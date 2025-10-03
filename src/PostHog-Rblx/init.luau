--!strict
local Players = game:GetService("Players")

local PostHog = require(script.PostHog)
local PostHogTypes = require(script.PostHogTypes)

local Promise = require(script.Utils.Promise)

local PostHogInstance: PostHog.PostHog? = nil
local PostHogInitPromise: Promise.Promise<PostHog.PostHog>? = nil

local PlayerAddedConnection: RBXScriptConnection? = nil

export type PostHogOptions = PostHogTypes.PostHogCoreOptions

local PostHogRblx = {}

function PostHogRblx.Enable(options: PostHogOptions?)
	if PostHogInstance then
		warn(`[PostHog]: Attempted to enable PostHog, but it is already enabled.`)
		return
	end

	PostHogInitPromise = PostHog.promiseNew(options):Then(function(newInstance: PostHog.PostHog)
		PostHogInstance = newInstance

		print(PostHogInstance)

		local function OnPlayerAdded(player: Player)
			if player:GetAttribute("POSTHOG_IDENTIFIED") or not PostHogInstance then
				return
			end

			PostHogInstance:_identify(player.UserId)

			player:SetAttribute("POSTHOG_IDENTIFIED", true)
		end

		PlayerAddedConnection = Players.PlayerAdded:Connect(OnPlayerAdded)

		for _, player in Players:GetPlayers() do
			OnPlayerAdded(player)
		end
	end)
end

return PostHogRblx
