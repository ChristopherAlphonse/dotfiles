local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.font = wezterm.font("BlexMono Nerd Font Mono")
config.font_size = 16
config.color_scheme = 'Catppuccin Mocha'
config.colors={
  cursor_bg="#7aa2f7",
  cursor_border="#7aa2f7",
}
config.default_cursor_style = "BlinkingBar"
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 30
-- config.default_prog = { "pwsh" }

config.keys = {
  {
    key = "w",
    mods = "CMD",
    action = act.CloseCurrentPane { confirm = false },
  },
  {
    key = "\\",
    mods = "CMD",
    action = act.SplitHorizontal { domain = "CurrentPaneDomain" },
  },
  {
    key = "\\",
    mods = "CMD | SHIFT",
    action = act.SplitVertical { domain = "CurrentPaneDomain" },
  },
  {
    key = "[",
    mods = "CMD",
    action = act.ActivatePaneDirection "Left",
  },
  {
    key = "]",
    mods = "CMD",
    action = act.ActivatePaneDirection "Right",
  },
  {
    key = 't',
    mods = 'CMD',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
}

return config
