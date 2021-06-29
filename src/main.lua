import "CoreLibs/animation"
import "CoreLibs/graphics"
import "CoreLibs/keyboard"
import "CoreLibs/nineslice"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/string"
import "CoreLibs/timer"
import "CoreLibs/ui/crankIndicator"

import "constants"
import "input"
import "levels"
import "utils"

import "model/done-numbers"
import "model/done-numbers-disabled"
import "model/level"
import "model/numbers"
import "model/player"

import "screen/screen"
import "screen/avatar-create"
import "screen/grid-create"
import "screen/grid-play"
import "screen/grid-solved"
import "screen/title"

import "sidebar/sidebar"
import "sidebar/create-avatar"
import "sidebar/create-grid"
import "sidebar/options"
import "sidebar/select-avatar"
import "sidebar/select-creator"
import "sidebar/select-level"
import "sidebar/select-mode"
import "sidebar/select-player"
import "sidebar/test-grid"

import "ui/avatar"
import "ui/board"
import "ui/board-numbers"
import "ui/cursor"
import "ui/dialog"
import "ui/list"
import "ui/text-cursor"
import "ui/title"

import "utils/numbers"
import "utils/ui"

local gfx <const> = playdate.graphics

fontGrid = gfx.font.newFamily({
	[playdate.graphics.font.kVariantNormal] = "font/grid",
	[playdate.graphics.font.kVariantBold] = "font/grid-bold"
})
assert(fontGrid)

fontText = gfx.font.new("font/text")
assert(fontText)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)
imgBoard, err = gfx.imagetable.new("img/board")
assert(imgBoard, err)
imgDialog = gfx.nineSlice.new("img/dialog", 19, 9, 2, 2)

-- screens
local avatarCreate = AvatarCreate()
local gridCreate = GridCreate()
local gridPlay = GridPlay()
local gridSolved = GridSolved()
local title = TitleScreen()

-- sidebars
local createAvatarSidebar = CreateAvatarSidebar()
local createGridSidebar = CreateGridSidebar()
local testGridSidebar = TestGridSidebar()
local optionsSidebar = OptionsSidebar()
local selectAvatarSidebar = SelectAvatarSidebar()
local selectCreatorSidebar = SelectCreatorSidebar()
local selectLevelSidebar = SelectLevelSidebar()
local selectPlayerSidebar = SelectPlayerSidebar()
local selectModeSidebar = SelectModeSidebar()

local context = {
	creator = nil,
	level = nil,
	player = nil,
	mode = nil,
	save = nil,
	screen = title
}

local sidebar = selectPlayerSidebar

function showPlayerKeyboard(mode)
	playdate.keyboard.canDismiss = function ()
		return true
	end

	local invalid = mode == PLAYER_ID_SHOW_NAME

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switchToSidebar(mode == PLAYER_ID_SHOW_RENAME and optionsSidebar or selectPlayerSidebar)
		else
			context.player:save(context)

			switchToSidebar(mode == PLAYER_ID_SHOW_RENAME and optionsSidebar or selectModeSidebar)
		end
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_LEVEL_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.player.name = text
			switchToSidebar(selectPlayerSidebar, mode)
		else
			playdate.keyboard.text = context.player.name
		end
	end

	playdate.keyboard.show(context.player.name)
end

function showLevelKeyboard()
	playdate.keyboard.canDismiss = function ()
		return true
	end

	local invalid = true

	playdate.keyboard.keyboardWillHideCallback = function ()
		if invalid then
			switchToScreen(gridSolved)
			switchToSidebar(testGridSidebar)
		else
			context.level:save(context)

			switchToScreen(title)
			switchToSidebar(selectModeSidebar)
		end
	end

	playdate.keyboard.textChangedCallback = function ()
		local text = playdate.keyboard.text
		gfx.setFont(fontText)
		local size = gfx.getTextSize(text)
		if size <= MAX_LEVEL_NAME_SIZE then
			invalid = rawlen(playdate.string.trimWhitespace(text)) == 0
			context.level.title = text
			switchToSidebar(selectLevelSidebar, LEVEL_ID_SHOW_NAME)
		else
			playdate.keyboard.text = context.level.title
		end
	end

	playdate.keyboard.show()
end

function switchToScreen(newScreen)
	context.screen:leave()
	context.screen = newScreen
	context.screen:enter(context)
end

function switchToSidebar(newSidebar, selected)
	sidebar:leave()
	sidebar = newSidebar
	sidebar:enter(context, selected)
end

avatarCreate.onChanged = function()
	switchToSidebar(createAvatarSidebar)
end

gridCreate.onChanged = function ()
	context.level.hasBeenSolved = false
	switchToSidebar(createGridSidebar)
end

gridPlay.onPlayed = function ()
	switchToScreen(gridSolved)
	if context.mode == MODE_CREATE then
		switchToSidebar(testGridSidebar)
	else
		context.player.played[context.level.id] = true
		context.player:save(context)

		switchToSidebar(selectLevelSidebar, context.level.id)
	end
end

createAvatarSidebar.onAbort = function ()
	switchToScreen(title)
	switchToSidebar(selectAvatarSidebar)
end

createAvatarSidebar.onSave = function()
	context.player.avatar = createAvatarPreview(context.level)

	switchToScreen(title)
	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_NAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
end

createGridSidebar.onAbort = function()
	switchToScreen(title)
	switchToSidebar(selectModeSidebar)
end

createGridSidebar.onTestAndSave = function ()
	switchToScreen(gridPlay)
	switchToSidebar(testGridSidebar)
end

optionsSidebar.onAbort = function ()
	switchToSidebar(selectModeSidebar)
end

optionsSidebar.onRename = function ()
	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_RENAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_RENAME)
end

optionsSidebar.onToggleHints = function ()
	context.player.options.hintsDisabled = not context.player.options.hintsDisabled
	context.player:save(context)
	switchToSidebar(optionsSidebar)
end

selectAvatarSidebar.onAbort = function()
	switchToSidebar(selectPlayerSidebar)
end

selectAvatarSidebar.onNewAvatar = function ()
	switchToScreen(avatarCreate)
	switchToSidebar(createAvatarSidebar)
end

selectAvatarSidebar.onSelected = function(avatar)
	local player = context.player
	player.avatar = imgAvatars:getImage(avatar)

	switchToSidebar(selectPlayerSidebar, PLAYER_ID_SHOW_NAME)
	showPlayerKeyboard(PLAYER_ID_SHOW_NAME)
end

selectCreatorSidebar.onAbort = function()
	switchToSidebar(selectModeSidebar)
end

selectCreatorSidebar.onSelected = function(creator)
	context.creator = creator
	switchToSidebar(selectLevelSidebar)
end

selectLevelSidebar.onAbort = function()
	switchToScreen(title)
	switchToSidebar(selectCreatorSidebar, context.creator.id)
end

selectLevelSidebar.onSelected = function (level)
	context.level = Level(level)
	switchToScreen(gridPlay)
end

selectModeSidebar.onAbort = function()
	switchToSidebar(selectPlayerSidebar, context.player.id)
end

selectModeSidebar.onSelected = function(selectedMode)
	context.mode = selectedMode
	if context.mode == MODE_PLAY then
		switchToSidebar(selectCreatorSidebar)
	elseif context.mode == MODE_CREATE then
		context.level = Level.createEmpty()
		switchToScreen(gridCreate)
		switchToSidebar(createGridSidebar)
	else
		switchToSidebar(optionsSidebar)
	end
end

selectPlayerSidebar.onNewPlayer = function()
	context.player = Player.createEmpty()

	switchToSidebar(selectAvatarSidebar)
end

selectPlayerSidebar.onSelected = function(player)
	context.player = player

	switchToSidebar(selectModeSidebar)
end

testGridSidebar.onAbort = function ()
	switchToScreen(gridCreate)
	switchToSidebar(createGridSidebar)
end

testGridSidebar.onSave = function ()
	context.level.title = ""
	switchToSidebar(selectLevelSidebar, LEVEL_ID_SHOW_NAME)
	showLevelKeyboard()
end

function playdate.crankDocked()
	sidebar:close()
end

function playdate.crankUndocked()
	sidebar:open()
end

function playdate.cranked(change, acceleratedChange)
	sidebar:cranked(-change, -acceleratedChange)
end

function playdate.downButtonDown()
	if not playdate.isCrankDocked() then
		sidebar:downButtonDown()
	end
end

function playdate.upButtonDown()
	if not playdate.isCrankDocked() then
		sidebar:upButtonDown()
	end
end

function playdate.AButtonDown()
	if playdate.isCrankDocked() then
		context.screen:AButtonDown()
	else
		sidebar:AButtonDown()
	end
end

function playdate.BButtonDown()
	if playdate.isCrankDocked() then
		context.screen:BButtonDown()
	else
		sidebar:BButtonDown()
	end
end

math.randomseed(playdate.getSecondsSinceEpoch())

--playdate.datastore.write(DEFAULT_SAVE)
context.save = playdate.datastore.read() or DEFAULT_SAVE

playdate.ui.crankIndicator:start()
context.screen:enter(context)
sidebar:enter(context)

function playdate.update()
	context.screen:update()

	gfx.sprite.update()
	if context.screen.showCrank and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:update()
	end
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
