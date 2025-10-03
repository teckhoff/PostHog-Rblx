--!strict

local Random = Random.new()

local function UUIDv7()
	local timestamp = DateTime.now().UnixTimestampMillis

	local timestampHigh = math.floor(timestamp / 0x10000)
	local timestampLow = timestamp % 0x10000

	local uuidBuffer = buffer.create(16)

	buffer.writeu32(uuidBuffer, 0, timestampHigh)
	buffer.writeu16(uuidBuffer, 4, timestampLow)

	for i = 0, 9 do
		buffer.writeu8(uuidBuffer, 6 + i, Random:NextInteger(0, 255))
	end

	-- Encode Version into byte 6 of the buffer (the 7th byte)
	local byte6 = buffer.readu8(uuidBuffer, 6)
	byte6 = bit32.band(byte6, 0x0F)
	byte6 = bit32.bor(byte6, 0x70)
	buffer.writeu8(uuidBuffer, 6, byte6)

	-- Encode variant into byte 8 of the buffer (the 9th byte)
	local byte8 = buffer.readu8(uuidBuffer, 8)
	byte8 = bit32.band(byte8, 0x3F)
	byte8 = bit32.bor(byte8, 0x80)
	buffer.writeu8(uuidBuffer, 8, byte8)

	local uuidTable = {}

	for i = 0, 15 do
		table.insert(uuidTable, string.format("%02x", buffer.readu8(uuidBuffer, i)))
	end

	local uuid = table.concat(uuidTable)

	return string.format(
		"%s-%s-%s-%s-%s",
		uuid:sub(1, 8),
		uuid:sub(9, 12),
		uuid:sub(13, 16),
		uuid:sub(17, 20),
		uuid:sub(21, 32)
	)
end

return UUIDv7
