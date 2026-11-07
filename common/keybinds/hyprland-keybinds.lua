-- ==========================================
-- Hyprland Keybindings Export (Lua format)
-- (Functional only - independent of theme)
-- ==========================================

local home = os.getenv("HOME")
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local menu = home .. "/.config/rofi/launcher.sh"
local resizeUnit = 20

-- Applications
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(home .. "/.config/rofi/powermenu/type-2/powermenu.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(home .. "/.config/rofi/cheatsheet/cheatsheet.sh"))
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd(home .. "/.config/rofi/calc.sh"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd(home .. "/.config/rofi/calc.sh"))

-- Window Management
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus Navigation
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Window Moving
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Window Resizing
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -resizeUnit, y = 0 }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = resizeUnit, y = 0 }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -resizeUnit }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = resizeUnit }))

-- Transparency Controls
hl.bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd("hyprctl dispatch setprop active opacity 0.8"))
hl.bind(mainMod .. " + bracketright", hl.dsp.exec_cmd("hyprctl dispatch setprop active opacity 1.0"))
hl.bind("CTRL + ALT + backslash", hl.dsp.exec_cmd("hyprctl dispatch setprop active opacity 1.0"))

-- Workspaces: Switch
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.workspace({ id = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.workspace({ id = 10 }))

-- Workspaces: Move to Workspace
for i = 1, 9 do
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.movetoworkspace({ id = i }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.movetoworkspace({ id = 10 }))

-- Workspaces: Special / Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.special({ name = "magic" }))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.movetoworkspace({ special = "magic" }))

-- Hardware / Media Keys
hl.bind("SUPER + space", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/lang-osd.sh"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/volume-osd.sh raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/volume-osd.sh lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/volume-osd.sh mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/volume-osd.sh mic-mute"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/brightness-osd.sh up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/brightness-osd.sh down"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
