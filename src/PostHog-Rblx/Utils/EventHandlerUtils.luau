--!strict

--[=[
	MIT License

	Copyright (c) 2014-2025 James Onnen (Quenty)

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]=]

--[=[
	Utility methods to fire an event in a free thread, reusing threads

	@class EventHandlerUtils
]=]

local EventHandlerUtils = {}

-- The currently idle thread to run the next handler on
local freeThreads = setmetatable({} :: { [string]: thread }, { __mode = "kv" })

-- Function which acquires the currently idle handler runner thread, runs the
-- function fn on it, and then releases the thread, returning it to being the
-- currently idle one.
-- If there was a currently idle runner thread already, that's okay, that old
-- one will just get thrown and eventually GCed.
function EventHandlerUtils._fireEvent<T...>(memoryCategory: string, fn: (T...) -> (), ...: T...): ()
	local acquiredRunnerThread = freeThreads[memoryCategory]
	freeThreads[memoryCategory] = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeThreads[memoryCategory] = acquiredRunnerThread
end

-- Coroutine runner that we create coroutines of. The coroutine can be
-- repeatedly resumed with functions to run followed by the argument to run
-- them with.
function EventHandlerUtils._initializeThread(memoryCategory: string): ()
	if memoryCategory == "" then
		debug.setmemorycategory("signal_unknown")
	else
		debug.setmemorycategory(memoryCategory)
	end

	-- Note: We cannot use the initial set of arguments passed to
	-- initializeThread for a call to the handler, because those
	-- arguments would stay on the stack for the duration of the thread's
	-- existence, temporarily leaking references. Without access to raw bytecode
	-- there's no way for us to clear the "..." references from the stack.
	while true do
		EventHandlerUtils._fireEvent(coroutine.yield())
	end
end

--[=[
	Safely fires an event in the given memory category we're in
]=]
function EventHandlerUtils.fire<T...>(memoryCategory: string, callback: (T...) -> (), ...: T...): ()
	assert(type(memoryCategory) == "string", "Bad memoryCategory")
	assert(type(callback) == "function", "Bad callback")

	if not freeThreads[memoryCategory] then
		freeThreads[memoryCategory] = coroutine.create(EventHandlerUtils._initializeThread)
		coroutine.resume(freeThreads[memoryCategory], memoryCategory)
	end

	task.spawn(freeThreads[memoryCategory], memoryCategory, callback, ...)
end

return EventHandlerUtils
