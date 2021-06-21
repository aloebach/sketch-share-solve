local gfx <const> = playdate.graphics

class("SelectLevelSidebar").extends(Sidebar)

function SelectLevelSidebar:init()
	SelectLevelSidebar.super.init(self)
end

function SelectLevelSidebar:enter(context)
	local player = context.player
	local creator = context.creator
	local menuItems = {}
	for i, id in pairs(creator.created) do
		local level = context.save.levels[id]
		assert(level)
		local revealed = creator.id == player.id or player.played[level.id]
		local text = revealed and level.title or "Level " .. i

		local image = nil
		if revealed then
			image = gfx.image.new(16, 16, gfx.kColorBlack)
			gfx.lockFocus(image)
			do
				gfx.setColor(gfx.kColorWhite)
				for y = 1, LEVEL_HEIGHT do
					for x = 1, LEVEL_WIDTH do
						local index = x - 1 + (y - 1) * 15 + 1
						if level.grid[index] == 0 then
							gfx.fillRect(x - 1, y + 1, 1, 1)
						end
					end
				end
			end
			gfx.unlockFocus()
		end

		table.insert(menuItems, {
			text = text,
			ref = level,
			img = image
		})
	end

	local config = {
		menuItems = menuItems,
		menuTitle = "Choose level"
	}

	SelectLevelSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked(),
		context.player.avatar,
		context.creator.avatar
	)
end