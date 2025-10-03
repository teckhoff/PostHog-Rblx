--!strict

local HttpPromise = require(script.Parent.HttpPromise)
local PostHogTypes = require(script.Parent.Parent.PostHogTypes)

local function PostHogFetchOptionsToHttpRequest(
	url: string | Secret,
	options: PostHogTypes.PostHogFetchOptions,
	disableCompression: boolean?
): HttpPromise.HTTPRequest
	return {
		Url = url,
		Method = options.method,
		Headers = options.headers,
		Body = options.body,
		Compress = disableCompression and Enum.HttpCompression.None or Enum.HttpCompression.Gzip,
	}
end

return PostHogFetchOptionsToHttpRequest
