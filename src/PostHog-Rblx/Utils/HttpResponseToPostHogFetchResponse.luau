--!strict

local HttpService = game:GetService("HttpService")

local HttpPromise = require(script.Parent.HttpPromise)
local PostHogTypes = require(script.Parent.Parent.PostHogTypes)

local function HttpResponseToPostHogFetchResponse(
	httpResponse: HttpPromise.HTTPResponse
): PostHogTypes.PostHogFetchResponse
	return {
		status = httpResponse.StatusCode,
		text = httpResponse.Body,
		json = HttpPromise.decodeJson(httpResponse),
	}
end

return HttpResponseToPostHogFetchResponse
