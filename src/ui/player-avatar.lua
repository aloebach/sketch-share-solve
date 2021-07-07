local gfx <const> = playdate.graphics

class("Avatar").extends(gfx.sprite)

function Avatar:init()
	Avatar.super.init(self)

	self.text = "Player"
	self.image = gfx.image.new(SIDEBAR_WIDTH + 1, 27, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_AVATAR)

end

function Avatar:enter(config, avatar)
	self.menuItems = config.menuItems
	self.avatar = avatar
	self.idleCounter = 0
	self.position = 1
	self.slide = nil

	self:setVisible(not not avatar)
	if avatar then
		self:draw(avatar)
	end

	self:add()
end

function Avatar:leave()
	self:remove()
end

function Avatar:change(position)
	self.idleCounter = 0
	self.animator = nil

	self:setPosition(position)
end

function Avatar:setPosition(position)
	self.position = position
	self.target = math.floor(position + 0.5)

	self:initSlide()

	self.image:clear(gfx.kColorClear)
	gfx.pushContext(self.image)
	do
		drawRightTextRect(-1, 0, SIDEBAR_WIDTH - 23, 26, self.text)
		gfx.setDrawOffset(AVATAR_OFFSET, 0)
		gfx.setClipRect(0, 0, 26, 26)
		self.slide:draw(3, 3 - math.floor((position - 1) * 23 + 0.5))

		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0, 0, 26, 26)
		gfx.drawRect(2, 2, 22, 22)
		gfx.setColor(gfx.kColorWhite)
		gfx.drawRect(1, 1, 24, 24)
	end
	gfx.popContext()
	self:markDirty()
end

function Avatar:setTarget(position)
	self.target = position
	self.animator = nil
	self.idleCounter = 5

	self:initSlide()
end

function Avatar:draw(avatar)
	self.image:clear(gfx.kColorClear)
	gfx.pushContext(self.image)
	do
		gfx.setColor(gfx.kColorWhite)
		gfx.drawLine(0, 26, SIDEBAR_WIDTH - SEPARATOR_WIDTH - 1, 26)
		gfx.drawLine(SIDEBAR_WIDTH - SEPARATOR_WIDTH + 1, 26, SIDEBAR_WIDTH, 26)
		drawRightTextRect(-1, 0, SIDEBAR_WIDTH - 23, 26, self.text)
		gfx.setDrawOffset(AVATAR_OFFSET, 0)
		avatar:drawScaled(3, 3, 2)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0, 0, 26, 26)
		gfx.drawRect(2, 2, 22, 22)
		gfx.setColor(gfx.kColorWhite)
		gfx.drawRect(1, 1, 24, 24)
	end
	gfx.popContext()
	self:markDirty()
end

function Avatar:initSlide()
	if not self.slide then
		self.slide = gfx.image.new(20, 23 * #self.menuItems, gfx.kColorClear)
		gfx.lockFocus(self.slide)
		for i, item in pairs(self.menuItems) do
			if item.avatar == self.avatar then
				self.position = i
			end
			item.avatar:drawScaled(0, (i - 1) * 23, 2)
			gfx.setColor(gfx.kColorBlack)
			gfx.drawRect(0, (i - 1) * 23 + 20, 20, 3)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawLine(0, (i - 1) * 23 + 21, 20, (i - 1) * 23 + 21)
		end
		gfx.unlockFocus()
	end
end

function Avatar:update()
	if self.slide and self.position ~= self.target then
		self.idleCounter += 1
		if self.animator then
			self:setPosition(self.animator:currentValue())
			if self.animator:ended() then
				self.animator = nil
			end
		elseif self.idleCounter >= 5 then
			self.animator = gfx.animator.new(
				200,
				self.position,
				self.target,
				playdate.easingFunctions.inOutSine
			)
		end
	end
end
