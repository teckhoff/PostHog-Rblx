--!strict
local Players = game:GetService("Players")

local PostHog = require(script.PostHog)
local PostHogTypes = require(script.PostHogTypes)

local Promise = require(script.Utils.Promise)

local PostHogInstance: PostHog.PostHog? = nil
local PostHogInitPromise: Promise.Promise<PostHog.PostHog>? = nil

local PlayerAddedConnection: RBXScriptConnection? = nil
local PlayerRemovingConnection: RBXScriptConnection? = nil

export type PostHogOptions = PostHogTypes.PostHogCoreOptions

local PostHogRblx = {}

function PostHogRblx.Enable(options: PostHogOptions)
	if PostHogInstance then
		warn(`[PostHog]: Attempted to enable PostHog, but it is already enabled.`)
		return
	end

	PostHogInitPromise = PostHog.promiseNew(options):Then(function(newInstance: PostHog.PostHog)
		if not newInstance then
			error("[PostHog]: Unable to load PostHog.")
			return
		end

		PostHogInstance = newInstance

		newInstance:onServerStarted()

		game:BindToClose(function(closeReason: Enum.CloseReason)
			newInstance:onServerClosed(closeReason)
		end)

		local function OnPlayerAdded(player: Player)
			if player:GetAttribute("POSTHOG_IDENTIFIED") or not PostHogInstance then
				return
			end

			newInstance:onPlayerAdded(player):Finally(function()
				if not player:GetAttribute("POSTHOG_IDENTIFIED") then
					return
				end

				player:SetAttribute("POSTHOG_IDENTIFIED", true)
			end)
		end

		local function OnPlayerRemoving(player: Player)
			newInstance:onPlayerRemoving(player)
		end

		PlayerAddedConnection = Players.PlayerAdded:Connect(OnPlayerAdded)
		PlayerRemovingConnection = Players.PlayerRemoving:Connect(OnPlayerRemoving)

		for _, player in Players:GetPlayers() do
			OnPlayerAdded(player)
		end
	end)
end

return PostHogRblx
