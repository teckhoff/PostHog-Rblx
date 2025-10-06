local PostHog = require(script.PostHog)

print("Hello world, from server!")

PostHog.Enable({
	api_key = "<your-api-key-here>",
})
