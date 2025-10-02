--!strict

local PostHogTypes = require(script.Parent.Parent.PostHogTypes)

local Promise = require(script.Parent.Parent.Utils.Promise)

--[=[
    @class FeatureFlagPoller
]=]
local FeatureFlagPoller = {}

export type FeatureFlagPollerOptions = {
	pollingInterval: number,
	projectApiKey: Secret,
	personalApiKey: Secret,
	timeout: number?,
	host: string,
	fetch: (
		url: string,
		options: PostHogTypes.PostHogFetchOptions
	) -> Promise.Promise<PostHogTypes.PostHogFetchResponse>,
	onError: ((error: any) -> ())?,
	customHeaders: { [string]: string }?,
	onLoad: ((count: number) -> ())?,
}

export type FeatureFlagPoller = typeof(setmetatable(
	{} :: {
		_pollingInterval: number,
		_personalApiKey: Secret,
		_projectApiKey: Secret,
		_featureFlags: { PostHogTypes.PostHogFeatureFlag },
		_featureFlagsByKey: { [string]: PostHogTypes.PostHogFeatureFlag },
		_groupTypeMapping: { [string]: string },
		_cohorts: { [string]: PostHogTypes.PropertyGroup },
		_loadedSuccessfullyOnce: boolean,
		_timeout: number?,
		_host: string,
		_fetch: (
			url: string,
			options: PostHogTypes.PostHogFetchOptions
		) -> Promise.Promise<PostHogTypes.PostHogFetchResponse>,
		_onError: ((error: any) -> ())?,
		_customHeaders: { [string]: string }?,
		_shouldBeginExponentialBackoff: boolean,
		_backOffCount: number,
		_onLoad: ((count: number) -> ())?,
	},
	{} :: typeof({ __index = FeatureFlagPoller })
))

function FeatureFlagPoller.new(optionsDictionary: FeatureFlagPollerOptions): FeatureFlagPoller
	local self = {} :: any

	return self
end

return FeatureFlagPoller
