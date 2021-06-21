local gfx <const> = playdate.graphics

class("Cursor").extends(gfx.sprite)

function Cursor:init()
	Cursor.super.init(self)

	self.image = gfx.image.new(CELL + 5, CELL + 5, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(20)

	gfx.pushContext(self.image)
	do
		gfx.clear(gfx.kColorClear)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, CELL + 5, CELL + 5)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(1, 1, CELL + 3, CELL + 3, 3)
		gfx.setColor(gfx.kColorClear)
		gfx.fillRoundRect(3, 3, CELL - 1, CELL - 1, 2)
	end
	gfx.popContext()
end

function Cursor:enter(level)
	self.gridX = 8
	self.gridY = 4
	self:moveTo(
		CELL * (BOARD_OFFSET_X - 1 + self.gridX) - 2,
		CELL * (BOARD_OFFSET_Y - 1 + self.gridY) - 2
	)
	self.level = level
	self:redraw()
	self:add()
end

function Cursor:leave()
	self:remove()
end

function Cursor:getIndex()
	return self.gridX - 1 + (self.gridY - 1) * LEVEL_WIDTH + 1
end

function Cursor:moveBy(dx, dy)
	self.gridX = (self.gridX + dx + LEVEL_WIDTH - 1) % LEVEL_WIDTH + 1
	self.gridY = (self.gridY + dy + LEVEL_HEIGHT - 1) % LEVEL_HEIGHT + 1
	self:redraw()
end

function Cursor:redraw()
	self:moveTo(
		CELL * (BOARD_OFFSET_X - 1 + self.gridX) - 2,
		CELL * (BOARD_OFFSET_Y - 1 + self.gridY) - 2
	)
end