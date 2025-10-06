--!strict

local Promise = require(script.Parent.Utils.Promise)
local Signal = require(script.Parent.Utils.Signal)

--[=[
    @class PostHogTypes
]=]
local PostHogTypes = table.freeze({
	-- ActionStepStringMatching Enum
	ActionStepStringMatching = table.freeze({
		Contains = "contains",
		Exact = "exact",
		Regex = "regex",
	}),

	Attributes = table.freeze({
		AnonymousId = "AnonymousId",
		IsRemoving = "IsRemoving",
	}),

	-- Compression Enum
	Compression = table.freeze({
		Base64 = "base64",
		GZip = "gzip",
	}),

	DefaultAssetHosts = table.freeze({
		US = "https://us-assets.i.posthog.com",
		EU = "https://eu-assets.i.posthog.com",
	}),

	DefaultHosts = table.freeze({
		US = "https://us.i.posthog.com",
		EU = "https://eu.i.posthog.com",
	}),

	-- Enum for the Default SecretStore names
	DefaultSecretNames = table.freeze({
		PersonalApiKey = "POSTHOG_PERSONAL_API_KEY",
	}),

	-- Events that have been implemented
	Events = table.freeze({
		Identify = "$identify",
		Alias = "$create_alias",
		Flush = "flush",
		PlayerJoined = "Player Joined",
		PlayerLeft = "Player Left",
	}),

	ServerEvents = table.freeze({
		ServerStarted = "Server Started",
		ServerClosed = "Server Closed",
	}),

	PayloadType = table.freeze({
		Identify = "identify",
		Capture = "capture",
		Alias = "alias",
	}),

	-- PostHogPersistedProperty Enum
	PostHogPersistedProperty = table.freeze({
		AnonymousId = "anonymous_id",
		DistinctId = "distinct_id",
		Props = "props",
		FeatureFlagDetails = "feature_flag_details",
		FeatureFlags = "feature_flags",
		FeatureFlagPayloads = "feature_flag_payloads",
		BootstrapFeatureFlagDetails = "bootstrap_feature_flag_details",
		BootstrapFeatureFlags = "bootstrap_feature_flags",
		BootstrapFeatureFlagPayloads = "bootstrap_feature_flag_payloads",
		OverrideFeatureFlags = "override_feature_flags",
		Queue = "queue",
		OptedOut = "opted_out",
		SessionId = "session_id",
		SessionStartTimestamp = "session_start_timestamp",
		SessionLastTimestamp = "session_timestamp",
		PersonProperties = "person_properties",
		GroupProperties = "group_properties",
		RemoteConfig = "remote_config",
	}),

	Properties = {
		ServerId = "Server ID",
		Library = "lib",
		LibraryVersion = "lib_version",
	},

	-- SurveyMatchType Enum
	SurveyMatchType = table.freeze({
		Regex = "regex",
		NotRegex = "not_regex",
		Exact = "exact",
		IsNot = "is_not",
		Icontains = "icontains",
		NotIcontains = "not_icontains",
	}),

	-- SurveyPosition Enum
	SurveyPosition = table.freeze({
		TopLeft = "top_left",
		TopCenter = "top_center",
		TopRight = "top_right",
		MiddleLeft = "middle_left",
		MiddleCenter = "middle_center",
		MiddleRight = "middle_right",
		Left = "left",
		Right = "right",
		Center = "center",
	}),

	-- SurveyQuestionDescriptionContentType Enum
	SurveyQuestionDescriptionContentType = table.freeze({
		Html = "html",
		Text = "text",
	}),

	-- SurveyQuestionBranchingType Enum
	SurveyQuestionBranchingType = table.freeze({
		NextQuestion = "next_question",
		End = "end",
		ResponseBased = "response_based",
		SpecificQuestion = "specific_question",
	}),

	-- SurveyQuestionType Enum
	SurveyQuestionType = table.freeze({
		Open = "open",
		MultipleChoice = "multiple_choice",
		SingleChoice = "single_choice",
		Rating = "rating",
		Link = "link",
	}),

	-- SurveyRatingDisplay Enum
	SurveyRatingDisplay = table.freeze({
		Number = "number",
		Emoji = "emoji",
	}),

	-- SurveyType Enum
	SurveyType = table.freeze({
		Popover = "popover",
		API = "api",
		Widget = "widget",
		ExternalSurvey = "external_survey",
	}),

	-- SurveyWidgetType Enum
	SurveyWidgetType = table.freeze({
		Button = "button",
		Tab = "tab",
		Selector = "selector",
	}),

	knownUnsafeEditableEvents = table.freeze({
		"$snapshot",
		"$pageview",
		"$pageleave",
		"$set",
		"survey dismissed",
		"survey sent",
		"survey shown",
		"$identify",
		"$groupidentify",
		"$create_alias",
		"$$client_ingestion_warning",
		"$web_experiment_applied",
		"$feature_enrollment_update",
		"$feature_flag_called",
	}),
})

-- TypeScript Utility Types
--[=[
    @type Record<Key, Value> { [Key]: Value }
    @within PostHogTypes

    "Shorthand" for defining a dictionary, for parity with TypeScript's Record utility type.
]=]
export type Record<Key, Value> = { [Key]: Value }

-- PostHog Enum Types
export type ActionStepStringMatching = "contains" | "exact" | "regex"

export type Compression = "base64" | "gzip"

export type PostHogPersistedProperty =
	"anonymous_id"
	| "distinct_id"
	| "props"
	| "feature_flag_details"
	| "feature_flags"
	| "feature_flag_payloads"
	| "bootstrap_feature_flag_details"
	| "bootstrap_feature_flags"
	| "bootstrap_feature_flag_payloads"
	| "override_feature_flags"
	| "queue"
	| "opted_out"
	| "session_id"
	| "session_start_timestamp"
	| "session_timestamp"
	| "person_properties"
	| "group_properties"
	| "remote_config"

export type SurveyMatchType = "regex" | "not_regex" | "exact" | "is_not" | "icontains" | "not_icontains"

export type SurveyPosition =
	"middle_center"
	| "left"
	| "top_left"
	| "top_center"
	| "top_right"
	| "middle_right"
	| "center"
	| "middle_left"
	| "right"

export type SurveyQuestionDescriptionContentType = "text" | "html"

export type SurveyQuestionBranchingType = "specific_question" | "next_question" | "response_based" | "end"

export type SurveyQuestionType = "single_choice" | "link" | "rating" | "open" | "multiple_choice"

export type SurveyRatingDisplay = "number" | "emoji"

export type SurveyType = "external_survey" | "api" | "widget" | "popover"

export type SurveyWidgetType = "button" | "tab" | "selector"

-- PostHog Addtl Types
export type ActionStepType = {
	event: string?,
	selector: string?,
	text: string?,
	text_matching: ActionStepStringMatching?, -- Default ActionStepStringMatching.Exact
	href: string?,
	href_matching: ActionStepStringMatching?, -- Default ActionStepStringMatching.Exact
	url: string?,
	url_matching: ActionStepStringMatching?, -- Default ActionStepStringMatching.Exact
}

export type EvaluationReason = {
	code: string?,
	condition_index: number?,
	description: string?,
}

export type FeatureFlagDetail = {
	key: string,
	enabled: boolean,
	variant: string?,
	reason: EvaluationReason?,
	metadata: FeatureFlagMetadata?,
}

export type FeatureFlagMetadata = {
	id: number?,
	version: number?,
	description: string?,
	-- Payloads in the response are always JSON encoded as a string
	payload: string?,
}

export type FeatureFlagValue = string | boolean

export type JsonType = string | number | boolean | nil | { JsonType } | { [string]: JsonType }

export type Logger = {
	_log: (level: LogLevel, ...any) -> (),
	info: (...any) -> (),
	warn: (...any) -> (),
	error: (...any) -> (),
	critical: (...any) -> (),
	uninitializedWarning: (methodName: string) -> (),
	createLogger: (prefix: string) -> Logger,
}

export type LogLevel = "log" | "warn" | "error"

export type RetriableOptions = {
	retryCount: number,
	retryDelay: number,
}

-- Survey Types
export type Survey = {
	-- NOTE: Keep this in sync with bakcend's SurveyAPISerializer.
	id: string,
	name: string,
	description: string?,
	type: SurveyType,
	feature_flag_keys: {
		{
			key: string,
			value: string?,
		}
	}?,
	linked_flag_key: string?,
	targeting_flag_key: string?,
	internal_targeting_flag_key: string?,
	questions: { SurveyQuestion },
	appearance: SurveyAppearance?,
	conditions: {
		url: string?,
		selector: string?,
		seenSurveyWaitPeriodInDays: number?,
		urlMatchType: SurveyMatchType?,
		events: {
			repeatedActivation: boolean?,
			values: {
				{
					name: string,
				}
			},
		}?,
		actions: {
			values: { SurveyActionType },
		}?,
		deviceTypes: { string }?,
		deviceTypesMatchType: SurveyMatchType?,
		linkedFlagVariant: string?,
	}?,
	start_date: string?,
	end_date: string?,
	current_iteration: number?,
	current_iteration_start_date: string?,
}

export type SurveyActionType = {
	id: number,
	name: string?,
	steps: { ActionStepType }?,
}

export type SurveyAppearance = {
	-- NOTE: Keep in sync with Frontend types. I don't have front-end types right now. Oops. Different package for survey support?
	backgroundColor: string?,
	submitButtonColor: string?,
	submitButtonText: string?, -- eventually getting deprecated
	submitButtonTextColor: string?,
	ratingButtonColor: string?,
	ratingButtonActiveColor: string?,
	autoDisappear: string?,
	displayThankYouMessage: boolean?,
	thankYouMessageHeader: string?,
	thankYouMessageDescription: string?,
	thankYouMessageDescriptionContextType: SurveyQuestionDescriptionContentType?,
	thankYouMessageCloseButtonText: string?,
	borderColor: string?,
	position: SurveyPosition?,
	placeholder: string?,
	shuffleQuestions: boolean?,
	surveyPopupDelaySeconds: number?,

	widgetType: SurveyWidgetType?,
	widgetSelector: string?,
	widgetLabel: string?,
	widgetColor: string?,
}

export type SurveyElement = {
	text: string?,
	el_text: string?,
	tag_name: string?,
	href: string?,
	attr_id: string?,
	attr_class: { string }?,
	nth_child: number?,
	nth_of_type: number?,
	attributes: Record<string, any>?,
	event_id: number?,
	order: number?,
	group_id: number?,
}

export type SurveyRenderReason = {
	visible: boolean,
	disabledReason: string?,
}

export type SurveyResponse = {
	surveys: { Survey },
}

-- Survey Question Types
export type SurveyQuestion = BasicSurveyQuestion | LinkSurveyQuestion | RatingSurveyQuestion | MultipleSurveyQuestion

type SurveyQuestionBase = {
	question: string,
	id: string,
	description: string?,
	descriptionContentType: SurveyQuestionDescriptionContentType?,
	optional: boolean?,
	buttonText: string?,
	originalQuestionIndex: number,
	branching: NextQuestionBranching | EndBranching | ResponseBasedBranching | SpecificQuestionBranching | nil,
}

export type BasicSurveyQuestion = SurveyQuestionBase & {
	type: "open", --SurveyQuestionType.Open
}

export type LinkSurveyQuestion = SurveyQuestionBase & {
	type: "link", --SurveyQuestionType.Link
	link: string?,
}

export type RatingSurveyQuestion = SurveyQuestionBase & {
	type: "rating", --SurveyQuestionType.Rating
	display: SurveyRatingDisplay,
	scale: number,
	lowerBoundLabel: string,
	upperBoundLabel: string,
}

export type MultipleSurveyQuestion = SurveyQuestionBase & {
	type: "single_choice" | "multiple_choice", --SurveyQuestionType.SingleChoice or SurveyQuestionType.MultipleChoice
	choices: { string },
	hasOpenChoice: boolean?,
	shuffleOptions: boolean?,
}

export type NextQuestionBranching = {
	type: "next_question", --SurveyQuestionBranchingType.NextQuestion
}

export type EndBranching = {
	type: "end", --SurveyQuestionBranchingType.End
}

export type ResponseBasedBranching = {
	type: "response_based", --SurveyQuestionBranchingType.ResponseBased
	responseValues: Record<string, any>,
}

export type SpecificQuestionBranching = {
	type: "specific_question", --SurveyQuestionBranchingType.SpecificQuestion
	index: number,
}

-- PostHog Core
--[=[
	@type PostHogCoreOptions
	@within PostHogTypes
]=]
export type PostHogCoreOptions = {
	-- The name of your API key in the SecretStore.
	-- If it doesn't exist, it will default to 'POSTHOG_API_KEY'.
	api_key: string,

	-- Whether or not there is a Personal API Key to use.
	-- Defaults to false.
	usePersonalApiKey: boolean?,

	-- The name of your personal API key in the SecretStore.
	-- If it doesn't exist, it will default to 'POSTHOG_PERSONAL_API_KEY'.
	personal_api_key_secret_name: string?,

	-- PostHog API host, usually 'https://us.i.posthog.com' or 'https://eu.i.posthog.com'
	host: string?,

	-- The number of events to queue before sending to PostHog (flushing)
	flushAt: number?,

	-- The interval in seconds between periodic flushes
	flushInterval: number?,

	-- The maximum number of queued messages to be flushed as part of a single batch.
	-- Must be higher than flushAt.
	maxBatchSize: number?,

	maxQueueSize: number?,

	-- If set to true the SDK is essentially disabled (useful for local environments where you don't want to track anything)
	disabled: boolean?,

	-- If set to false the SDK will not track until the `optIn` function is called.
	defaultOptIn: boolean?,

	-- If set to false the SDK will not track until the `optIn` function is called.
	sendFeatureFlagEvent: boolean?,

	-- Whether to load feature flags when initialized or not
	preloadFeatureFlags: boolean?,

	-- Whether to load remote config when initialized or not
	-- Experimental support
	-- Default: false - Remote config is loaded by default
	disableRemoteConfig: boolean?,

	-- Whether to load surveys when initialized or not
	-- Experimental support
	-- Default: false - Surveys are loaded by default, but requires the `PostHogSurveyProvider` to be used
	disableSurveys: boolean?,

	-- Option to bootstrap the library with given distinctId and feature flags
	boostrap: {
		distinctId: string?,
		isIdentifiedId: boolean?,
		featureFlags: Record<string, FeatureFlagValue>?,
		featureFlagPayloads: Record<string, JsonType>?,
	}?,

	fetchRetryCount: number?,

	fetchRetryDelay: number?,

	requestTimeout: number?,

	featureFlagRequestTimeoutSeconds: number?,

	remoteConfigRequestTimeoutSeconds: number?,

	sessionExpirationTimeSeconds: number?,

	-- Whether you want to disable Gzip compression for outwards requests.
	-- Defaults to false.
	disableCompression: boolean?,

	-- Whether or not to disable Geoip. Currently unused. Perhaps useful to see where servers are located?
	-- Defaults to true.
	disableGeoip: boolean?,

	historicalMigration: boolean?,

	-- The max size of the cache.
	-- Defaults to 50000.
	maxCacheSize: number?,

	-- How often (in seconds) featureFlags are polled.
	-- Defaults to 30 seconds.
	featureFlagPollingInterval: number?,

	-- Whether or not Local Evaluation for Feature Flags should be enabled.
	-- Periodically gets the Feature Flag definitions and stores them instead of polling PostHog every time.
	-- Defaults to true.
	enableLocalEvaluation: boolean?,
}

-- PostHog Core Composition Types
type PostHogCompressionRecordingBase = {
	sessionRecording: boolean | { [string]: JsonType } | nil,
	supportedCompression: { Compression }?,
}

export type PostHogEventProperties = { [string]: JsonType }

type PostHogFlagResponseBase = PostHogCompressionRecordingBase & {
	flags: {
		[string]: FeatureFlagDetail,
	},
	featureFlags: {
		[string]: FeatureFlagValue,
	},
	featureFlagPayloads: {
		[string]: JsonType,
	},
	errorsWhileComputingFlags: boolean,
	quotaLimited: { string }?,
}

type PostHogFlagResponseBaseNoFlags = PostHogCompressionRecordingBase & {
	featureFlags: {
		[string]: FeatureFlagValue,
	},
	featureFlagPayloads: {
		[string]: JsonType,
	},
	errorsWhileComputingFlags: boolean,
	quotaLimited: { string }?,
}

type PostHogFlagResponseBaseNoFeatureFlag = PostHogCompressionRecordingBase & {
	flags: {
		[string]: FeatureFlagDetail,
	},
	errorsWhileComputingFlags: boolean,
	quotaLimited: { string }?,
}

-- PostHog Core Types
export type PostHogAutocaptureElement = {
	el_text: string?,
	tag_name: string,
	href: string?,
	nth_child: number?,
	nth_of_type: number?,
	order: number?,
} & PostHogEventProperties

export type PostHogCaptureOptions = {
	uuid: string?,
	timestamp: DateTime?,
	disableGeoip: boolean?,
}

export type PostHogFetchOptions = {
	method: "GET" | "POST" | "PUT" | "PATCH",
	mode: "no-cors"?,
	credentials: "omit"?,
	headers: { [string]: string | Secret },
	body: string?, -- Blob support?
	signal: Signal.Signal<(string, ...any)>?, -- Reason & extra args if needed
}

export type PostHogFetchResponse = {
	status: number,
	--text: () -> Promise.Promise<string>,
	text: string,
	json: Promise.Promise<any>,
}

export type PostHogFeatureFlagDetails = PostHogFeatureFlagResponse -- ???

export type PostHogFeatureFlagResponse = PostHogFlagResponseBase & {
	requestId: string,
}

export type PostHogFlagsAndPayloadsResponse = {
	featureFlags: {
		[string]: FeatureFlagValue,
	}?,
	featureFlagPayloads: {
		[string]: JsonType,
	}?,
}

export type PostHogFlagsStorageFormat = {
	flags: {
		[string]: FeatureFlagDetail,
	},
}

export type PostHogFlagResponse = PostHogFlagResponseBase & {
	requestId: string?,
}

export type PostHogV1FlagsResponse = PostHogFlagResponseBaseNoFlags & {
	requestId: string?,
}

export type PostHogV2FlagsResponse = PostHogFlagResponseBaseNoFeatureFlag & {
	requestId: string?,
}

export type PostHogGroupProperties = { [string]: string | number }

export type PostHogQueueItem = {
	message: any,
	callback: ((err: any) -> ())?,
}

export type PostHogRemoteConfig = PostHogCompressionRecordingBase & {
	surveys: boolean | { Survey } | nil,
	hasFeatureFlags: boolean?,
}

-- PostHog Node Types
export type PostHogOptions = PostHogCoreOptions & {
	persistence: "memory"?,
	personalApiKey: string?,
	privacyMode: boolean?,
	enableExceptionAutocapture: boolean?,
	featureFlagsPollingInterval: number?, -- Defaults to 30 seconds.
	maxCacheSize: number?,
	fetch: PromiseFetch?,
	enableLocalEvaluation: boolean?,
	before_send: BeforeSendFn | { BeforeSendFn } | nil,
}

export type IdentifyMessage = {
	distinctId: string,
	properties: Record<string | number, any>,
	disableGeoip: boolean?,
}

export type SendFeatureFlagsOptions = {
	onlyEvaluateLocally: boolean?,
	personProperties: Record<string, any>?,
	groupProperties: Record<string, Record<string, any>>?,
	flagKeys: { string }?,
}

export type EventMessage = IdentifyMessage & {
	event: string,
	groups: Record<string, string | number>?,
	sendFeatureFlags: boolean | SendFeatureFlagsOptions | nil,
	timestamp: DateTime?,
	uuid: string?,
}

export type GroupIdentifyMessage = {
	groupType: string,
	groupKey: string,
	properties: Record<string | number, any>?,
	distinctId: string?,
	disableGeoip: boolean?,
}

export type PropertyGroup = {
	type: "AND" | "OR",
	values: { FlagProperty } | { PropertyGroup },
}

export type FlagProperty = {
	key: string,
	type: string?,
	value: FlagPropertyValue,
	operator: string?,
	negation: boolean?,
	dependency_chain: { string }?,
}

export type FlagPropertyValue = string | number | { string | number } | boolean

export type FeatureFlagCondition = {
	properties: { FlagProperty },
	rollout_percentage: number?,
	variant: string?,
}

export type PostHogFeatureFlag = {
	id: number,
	name: string,
	key: string,
	filters: {
		aggregation_group_type_index: number?,
		groups: { FeatureFlagCondition }?,
		multivariate: {
			{
				variants: {
					key: string,
					rollout_percentage: number,
				},
			}
		}?,
		payloads: Record<string, string>?,
	}?,
	deleted: boolean,
	active: boolean,
	rollout_percentage: number?,
	ensure_experience_continuity: boolean,
	experiment_set: { number },
}

--
--[=[
	@class IPostHog
]=]
export type IPostHog = {
	--[=[
		@within IPostHog

		Capture allows you to capture anything a user does within your system, 
		which you can later use in PostHog to find patterns in usage,
		work out which features to improve or where people are giving up.

		@param messageOrId EventMessage | string -- An already generated EventMessage, or a distinctId which identifies the user.
		@param event string? -- PostHog recommends used [verb] [noun] to identify events easily. Only needed if messageOrId is not an EventMessage.
		@param properties Record<string | number, any>? -- A dictionary containig any information you want to add to the event. Optional.
		@param groups Record<string, string | number>? -- Dictionary of what groups are related to this event. Can be used to analyze entire groups instead of just users. Optional.
		@param sendFeatureFlags boolean | SendFeatureFlagsOptions | nil -- Used with experiments to send Feature Flags with the event.
	]=]
	capture: (
		messageOrId: EventMessage | string,
		event: string?,
		properties: Record<string | number, any>?,
		groups: Record<string, string | number>?,
		sendFeatureFlags: boolean | SendFeatureFlagsOptions | nil
	) -> (),

	--[=[
		@within IPostHog

		Capture an event immediately when you can't use the queue.
		Most likely not an option, but delcaring the type for parity at the moment.

		@param messageOrId EventMessage | string -- An already generated EventMessage, or a distinctId which identifies the user.
		@param event string? -- PostHog recommends used [verb] [noun] to identify events easily. Only needed if messageOrId is not an EventMessage.
		@param properties Record<string | number, any>? -- A dictionary containig any information you want to add to the event. Optional.
		@param groups Record<string, string | number>? -- Dictionary of what groups are related to this event. Can be used to analyze entire groups instead of just users. Optional.
		@param sendFeatureFlags boolean | SendFeatureFlagsOptions | nil -- Used with experiments to send Feature Flags with the event.

		@return Promise
	
	captureImmediate: (
		messageOrId: EventMessage | string,
		event: string?,
		properties: Record<string | number, any>?,
		groups: Record<string, string | number>?,
		sendFeatureFlags: boolean | SendFeatureFlagsOptions | nil
	) -> Promise.Promise<nil>,

	]=]

	--[=[
		@within IPostHog

		Lets you add metadata to users so you can more easily identify who they are in PostHog.
		You can also segment users by the metadata.

		@param messageOrId IdentifyMessage | string -- The identify message or the Id of the user.
		@param properties properties: Record<string | number, any>? -- A dictionary of properties for the user. Optional if messageOrId is an IdentifyMessage.
	]=]
	identify: (messageOrId: IdentifyMessage | string, properties: Record<string | number, any>?) -> (),

	--[=[
		
	identifyImmediate: (
		messageOrId: IdentifyMessage | string,
		properties: Record<string | number, any>?
	) -> Promise.Promise<nil>,
	]=]

	--[=[
		@within IPostHog

		Allows you to marry up two user IDs. Would be useful if we had a way to detect alt accounts?

		@param distinctId string -- The User ID of the player.
		@param aliasId string -- The User ID of the player we want to alias onto the first player.
	]=]
	alias: (distinctId: string, aliasId: string) -> (),

	--[=[
		@within IPostHog

		PostHog feature flags (https://posthog.com/docs/features/feature-flags)
	]=]
	isFeatureEnabled: (
		key: string,
		distinctId: string,
		options: {
			groups: Record<string, string>?,
			personProperties: Record<string, string>?,
			groupProperties: Record<string, Record<string, string>>?,
			onlyEvaluateLocally: boolean?,
			sendFeatureFlagEvents: boolean?,
		}?
	) -> Promise.Promise<boolean?>,

	--[=[
		
	]=]
	getFeatureFlag: (
		key: string,
		distinctId: string,
		options: {
			groups: Record<string, string>?,
			personProperties: Record<string, string>?,
			groupProperties: Record<string, Record<string, string>>?,
			onlyEvaluateLocally: boolean?,
			sendFeatureFlagEvents: boolean?,
		}?
	) -> Promise.Promise<FeatureFlagValue?>,

	--[=[
		
	]=]
	getFeatureFlagPayload: (
		key: string,
		distinctId: string,
		matchValue: FeatureFlagValue?,
		options: {
			onlyEvaluateLocally: boolean?,
		}?
	) -> Promise.Promise<JsonType?>,

	--[=[
		
	]=]
	groupIdentify: (
		groupTypeOrIdentifyMessage: GroupIdentifyMessage | string,
		groupKey: string?,
		properties: Record<string | number, any>?
	) -> (),

	--[=[
		
	]=]
	reloadFeatureFlags: () -> Promise.Promise<nil>,

	--[=[
		
	]=]
	shutdown: (shutdownTimeMs: number?) -> (),

	--[=[
		
	]=]
	waitForLocalEvaluationReady: (timeoutMs: number?) -> Promise.Promise<boolean>,

	--[=[
		
	]=]
	isLocalEvaluationReady: () -> boolean,
}

-- Functions
export type BeforeSendFn = (event: EventMessage?) -> EventMessage?
export type FetchLike = (url: string, options: PostHogFetchOptions) -> PostHogFetchResponse
export type PromiseFetch = (
	url: string,
	options: PostHogFetchOptions,
	disableCompression: boolean?
) -> Promise.Promise<PostHogFetchResponse>
export type SurveyCallback = (surveys: { Survey }) -> ()

return PostHogTypes
