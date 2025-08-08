local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Appearance
config.front_end = "OpenGL"
config.max_fps = 60
config.animation_fps = 1
config.cursor_blink_rate = 500
config.default_cursor_style = "BlinkingBar"
config.window_background_opacity = 0.5
config.prefer_egl = true
config.window_decorations = "NONE | RESIZE"
config.window_padding = {
  left = 50,
  right = 10,
  top = 30,
  bottom = 10,
}

-- Font
config.font = wezterm.font("MesloLGL Nerd Font Mono")
config.font_size = 16
config.cell_width = 0.9

-- Terminal behavior
config.term = "xterm-256color"
-- config.default_prog = { "zsh ", "-NoLogo" }
config.initial_cols = 80

-- Color scheme
config.color_scheme = "Cloud (terminal.sexy)"
config.colors = {
  background = "#0c0b0f",
  foreground = "#f8f2f5",  -- Main font color (light grayish-white)

  -- Cursor colors
  cursor_bg = "#bea3c7",
  cursor_border = "#bea3c7",
  cursor_fg = "#0c0b0f",  -- Text color under cursor

  -- Text selection colors
  selection_bg = "#bea3c7",
  selection_fg = "#0c0b0f",

  -- ANSI color palette for terminal colors
  ansi = {
    "#1e1e1e",  -- black
    "#cf6679",  -- red
    "#c3e88d",  -- green
    "#ffcb6b",  -- yellow
    "#82aaff",  -- blue
    "#c792ea",  -- magenta/purple
    "#89ddff",  -- cyan
    "#d0d0d0",  -- white
  },
  brights = {
    "#5c5c5c",  -- bright black (gray)
    "#ff5370",  -- bright red
    "#c3e88d",  -- bright green
    "#ffcb6b",  -- bright yellow
    "#82aaff",  -- bright blue
    "#c792ea",  -- bright magenta
    "#89ddff",  -- bright cyan
    "#ffffff",  -- bright white
  },

  tab_bar = {
    background = "#0c0b0f",
    active_tab = {
      bg_color = "#0c0b0f",
      fg_color = "#bea3c7",
      intensity = "Normal",
      underline = "None",
      italic = false,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = "#0c0b0f",
      fg_color = "#f8f2f5",
      intensity = "Normal",
      underline = "None",
      italic = false,
      strikethrough = false,
    },
    new_tab = {
      bg_color = "#0c0b0f",
      fg_color = "white",
    },
  },
}

-- Window frame
config.window_frame = {
  font = wezterm.font({ family = "Iosevka Custom", weight = "Regular" }),
  active_titlebar_bg = "#47FF9C",
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Dynamic color scheme toggle
wezterm.on("toggle-colorscheme", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme == "Zenburn" then
    overrides.color_scheme = "Cloud (terminal.sexy)"
  else
    overrides.color_scheme = "Zenburn"
  end
  window:set_config_overrides(overrides)
end)


-- Keybindings
    config.keys = {
  -- Pane navigation and split
  { key = '\\', mods = 'CTRL', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'I', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = "Up", size = { Percent = 50 } } },
  { key = 'K', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = "Down", size = { Percent = 50 } } },
  { key = '[', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = ']', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
  { key = '9', mods = 'CTRL', action = act.PaneSelect },

  -- Tabs and windows
  { key = 'n', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'f', mods = 'CTRL', action = act.SpawnWindow },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- Scrolling
  { key = 'UpArrow', mods = 'CTRL', action = act.ScrollByLine(-10) },
  { key = 'DownArrow', mods = 'CTRL', action = act.ScrollByLine(5) },

  -- Debug and utility
  { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },
  {
    key = 'O',
    mods = 'CTRL|ALT',
    action = wezterm.action_callback(function(window, _)
      local overrides = window:get_config_overrides() or {}
      if overrides.window_background_opacity == 1.0 then
        overrides.window_background_opacity = 0.9
      else
        overrides.window_background_opacity = 1.0
      end
      window:set_config_overrides(overrides)
    end),
  },
}

return config
