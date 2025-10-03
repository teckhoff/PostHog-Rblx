--!strict

local Promise = require(script.Parent.Promise)
local UUIDv7 = require(script.Parent.UUIDv7)

--[=[
    @class PromiseQueue
]=]
local PromiseQueue = {}

export type PromiseQueue = typeof(setmetatable(
	{} :: {
		_promiseByIds: { [string]: Promise.Promise<any> },
		_promiseCount: number,
	},
	{} :: typeof({ __index = PromiseQueue })
))

function PromiseQueue.new(): PromiseQueue
	local self = setmetatable({} :: any, PromiseQueue)

	self._promiseByIds = {}
	self._promiseCount = 0

	return self
end

function PromiseQueue.Add(self: PromiseQueue, promise: Promise.Promise<any>): Promise.Promise<any>
	local promiseId = UUIDv7()

	self._promiseByIds[promiseId] = promise
	self._promiseCount += 1

	promise:Catch():Finally(function()
		self._promiseByIds[promiseId] = nil
		self._promiseCount -= 1
	end)

	return promise
end

function PromiseQueue.Join(self: PromiseQueue): Promise.Promise<nil>
	--[[return Promise.new(function(resolve, reject)
        Promise.
    end)]]

	print(`PROMISE QUEUE JOIN NOT YET IMPLEMENTED`)

	return Promise.Resolve({})
end

function PromiseQueue.GetLength(self: PromiseQueue): number
	return self._promiseCount
end

return PromiseQueue
