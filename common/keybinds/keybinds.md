# Hyprland Keybindings Export

> **Main Modifier**: `SUPER` (Windows key)

## Applications & System
| Keybinding | Action | Command / Target |
| :--- | :--- | :--- |
| `SUPER + Q` | Open Terminal | `kitty` |
| `SUPER + E` | Open File Manager | `dolphin` |
| `SUPER + R` | Application Launcher | `~/.config/rofi/launcher.sh` |
| `SUPER + K` | Keybindings Cheatsheet | `~/.config/rofi/cheatsheet/cheatsheet.sh` |
| `SUPER + =` / `Calculator` | Quick Calculator Bar | `~/.config/rofi/calc.sh` (`rofi -show qalc`) |
| `SUPER + M` | System Power Menu | `~/.config/rofi/powermenu/type-2/powermenu.sh` |
| `SUPER + B` | Toggle Topbar (Hide/Unhide) | `killall -SIGUSR1 waybar` |
| `SUPER + Space` | Switch Keyboard Layout (OSD) | `~/.config/waybar/scripts/lang-osd.sh` |

## Window Management
| Keybinding | Action | Dispatcher |
| :--- | :--- | :--- |
| `SUPER + C` | Close Focused Window | `killactive` |
| `SUPER + T` | Toggle Floating (Single Window) | `togglefloating` |
| `SUPER + V` | Toggle Floating (All on Workspace) | Custom Lua function |
| `SUPER + F` | Toggle Fullscreen (Maximized) | `fullscreen 1` |
| `SUPER + P` | Toggle Pseudo Tiling | `pseudo` |
| `SUPER + J` | Toggle Split Direction (Dwindle) | `togglesplit` |
| `SUPER + Left / Right / Up / Down` | Focus Window by Direction | `movefocus, <dir>` |
| `SUPER + Shift + Left / Right / Up / Down` | Resize Window (Hold to repeat) | `resizeactive, +/-20px` |
| `SUPER + Left Mouse Drag` | Move Floating Window | Mouse drag |
| `SUPER + Right Mouse Drag` | Resize Floating Window | Mouse resize |

## Workspaces
| Keybinding | Action |
| :--- | :--- |
| `SUPER + 1 .. 9` | Switch to Workspace 1 through 9 |
| `SUPER + Shift + 1 .. 9` | Move Focused Window to Workspace 1 through 9 |
| `SUPER + S` | Toggle Scratchpad / Special Workspace (`magic`) |
| `SUPER + Shift + S` | Move Focused Window to Scratchpad |
| `SUPER + Mouse Scroll Up / Down` | Switch to Next / Previous Workspace |

## Custom Opacity & Transparency
| Keybinding | Action |
| :--- | :--- |
| `Ctrl + Alt + Up` | Increase Opacity (+5% Solid, Hold to repeat) |
| `Ctrl + Alt + Down` | Decrease Opacity (+5% Glass, Hold to repeat) |
| `Ctrl + Alt + Enter` | Reset Focused Window Opacity to 100% |
| `Ctrl + Alt + \` | Reset All Windows Opacity to 100% |

## Screenshots & Media
| Keybinding | Action | Command |
| :--- | :--- | :--- |
| `Print` | Screenshot Area to Clipboard | `grim -g "$(slurp)" - \| wl-copy` |
| `Shift + Print` | Screenshot Area to Editor | `grim -g "$(slurp)" - \| swappy -f -` |
| `XF86AudioRaiseVolume` | Volume Up (+5% with OSD) | `~/.config/waybar/scripts/volume-osd.sh raise` |
| `XF86AudioLowerVolume` | Volume Down (-5% with OSD) | `~/.config/waybar/scripts/volume-osd.sh lower` |
| `XF86AudioMute` | Mute Audio Sink | `~/.config/waybar/scripts/volume-osd.sh mute` |
| `XF86AudioMicMute` | Mute Microphone | `~/.config/waybar/scripts/volume-osd.sh mic-mute` |
| `XF86MonBrightnessUp` | Brightness Up (+5% with OSD) | `~/.config/waybar/scripts/brightness-osd.sh up` |
| `XF86MonBrightnessDown` | Brightness Down (-5% with OSD) | `~/.config/waybar/scripts/brightness-osd.sh down` |
| `XF86AudioPlay` / `Pause` | Media Play / Pause | `playerctl play-pause` |
| `XF86AudioNext` / `Prev` | Media Next / Previous | `playerctl next` / `previous` |
