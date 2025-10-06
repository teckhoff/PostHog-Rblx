--!strict

local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")

local PostHogTypes = require(script.Parent.PostHogTypes)

local FeatureFlagPoller = require(script.Parent.FeatureFlags.FeatureFlagPoller)

local CopyDeep = require(script.Parent.Utils.CopyDeep)
local DataStructures = require(script.Parent.Utils.DataStructures)
local HttpPromise = require(script.Parent.Utils.HttpPromise)
local Promise = require(script.Parent.Utils.Promise)
local PromiseQueue = require(script.Parent.Utils.PromiseQueue)
local Signal = require(script.Parent.Utils.Signal)
local UUIDv7 = require(script.Parent.Utils.UUIDv7)

local fetch = require(script.Parent.fetch)
local version = require(script.Parent.version)

--[=[
    @class PostHog
]=]
local PostHog = {}
PostHog.__index = PostHog

export type PostHog = typeof(setmetatable(
	{} :: {
		_options: PostHogTypes.PostHogOptions?,

		-- PostHog Core Stateless
		_apiKey: string,
		_personalApiKey: Secret?,
		_host: string,
		_flushAt: number,
		_flushInterval: number,
		_flushPromise: Promise.Promise<any>?,
		_maxBatchSize: number,
		_maxQueueSize: number,
		_preloadFeatureFlags: boolean,
		_disableSurveys: boolean,
		_shutdownPromise: Promise.Promise<nil>?,
		_requestTimeout: number,
		_featureFlagsRequestTimeoutMs: number,
		_remoteConfigRequestTimeoutMs: number,
		_removeDebugCallback: (() -> ())?,
		_disableGeoip: boolean,
		_historicalMigration: boolean,
		_disabled: boolean,
		_disableCompression: boolean,
		_defaultOptIn: boolean,
		_promiseQueue: PromiseQueue.PromiseQueue,
		_events: { [string]: Signal.Signal<...any> },
		_flushTimer: thread?,
		_retryOptions: PostHogTypes.RetriableOptions,
		_initPromise: Promise.Promise<nil>,
		_isInitialized: boolean,
		_removeConfigResponsePromise: Promise.Promise<PostHogTypes.PostHogRemoteConfig?>?,

		-- PostHogBackendClient
		_enableLocalEvaluation: boolean,
		_featureFlagsPoller: FeatureFlagPoller.FeatureFlagPoller?,
		--_errorTracking
		_maxCacheSize: number,
		--_logger

		_messageQueue: DataStructures.Queue<PostHogTypes.PostHogEventProperties>,
		_serverId: string,
		_serverStartedEventSent: boolean,
		_serverClosedEventSent: boolean,

		_currentPlayers: { string },
	},
	{} :: typeof({ __index = PostHog })
))

function PostHog.new(options: PostHogTypes.PostHogCoreOptions): PostHog
	local self = setmetatable({} :: any, PostHog)

	self._options = options

	assert(options.api_key, "")

	self._apiKey = options.api_key

	if options.usePersonalApiKey then
		self._personalApiKey = options.personal_api_key_secret_name
				and HttpService:GetSecret(options.personal_api_key_secret_name)
			or HttpService:GetSecret(PostHogTypes.DefaultSecretNames.PersonalApiKey)
	end

	self._host = options.host and options.host or PostHogTypes.DefaultHosts.US

	self._flushAt = options.flushAt and math.max(options.flushAt, 1) or 20

	self._flushInterval = options.flushInterval and options.flushInterval or 10

	self._maxBatchSize = math.max(self._flushAt, options.maxBatchSize and options.maxBatchSize or 100)

	self._maxQueueSize = math.max(self._flushAt, options.maxQueueSize and options.maxQueueSize or 1000)

	self._preloadFeatureFlags = options.preloadFeatureFlags and options.preloadFeatureFlags or true

	self._disableSurveys = options.disableSurveys and options.disableSurveys or false

	self._requestTimeout = options.requestTimeout and options.requestTimeout or 10

	self._featureFlagsRequestTimeoutMs = options.featureFlagRequestTimeoutSeconds
			and options.featureFlagRequestTimeoutSeconds
		or 3

	self._remoteConfigRequestTimeoutMs = options.featureFlagRequestTimeoutSeconds
			and options.featureFlagRequestTimeoutSeconds
		or 3

	self._disableGeoip = true

	self._historicalMigration = options.historicalMigration and options.historicalMigration or false

	self._disabled = options.disabled and options.disabled or false

	self._disableCompression = options.disableCompression and options.disableCompression or false

	self._defaultOptIn = options.defaultOptIn and options.defaultOptIn or false

	self._promiseQueue = PromiseQueue.new()

	self._events = {}

	self._retryOptions = {
		retryCount = options.fetchRetryCount and options.fetchRetryCount or 3,
		retryDelay = options.fetchRetryDelay and options.fetchRetryDelay or 3,
	}

	self._enableLocalEvaluation = options.enableLocalEvaluation and options.enableLocalEvaluation or true

	self._featureFlagPollingInterval = options.featureFlagPollingInterval and options.featureFlagPollingInterval or 30

	self._featureFlagsPoller = FeatureFlagPoller.new({
		pollingInterval = self._featureFlagPollingInterval :: number,
		projectApiKey = self._apiKey :: Secret,
		personalApiKey = self._personalApiKey :: Secret,
		timeout = self._requestTimeout :: number,
		host = self._host :: string,
		fetch = fetch,
		onError = function(err: any) end,
		onLoad = function(count: number) end,
		customHeaders = {},
	})

	--_errorTracking

	self._maxCacheSize = options.maxCacheSize and options.maxCacheSize or 50000

	--_logger

	self._messageQueue = DataStructures.getQueue()

	self._initPromise = Promise:Resolve()
	self._isInitialized = true

	self._serverId = `S-{UUIDv7()}`

	self._serverStartedEventSent = false
	self._serverClosedEventSent = false

	self._currentPlayers = {}

	return self
end

function PostHog.promiseNew(options: PostHogTypes.PostHogCoreOptions): Promise.Promise<PostHog>
	return Promise.spawn(function(resolve, reject)
		local success, instanceOrError = pcall(function()
			return PostHog.new(options)
		end)

		if success then
			resolve(instanceOrError)

			instanceOrError:_startFlushTimerThread()
		else
			reject(instanceOrError)
		end
	end)
end

function PostHog._buildPayload(
	self: PostHog,
	payload: {
		distinct_id: string?,
		event: string,
		properties: PostHogTypes.PostHogEventProperties?,
	}
): PostHogTypes.PostHogEventProperties
	local newPayload = {
		distinct_id = payload.distinct_id,
		event = payload.event,
		properties = payload.properties or {},
	}

	newPayload.properties[PostHogTypes.Properties.Library] = "posthog-rblx"
	newPayload.properties[PostHogTypes.Properties.LibraryVersion] = version
	newPayload.properties[PostHogTypes.Properties.ServerId] = self._serverId

	return newPayload
end

function PostHog._prepareMessage( -- Merge with Build Payload?
	self: PostHog,
	type: string,
	message: PostHogTypes.PostHogEventProperties -- Assumed to be a dictionary in PostHog Core Stateless
): PostHogTypes.PostHogEventProperties
	local preparedMessage = CopyDeep(message)

	preparedMessage["type"] = type
	preparedMessage["library"] = "posthog-rblx"
	preparedMessage["library_version"] = version
	preparedMessage["timestamp"] = DateTime.now():ToIsoDate()
	preparedMessage["uuid"] = UUIDv7()

	return preparedMessage
end

function PostHog._enqueue(self: PostHog, type: string, message: any)
	local preparedMessage = self:_prepareMessage(type, message)

	if self._messageQueue:Length() > self._maxQueueSize then
		self._messageQueue:Dequeue()
		print(`[PostHog]: MessageQueue is full; oldest event being dropped.`)
	end

	self._messageQueue:Queue(preparedMessage)

	self:getEventSignal(type):Fire(message)

	if self._messageQueue:Length() > self._flushAt then
		self:_clearFlushTimerThread()
		self:_flushQueue()
	else
		if not self._flushTimer then
			self:_startFlushTimerThread()
		end
	end
end

function PostHog._flushQueue(self: PostHog): Promise.Promise<nil>
	local nextFlushPromise = Promise.allSettled({ self._flushPromise }):Then(function()
		return self:_flush()
	end)

	self._flushPromise = nextFlushPromise

	Promise.allSettled({ nextFlushPromise }):Then(function()
		if self._flushPromise == nextFlushPromise then
			self._flushPromise = nil
		end
	end)

	return nextFlushPromise
end

function PostHog._flush(self: PostHog): Promise.Promise<nil>
	local fetchPromises: { Promise.Promise<any> } = {}
	local sentMessages = {}
	local originalQueueLength = self._messageQueue:Length()

	print(`[PostHog Flush]: Message Queue:`)
	print(self._messageQueue._Queue)

	while self._messageQueue:Length() > 0 and #sentMessages < originalQueueLength do
		local batch = self._messageQueue:DequeueBatch(self._maxBatchSize)

		print(`[PostHog Flush]: Batch:`)
		print(batch)
		print(self._messageQueue._Queue)

		local data: { [string]: any } = {
			api_key = self._apiKey,
			batch = batch,
			sent_at = DateTime.now():ToIsoDate(),
		}

		local payload = HttpService:JSONEncode(data)

		local url = `{self._host}/batch/`

		local fetchOptions: PostHogTypes.PostHogFetchOptions = {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
			},
			body = payload,
		}

		local fetchPromise = fetch(url, fetchOptions, self._disableCompression):Then(
			function(response: HttpPromise.HTTPResponse)
				for key, value in response do
					print(`[PostHog Fetch]: {key} = {value}`)
				end
			end,
			function(err)
				warn(`[PostHog fetch]: Fetch failed, error: {err}`)
			end
		)

		table.insert(fetchPromises, fetchPromise)

		table.move(batch, 1, #batch, #sentMessages + 1, sentMessages)
	end

	return Promise.allSettled(fetchPromises):Finally(function()
		self:getEventSignal(PostHogTypes.Events.Flush):Fire(sentMessages)
		self:_startFlushTimerThread()
	end)
end

function PostHog._startFlushTimerThread(self: PostHog)
	--[[if self._flushTimer then
		self:_clearFlushTimerThread()
	end]]

	self._flushTimer = task.delay(self._flushInterval, function()
		self:_flush()
	end)
end

function PostHog._clearFlushTimerThread(self: PostHog)
	if self._flushTimer and coroutine.status(self._flushTimer) == "running" then
		task.cancel(self._flushTimer)
	end

	self._flushTimer = nil
end

function PostHog._identify(self: PostHog, distinctId: string | number, properties: PostHogTypes.PostHogEventProperties?)
	if typeof(distinctId) == "number" then
		distinctId = tostring(distinctId)
	end

	local payload = self:_buildPayload({
		distinct_id = distinctId :: string,
		event = PostHogTypes.Events.Identify,
		properties = properties,
	})

	self:_enqueue(PostHogTypes.PayloadType.Identify, payload)
end

function PostHog._capture(
	self: PostHog,
	distinctId: string | number | nil,
	event: string,
	properties: PostHogTypes.PostHogEventProperties?,
	options: PostHogTypes.PostHogCaptureOptions?
)
	if distinctId and typeof(distinctId) == "number" then
		distinctId = tostring(distinctId)
	end

	local payload = self:_buildPayload({
		distinct_id = distinctId :: string?,
		event = event,
		properties = properties,
	})

	self:_enqueue(PostHogTypes.PayloadType.Capture, payload)
end

function PostHog._alias(
	self: PostHog,
	alias: string,
	distinctId: string | number,
	properties: PostHogTypes.PostHogEventProperties?,
	options: PostHogTypes.PostHogCaptureOptions?
)
	if typeof(distinctId) == "number" then
		distinctId = tostring(distinctId)
	end

	if not properties then
		properties = {}
	end

	if properties then
		properties["distinct_id"] = distinctId
		properties["alias"] = alias
	end

	local payload = self:_buildPayload({
		distinct_id = distinctId :: string,
		event = PostHogTypes.Events.Alias,
		properties = properties,
	})

	self:_enqueue(PostHogTypes.PayloadType.Alias, payload)
end

function PostHog.addPendingPromise<T>(self: PostHog, promise: Promise.Promise<T>): Promise.Promise<T>
	return self._promiseQueue:Add(promise)
end

function PostHog.onServerStarted(self: PostHog)
	if self._serverStartedEventSent then
		return
	end

	self._serverStartedEventSent = true

	self:_capture(self._serverId, PostHogTypes.ServerEvents.ServerStarted)
end

function PostHog.onServerClosed(self: PostHog, closeReason: Enum.CloseReason)
	if self._serverClosedEventSent then
		return
	end

	self._serverClosedEventSent = true

	for _, id in self._currentPlayers do
		self:_capture(id, PostHogTypes.Events.PlayerLeft)
	end

	self:_capture(self._serverId, PostHogTypes.ServerEvents.ServerClosed, { ["Close Reason"] = closeReason.Name })

	self:_flush()
end

function PostHog._onPlayerAdded(self: PostHog, player: Player, anonymous: boolean?)
	local id = anonymous and UUIDv7() or tostring(player.UserId)

	if anonymous then
		player:SetAttribute(PostHogTypes.Attributes.AnonymousId, id)
	end

	self:_capture(id, PostHogTypes.Events.PlayerJoined)

	if not table.find(self._currentPlayers, id) then
		table.insert(self._currentPlayers, id)
	end
end

function PostHog.onPlayerAdded(self: PostHog, player: Player): Promise.Promise<()>
	local PolicyPromise = Promise.new(function(resolve, reject)
		local policyInfo: { [string]: boolean }? = nil
		local tryCount = 1

		while not policyInfo and tryCount <= 3 do
			local success, policyInfoOrError = pcall(function()
				return PolicyService:GetPolicyInfoForPlayerAsync(player)
			end)

			if not success then
				warn({
					`[PostHog]: Error retrieving policy info for user {player.UserId}. {tryCount < 3 and "Retrying..." or "Keeping anonymous."} (err: {policyInfoOrError})`,
				})
				continue
			end

			policyInfo = policyInfoOrError

			break
		end

		if policyInfo then
			resolve(policyInfo)
			return
		end

		reject(`Unable to get PolicyInfo for player {player.UserId}. Treating as anonymous.`)
	end)

	PolicyPromise:Then(function(policyInfo: { [string]: boolean })
		if policyInfo and policyInfo["AreAdsAllowed"] ~= nil and policyInfo["AreAdsAllowed"] == true then
			self:_onPlayerAdded(player)
		else
			self:_onPlayerAdded(player, true)
		end
	end, function(error: string)
		warn(`[PostHog]: {error}`)
		self:_onPlayerAdded(player, true)
	end)

	return PolicyPromise
end

function PostHog.onPlayerRemoving(self: PostHog, player: Player)
	if player:GetAttribute(PostHogTypes.Attributes.IsRemoving) then
		return
	end

	player:SetAttribute(PostHogTypes.Attributes.IsRemoving, true)

	local id = (player:GetAttribute(PostHogTypes.Attributes.AnonymousId) :: string?) or tostring(player.UserId)

	self:_capture(id, PostHogTypes.Events.PlayerLeft)

	local index = table.find(self._currentPlayers, id)

	if index then
		table.remove(self._currentPlayers, index)
	end
end

function PostHog.getEventSignal(self: PostHog, event: string): Signal.Signal<any>
	if not self._events[event] then
		self._events[event] = Signal.new()
	end

	return self._events[event]
end

function PostHog.isDisabled(self: PostHog): boolean
	return self._disabled
end

return PostHog
