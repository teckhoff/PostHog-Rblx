--!strict

local PostHogTypes = require(script.Parent.PostHogTypes)

local HttpPromise = require(script.Parent.Utils.HttpPromise)
local Promise = require(script.Parent.Utils.Promise)

local HttpResponseToPostHogFetchResponse = require(script.Parent.Utils.HttpResponseToPostHogFetchResponse)
local PostHogFetchOptionsToHttpRequest = require(script.Parent.Utils.PostHogFetchOptionsToHttpRequest)

local function fetch(
	url: string,
	options: PostHogTypes.PostHogFetchOptions,
	disableCompression: boolean?
): Promise.Promise<PostHogTypes.PostHogFetchResponse>
	return Promise.spawn(function(resolve, reject)
		local request = PostHogFetchOptionsToHttpRequest(url, options, disableCompression)

		HttpPromise.request(request):Then(function(response: HttpPromise.HTTPResponse)
			local fetchResponse = HttpResponseToPostHogFetchResponse(response)

			resolve(fetchResponse)
		end, function(errOrNotOkResponse: string | HttpPromise.HTTPResponse | nil)
			if not errOrNotOkResponse then
				reject("Unable to complete fetch.")
			end

			if typeof(errOrNotOkResponse) == "string" then
				reject(errOrNotOkResponse)
			end

			local fetchResponse = HttpResponseToPostHogFetchResponse(errOrNotOkResponse :: HttpPromise.HTTPResponse)

			-- Node fetch does not reject on a successful request that returns a status code that isn't in the 200s.
			resolve(fetchResponse)
		end)
	end)
end

return fetch
