-- To use the dev version, download master from git and then run `sh rebuild.sh`
-- following:
-- https://github.com/Hammerspoon/hammerspoon/blob/master/CONTRIBUTING.md#making-frequent-local-rebuilds-more-convenient

hs.loadSpoon("KSheet")

-- Preamble {{{

-- Modifier shortcuts
local cmd_ctrl = {"ctrl", "cmd"}
local cmd_shift = {"shift", "cmd"}
local cmd_option = {"ctrl", "option"}

-- Reload (auto) hotkey script
hs.hotkey.bind(cmd_ctrl, "a", function()
  hs.alert("Hammerspoon config was reloaded.")
  hs.reload()
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
hs.hotkey.bind(cmd_shift, "k", function()
                resize_win(0,0,1,0.5) end) -- top
hs.hotkey.bind(cmd_shift, "j", function()
                resize_win(0,0.5,1,0.5) end) -- bottom

hs.hotkey.bind(cmd_shift, "return", function()
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
-- hs.expose.ui.otherSpacesStripWidth = 0  -- I don't use other spaces
-- hs.expose.ui.highlightThumbnailStrokeWidth = 0
hs.expose.ui.backgroundColor = {0, 0, 0, 0.1}
hs.expose.ui.highlightThumbnailStrokeWidth = 0
hs.expose.ui.showTitles = false
-- hs.expose.ui.textSize = 30
hs.expose.ui.nonVisibleStripWidth = 0
hs.expose.ui.otherSpacesStripWidth = 0
expose = hs.expose.new()
-- show desktop then show fake mission control
hs.hotkey.bind(cmd_ctrl, "e", function()
    hs.eventtap.keyStroke("fn", "F11")
    expose:toggleShow()
end)

-- Window switcher (deprecates Hyperswitch)
hs.window.switcher.ui.showSelectedThumbnail = false
hs.window.switcher.ui.showTitles = false
hs.window.switcher.ui.textSize = 12
hs.window.switcher.ui.thumbnailSize = 280
hs.window.switcher.ui.backgroundColor = {0.2, 0.2, 0.2, 0.3} -- Greyish
hs.window.switcher.ui.titleBackgroundColor = {0, 0, 0, 0} -- Transparent
hs.window.switcher.ui.textColor = {0, 0, 0} -- Black
-- TODO: Show switcher on active screen
-- TODO: fix text paddling
switcher = hs.window.switcher.new(
                hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{})
hs.hotkey.bind("alt", "tab", function() switcher:next() end)

switcher = hs.window.switcher.new(
    hs.window.filter.new()
        :setAppFilter('Emacs', {allowRoles = '*', allowTitles = 1}), -- make emacs window show in switcher list
    {
        showTitles = false,               -- don't show window title
        thumbnailSize = 300,              -- window thumbnail size
        showSelectedThumbnail = false,    -- don't show bigger thumbnail
        backgroundColor = {0.2, 0.2, 0.2, 0.3}, -- Greyish
        highlightColor = {0.3, 0.3, 0.3, 0.8}, -- selected color
    }
    )
    hs.hotkey.bind("option", "tab", function()
		   switcher:next()
       end)
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

-- Key to launch application.
local key2App = {
    t = {'/Applications/iTerm.app', 'English'},
    c = {'/Applications/Google Chrome.app', 'English'},
    f = {'/System/Library/CoreServices/Finder.app', 'English'},
    w = {'/Applications/WeChat.app', 'Chinese'},
    s = {'/Applications/System Preferences.app', 'English'},
    d = {'/Applications/Dash.app', 'English'},
    p = {'/Applications/PyCharm.app', 'English'},
    v = {'/Applications/Visual Studio Code.app', 'English'},
    q = {'/Applications/QQ.app', 'Chinese'},
    m = {'/Applications/Typora.app', 'Chinese'}
}
-- Show launch application's keystroke.
local showAppKeystrokeAlertId = ""

local function showAppKeystroke()
    if showAppKeystrokeAlertId == "" then
        -- Show application keystroke if alert id is empty.
        local keystroke = ""
        local keystrokeString = ""
        for key, app in pairs(key2App) do
            keystrokeString = string.format("%-10s%s", key:upper(), app[1]:match("^.+/(.+)$"):gsub(".app", ""))

            if keystroke == "" then
                keystroke = keystrokeString
            else
                keystroke = keystroke .. "\n" .. keystrokeString
            end
        end

        showAppKeystrokeAlertId = hs.alert.show(keystroke, hs.alert.defaultStyle, hs.screen.mainScreen(), 10)
    else
        -- Otherwise hide keystroke alert.
        hs.alert.closeSpecific(showAppKeystrokeAlertId)
        showAppKeystrokeAlertId = ""
    end
end

hs.hotkey.bind(cmd_ctrl, "z", showAppKeystroke)
function launchApp(app)

    local appPath = app[1]
    -- We need use Chrome's remote debug protocol that debug JavaScript code in Emacs.
    -- So we need launch chrome with --remote-debugging-port argument instead application.launchOrFocus.
    if appPath == "/Applications/Google Chrome.app" then
        hs.execute("open -a 'Google Chrome' --args '--remote-debugging-port=9222'")
    else
        hs.application.launchOrFocus(appPath)
    end
end
local mouseCircle = nil
local mouseCircleTimer = nil

-- Start or focus application.
for key, app in pairs(key2App) do
    hs.hotkey.bind(
        cmd_ctrl, key,
        function()
            launchApp(app)
    end)
end

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

-- Show application keystroke window.
local ksheetIsShow = false
local ksheetAppPath = ""

hs.hotkey.bind(
    cmd_ctrl, "R",
    function ()
        local currentAppPath = hs.window.focusedWindow():application():path()

        -- Toggle ksheet window if cache path equal current app path.
        if ksheetAppPath == currentAppPath then
            if ksheetIsShow then
                spoon.KSheet:hide()
                ksheetIsShow = false
            else
                spoon.KSheet:show()
                ksheetIsShow = true
            end
            -- Show app's keystroke if cache path not equal current app path.
        else
            spoon.KSheet:show()
            ksheetIsShow = true

            ksheetAppPath = currentAppPath
        end
    end)

-- Lockscreen
hs.hotkey.bind({"ctrl","shift", "cmd"}, "l", function()
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
-- show inputmethod {{{

local function Chinese()
    hs.keycodes.currentSourceID("im.rime.inputmethod.Squirrel.Rime")
end

local function English()
    hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
end


function updateFocusAppInputMethod(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        local default = true
        for index, app in pairs(key2App) do
            if app[1] == appObject:path() then
                default = false
                if app[2] == 'Chinese' then
                    Chinese()
                else
                    English()
                end
            end
        end
        if default then
            English()
        end
    end
    showInputMethod()
end

appWatcher = hs.application.watcher.new(updateFocusAppInputMethod)
appWatcher:start()

  hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(event)
      -- print(event:getKeyCode())
      -- print(hs.inspect.inspect(event:getFlags()))

     if event:getKeyCode() == 49  and event:getFlags().ctrl then
         showInputMethod(true)
     end
   end):start()

function showInputMethod(reverse)
   -- 用于保存当前输入法
    local currentSourceID = hs.keycodes.currentSourceID()
    local tag
    print(currentSourceID)
    hs.alert.closeSpecific(showUUID)

    if (currentSourceID == "com.apple.keylayout.ABC") then
        if reverse then
            tag = '中'
        else
            tag = 'A'
        end
    else
        if reverse then
            tag = 'A'
        else
            tag = '中'
        end
    end
    showUUID = hs.alert.show(tag, screens)
end

-- hs.keycodes.inputSourceChanged(function ()
--     print('changed!')
--     showInputMethod()
-- end)
-- }}}
