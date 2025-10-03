--!strict

-- Stack
export type Stack<T> = {
	_Stack: { T },
	Push: (Stack<T>, element: T) -> nil,
	Pop: (Stack<T>) -> T?,
}

local function StackPush<T>(stack: Stack<T>, element: T)
	table.insert(stack._Stack, element)
end

local function StackPop<T>(stack: Stack<T>): T?
	if #stack._Stack <= 0 then
		return nil
	end

	local Element = stack._Stack[#stack._Stack]

	table.remove(stack._Stack, #stack._Stack)

	return Element
end

-- Queue
export type Queue<T> = {
	_Queue: { T },
	Queue: (Queue<T>, element: T) -> nil,
	Dequeue: (Queue<T>) -> T?,
	DequeueBatch: (Queue<T>, batchSize: number) -> { T },
	Length: (Queue<T>) -> number,
}

local function QueueQueue<T>(queue: Queue<T>, element: T)
	table.insert(queue._Queue, element)
end

local function QueueDequeue<T>(queue: Queue<T>): T?
	if #queue._Queue <= 0 then
		return nil
	end

	local Element = queue._Queue[1]

	table.remove(queue._Queue, 1)

	return Element
end

local function QueueDequeueBatch<T>(queue: Queue<T>, batchSize: number): { T }
	if #queue._Queue <= 0 then
		return {}
	end

	local outputBatch: { T } = {}

	if batchSize >= #queue._Queue then
		outputBatch = queue._Queue
		queue._Queue = {}
		return outputBatch
	end

	table.move(queue._Queue, 1, batchSize, 1, outputBatch)

	local newQueue = {}

	table.move(queue._Queue, batchSize + 1, #queue._Queue, 1, newQueue)

	queue._Queue = newQueue

	return outputBatch
end

local function QueueLength<T>(queue: Queue<T>): number
	return #queue._Queue
end

-- Data Structures Table
local DataStructures = {}

function DataStructures.getStack<T>(): Stack<T>
	local Stack: Stack<T> = {
		_Stack = {},
		Push = StackPush,
		Pop = StackPop,
	}

	return Stack
end

function DataStructures.getQueue<T>(): Queue<T>
	local Queue: Queue<T> = {
		_Queue = {},
		Queue = QueueQueue,
		Dequeue = QueueDequeue,
		DequeueBatch = QueueDequeueBatch,
		Length = QueueLength,
	}

	return Queue
end

return DataStructures
