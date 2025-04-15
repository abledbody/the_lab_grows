local m_screens = require"src/screens"

--- Sets the current active screen.
--- @param self ScreenManager The screen manager to set the screen for.
--- @param screen Screen The screen to set as the current screen.
local function set_screen(self,screen)
	self.screen = screen
	self.screen:init()
end

--- Initializes a new screen manager.
--- @param screen_data table<string,ScreenData> The data for the screens available to the manager.
--- @param initial_screen_key string The key of the initial screen to set.
--- @return ScreenManager screen_manager The new screen manager.
local function init(screen_data,initial_screen_key)
	local screens = m_screens.import(screen_data)
	local initial_screen = screens[initial_screen_key]
	assert(initial_screen,"Cannot initialize screen manager with invalid screen key: "..initial_screen_key)

	--- @class ScreenManager
	--- @field screens table<string,Screen> All the screens in the game.
	--- @field screen Screen The current screen.
	local screen_manager = {
		screens = screens,
		screen = initial_screen,
		set_screen = set_screen,
	}

	screen_manager:set_screen(initial_screen)

	return screen_manager
end

return {
	init = init,
}