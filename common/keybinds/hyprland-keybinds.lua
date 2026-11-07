-- ==========================================
-- Hyprland Keybindings Export (Lua format)
-- (Functional only - independent of theme)
-- ==========================================

local home = os.getenv("HOME")
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "dolphin"
local menu = home .. "/.config/rofi/launcher.sh"
local resizeUnit = 30

-- Applications & Launchers
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(home .. "/.config/rofi/cheatsheet/cheatsheet.sh"))
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd(home .. "/.config/rofi/calc.sh"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd(home .. "/.config/rofi/calc.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(home .. "/.config/rofi/powermenu/type-2/powermenu.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind("SUPER + space", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/lang-osd.sh"))

-- Window Management
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Focus Navigation (Super + Arrow Keys)
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Window Resizing (Super + Shift + Arrow Keys - hold to repeat)
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = resizeUnit, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -resizeUnit, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -resizeUnit, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = resizeUnit, relative = true }), { repeating = true })

-- Mouse Drag & Resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces: Switch (Super + 1-9, 0)
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspaces: Special / Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Workspaces: Mouse Scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))

-- Hardware / Media Keys
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
