class("SelectPlayerSidebar").extends(Sidebar)

function SelectPlayerSidebar:init()
	SelectPlayerSidebar.super.init(self)

	self.onNewPlayer = function () end
end

function SelectPlayerSidebar:enter(context)
	local config = {
		menuItems = {},
		menuTitle = "Who is playing?"
	}

	local player = nil
	for _, id in pairs(context.save.profileList) do
		local profile = Player.load(context, id)
		if not profile.hidden then
			if not player then
				player = profile
			end
			table.insert(config.menuItems, {
				text = profile.name,
				avatar = profile.avatar,
				ref = profile
			})
		end
	end

	table.insert(config.menuItems, {
		text = "New player",
		avatar = imgAvatars:getImage(AVATAR_ID_NIL),
		exec = function()
			self.onNewPlayer()
		end
	})

	local avatar = config.menuItems[1].avatar
	SelectPlayerSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked() and avatar or nil
	)
end

function SelectPlayerSidebar:onCranked()
	self.playerAvatar:change(self.cursorRaw)
end

function SelectPlayerSidebar:onNavigated_(player, i)
	self:redraw()
end

function SelectPlayerSidebar:open()
	SelectPlayerSidebar.super.open(self)
	self:onNavigated_(self.menuItems[self.cursor].ref)
end
