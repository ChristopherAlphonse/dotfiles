
local wezterm = require("wezterm")
local config = wezterm.config_builder()


config.font = wezterm.font("BlexMono Nerd Font Mono")
config.font_size = 16
config.color_scheme = "tokyonight_night"
config.colors={
    cursor_bg="#7aa2f7",
    cursor_border="#7aa2f7",
}
config.default_cursor_style = "BlinkingBar"
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
config.macos_window_background_blur = 10
-- config.default_prog = { "pwsh" }



config.keys = {
  {
    key = "w",
    mods = "CMD",
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  {
    key = "\\",
    mods = "CMD",
    action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
  }, {
    key = "\\",
    mods = "CMD | SHIFT",
    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
  },
  {
    key = "[",
    mods = "CMD",
    action = wezterm.action.ActivatePaneDirection "Left",
  },
  {
    key = "]",
    mods = "CMD",
    action = wezterm.action.ActivatePaneDirection "Right",
  },
}



return config
