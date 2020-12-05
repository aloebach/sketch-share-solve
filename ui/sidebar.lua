local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self)
	self.opened = false

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(30)
end

function Sidebar:enter(level)
	self:add()
	self:redraw()
end

function Sidebar:leave()
	self:remove()
end

function Sidebar:open()
	self.opened = true
	self:redraw()
end

function Sidebar:close()
	self.opened = false
	self:redraw()
end

function Sidebar:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontText)
		self.width = self.opened and 200 or 120
		-- black border
		gfx.setColor(gfx.kColorBlack)
		gfx.drawLine(self.width, 0, self.width, 240)
		-- white outline
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, self.width, 240)
		-- dithered background
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.5)
		gfx.fillRect(
			self.opened and 1 or self.width - 23, 1,
			self.opened and self.width - 2 or 22, 240 - 2
		)

		self:drawAvatar(1, "Playing", 0)
		self:drawAvatar(3, "Created by", 240 - 24)
	end
	gfx.unlockFocus()
	self:markDirty()
	self:moveTo(self.opened and 0 or -120 + 24, 0)
end

function Sidebar:drawAvatar(id, text, y)
	local x = self.width - 24
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, y - 2, self.width, 28)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, y - 1, self.width, 26)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, y, self.width - 25, 24)
	gfx.fillRect(x, y, 24, 24)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(x + 1, y + 1, 22, 22)
	imgAvatars:getImage(id):drawScaled(x + 2, y + 2, 2)
	gfx.drawText(text, 6, y + 5)
end