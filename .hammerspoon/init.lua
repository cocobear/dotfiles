-- To use the dev version, download master from git and then run `sh rebuild.sh`
-- following:
-- https://github.com/Hammerspoon/hammerspoon/blob/master/CONTRIBUTING.md#making-frequent-local-rebuilds-more-convenient

-- Preamble {{{

-- Modifier shortcuts
local cmd_ctrl = {"ctrl", "cmd"}
local cmd_shift = {"shift", "cmd"}
local cmd_option = {"ctrl", "option"}

-- Reload (auto) hotkey script
hs.hotkey.bind(cmd_ctrl, "a", function()
  hs.reload()
  hs.alert("Hammerspoon config was reloaded.")
end)

-- Don't perform animations when resizing
hs.window.animationDuration = 0

-- Get list of screens and refresh that list whenever screens are plugged or
-- unplugged i.e initiate watcher
local screens = hs.screen.allScreens()
local screenwatcher = hs.screen.watcher.new(function()
                                                screens = hs.screen.allScreens()
                                            end)
screenwatcher:start()

-- }}}
-- Window handling {{{

-- Resize window for chunk of screen (this deprecates Spectable)
-- For x and y: use 0 to expand fully in that dimension, 0.5 to expand halfway
-- For w and h: use 1 for full, 0.5 for half
function resize_win(x, y, w, h)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w * x)
	f.y = max.y + (max.h * y)
	f.w = max.w * w
	f.h = max.h * h
	win:setFrame(f)
end
hs.hotkey.bind(cmd_shift, "h", function()
                resize_win(0,0,0.5,1) end) -- left
hs.hotkey.bind(cmd_shift, "l", function()
                resize_win(0.5,0,0.5,1) end) -- right
hs.hotkey.bind(cmd_ctrl, "k", function()
                resize_win(0,0,1,0.5) end) -- top
hs.hotkey.bind(cmd_ctrl, "j", function()
                resize_win(0,0.5,1,0.5) end) -- bottom
hs.hotkey.bind(cmd_shift, "k", function()
                resize_win(0,0,1,1) end) -- full
hs.hotkey.bind(cmd_ctrl, "1", function()
                resize_win(0,0,0.5,0.5) end) -- Top left quarter
hs.hotkey.bind(cmd_ctrl, "2", function()
                resize_win(0,0.5,0.5,0.5) end) -- Bottom left quarter
hs.hotkey.bind(cmd_ctrl, "3", function()
                resize_win(0.5,0,0.5,0.5) end) -- Top right quarter
hs.hotkey.bind(cmd_ctrl, "4", function()
                resize_win(0.5,0.5,0.5,0.5) end) -- Bottom right quarter
hs.hotkey.bind(cmd_ctrl, "5", function()
                resize_win(0.25,0.25,0.5,0.5) end) -- Center

-- (Expand) to full screen (we use OSX default Cmd + F to open finder)
hs.hotkey.bind(cmd_ctrl, "e", function()
        local win = hs.window.focusedWindow()
        if win ~= nil then
            win:setFullScreen(not win:isFullScreen())
        end
    end)

-- Change window width (setting the grid first)
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 10
hs.grid.GRIDHEIGHT = 2
hs.hotkey.bind(cmd_ctrl, "-", function()
    hs.grid.resizeWindowThinner(hs.window.focusedWindow())
end)
hs.hotkey.bind(cmd_ctrl, "=", function()
    hs.grid.resizeWindowWider(hs.window.focusedWindow())
end)

-- Expose (show thumbnails of open windows with a hint)
hs.expose.ui.otherSpacesStripWidth = 0  -- I don't use other spaces
hs.expose.ui.highlightThumbnailStrokeWidth = 5
hs.expose.ui.textSize = 30
hs.expose.ui.nonVisibleStripWidth = 0.2
hs.expose.ui.nonVisibleStripBackgroundColor = {0.08, 0.08, 0.08}
expose = hs.expose.new()
hs.hotkey.bind(cmd_ctrl, "e", function() expose:toggleShow() end)

-- Window switcher (deprecates Hyperswitch)
hs.window.switcher.ui.showSelectedThumbnail = false
hs.window.switcher.ui.showTitles = false
hs.window.switcher.ui.textSize = 12
hs.window.switcher.ui.thumbnailSize = 180
hs.window.switcher.ui.backgroundColor = {0.2, 0.2, 0.2, 0.3} -- Greyish
hs.window.switcher.ui.titleBackgroundColor = {0, 0, 0, 0} -- Transparent
hs.window.switcher.ui.textColor = {0, 0, 0} -- Black
-- TODO: Show switcher on active screen
-- TODO: fix text paddling
switcher = hs.window.switcher.new(
                hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{})
hs.hotkey.bind("alt", "tab", function() switcher:next() end)

-- }}}
-- Multiple monitors handling {{{

-- Move window to next/previous monitor (checks to make sure monitor exists, if
-- not moves to last monitor that exists)
function moveToMonitor(x)
	local win = hs.window.focusedWindow()
	local newScreen = nil
	while not newScreen do
		newScreen = screens[x]
		x = x - 1
	end
	win:moveToScreen(newScreen)

    -- Also move the mouse to center of next screen
    local center = hs.geometry.rectMidPoint(newScreen:fullFrame())
    hs.mouse.setAbsolutePosition(center)
end
--  Use new method to move window to another monitor
hs.hotkey.bind(cmd_ctrl,"l", function()
  hs.window.focusedWindow():moveOneScreenEast()
end)
hs.hotkey.bind(cmd_ctrl,"h", function()
  hs.window.focusedWindow():moveOneScreenWest()
end)


-- Switch focus and mouse to the next monitor
function windowInScreen(screen, win) -- Check if a window belongs to a screen
    return win:screen() == screen
end
function focusNextScreen()
    -- Get next screen (and its center point) using current mouse position
    -- local next_screen = hs.window.focusedWindow():screen():next()
    local next_screen = hs.mouse.getCurrentScreen():next()
    local center = hs.geometry.rectMidPoint(next_screen:fullFrame())

    -- Find windows within this next screen, ordered from front to back.
    windows = hs.fnutils.filter(hs.window.orderedWindows(),
                                hs.fnutils.partial(windowInScreen, next_screen))

    -- Move the mouse to the center of the other screen
    hs.mouse.setAbsolutePosition(center)

    --  Set focus on front-most application window or bring focus to desktop if
    --  no windows exists
    if #windows > 0 then
        windows[1]:focus()
    else
        hs.window.desktop():focus()
        -- In this case also do a click to activate menu bar
        hs.eventtap.leftClick(hs.mouse.getAbsolutePosition())
    end
end
hs.hotkey.bind({"alt"}, "§", focusNextScreen)
hs.hotkey.bind({"alt"}, "`", focusNextScreen)

-- }}}
-- Run or activate app {{{

-- hs.hotkey.bind(cmd_ctrl, "i", function()
                -- hs.application.launchOrFocus("Firefox") end)
hs.hotkey.bind(cmd_ctrl, "s", function()
                hs.application.launchOrFocus("Sublime Text") end)
hs.hotkey.bind(cmd_ctrl, "w", function()
                hs.application.launchOrFocus("Microsoft Word") end)
hs.hotkey.bind(cmd_ctrl, "i", function()
                hs.application.launchOrFocus("Google Chrome") end)
hs.hotkey.bind(cmd_ctrl, "g", function()
                hs.application.launchOrFocus("Giphy Capture") end)
hs.hotkey.bind(cmd_ctrl, "t", function()
                hs.application.launchOrFocus("iTerm") end)
hs.hotkey.bind(cmd_ctrl, "d", function()
                hs.execute("open ~/Downloads/") end)

-- }}}
-- Spotify and volume {{{

-- Volume control
hs.hotkey.bind({"cmd", "shift"}, '=', function()
    local audio_output = hs.audiodevice.defaultOutputDevice()
    if audio_output:muted() then
        audio_output:setMuted(false)
    end
    audio_output:setVolume(hs.audiodevice.current().volume + 5)
    hs.alert.closeAll()
    hs.alert.show("Volume level: " ..
                    tostring(math.floor(hs.audiodevice.current().volume)) ..
                    "%")
end)
hs.hotkey.bind({"cmd", "shift"}, '-', function()
    local audio_output = hs.audiodevice.defaultOutputDevice()
    audio_output:setVolume(hs.audiodevice.current().volume - 5)
    hs.alert.closeAll()
    hs.alert.show("Volume level: " ..
                    tostring(math.floor(hs.audiodevice.current().volume)) ..
                    "%")
end)
hs.hotkey.bind({"cmd", "shift"}, 'm', function()
    local audio_output = hs.audiodevice.defaultOutputDevice()
    if audio_output:muted() then
        audio_output:setMuted(false)
    else
        audio_output:setMuted(true)
    end
end)
hs.hotkey.bind({"cmd", "shift"}, 'v', function()
    local audio_output = hs.audiodevice.defaultOutputDevice()
    hs.alert.closeAll()
    hs.alert.show("Volume level: " ..
                    tostring(math.floor(hs.audiodevice.current().volume)) ..
                    "%")
end)

-- }}}
-- Toggle hidden files {{{

hs.hotkey.bind(cmd_option, "h", function()
    hidden_status = hs.execute("defaults read com.apple.finder " ..
                                "AppleShowAllFiles")
    if hidden_status == "YES\n"  then
        hs.execute("defaults write com.apple.finder AppleShowAllFiles NO")
    else
        hs.execute("defaults write com.apple.finder AppleShowAllFiles YES")
    end
    hs.execute("killall Finder")
end)

-- }}}
-- Active window screenshot {{{

hs.hotkey.bind({"shift", "cmd"}, "5", function()
                local image = hs.window.focusedWindow():snapshot()
                local current_date = os.date("%Y-%m-%d")
                local current_time = os.date("%H.%M.%S")
                local screenshot_dir = os.getenv("HOME") ..
                                        "/Pictures/Screenshots/"
                os.execute("mkdir " .. screenshot_dir)
                local filename = screenshot_dir .. "Screen Shot " ..
                                current_date .. " at " .. current_time .. ".png"
                image:saveToFile(filename)
                hs.alert("Screenshot saved as " .. filename)
            end)

-- }}}
-- Miscellaneous {{{

-- Lockscreen
hs.hotkey.bind({"shift", "cmd"}, "l", function()
                hs.caffeinate.lockScreen()
                end)

-- TODO: Remap capslock key to TAB (we already disabled it from System
-- Preferences)

-- Shutdown and restart (with confirmation dialog)
hs.hotkey.bind({"shift", "cmd"}, "s", function()
                os.execute("osascript -e 'tell application \"loginwindow\"" ..
                           "to «event aevtrsdn»'")
                end)
hs.hotkey.bind({"shift", "cmd"}, "r", function()
                os.execute("osascript -e 'tell application \"loginwindow\"" ..
                           "to «event aevtrrst»'")
                end)

-- Open trash folder and empty it (and then reactivate trash window)
hs.hotkey.bind({"cmd"}, "b", function() hs.execute("open ~/.Trash/") end)
hs.hotkey.bind(cmd_ctrl, "b", function() hs.execute("rm -rf ~/.Trash/*")
                                         hs.execute("open ~/.Trash/")
               end)

-- Move the mouse with the keyboard (requires vimouse.lua script)
local vimouse = require('vimouse')
require "modules/hotkey"
require "modules/windows"
vimouse({'shift', 'cmd'}, 'm')

-- }}}
