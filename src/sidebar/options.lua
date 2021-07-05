class("OptionsSidebar").extends(Sidebar)

function OptionsSidebar:init()
	OptionsSidebar.super.init(self)
end

function OptionsSidebar:enter(context)
	local hintsText = "Hints: " .. (
		context.player.options.hintsDisabled and "off" or "on"
	)
	local config = {
		player = context.player.avatar,
		menuItems = {
			{
				text = hintsText,
				exec = function ()
					self.onToggleHints()
				end
			},
			{
				text = "Reset progress",
				exec = function ()
					self.onResetProgress()
				end
			},
			{
				text = "Rename profile",
				exec = function ()
					self.onRename()
				end
			},
			{
				text = "Delete profile",
				exec = function ()
					self.onDelete()
				end
			},
		}
	}

	OptionsSidebar.super.enter(
		self,
		context,
		config
	)
end