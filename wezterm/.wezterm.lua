

local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.front_end = "OpenGL"
config.max_fps = 60
config.default_cursor_style = "BlinkingBlock"
config.animation_fps = 1
config.cursor_blink_rate = 500
config.term = "xterm-256color"

config.font = wezterm.font("MesloLGS Nerd Font Mono")

config.cell_width = 0.9

config.window_background_opacity = 0.9
config.prefer_egl = true
config.font_size = 16

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
}

-- tabs
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

wezterm.on("toggle-colorscheme", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "Zenburn" then
		overrides.color_scheme = "Cloud (terminal.sexy)"
	else
		overrides.color_scheme = "Zenburn"
	end
	window:set_config_overrides(overrides)
end)

-- keymaps
config.keys = {
 -- Terminal split horizontally (equivalent to `workbench.action.terminal.split`)
    {
      key = '\\',
      mods = 'CTRL',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },

    {
      key = '[',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection 'Left',
    },


    {
      key = ']',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection 'Right',
    },

    -- Open a new tab
    {
      key = 'n',
      mods = 'CTRL',
      action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },-- Go to the next tab
{
  key = "Tab",
  mods = "CTRL",
  action = wezterm.action.ActivateTabRelative(1),
},

-- Go to the previous tab
{
  key = "Tab",
  mods = "CTRL|SHIFT",
  action = wezterm.action.ActivateTabRelative(-1),
},

    -- Open new window
    {
      key = 'f',
      mods = 'CTRL',
      action = wezterm.action.SpawnWindow,
    },

    -- Scroll up and down by line values
    {
      key = 'UpArrow',
      mods = 'CTRL',
      action = wezterm.action.ScrollByLine(-10),
    },
    {
      key = 'DownArrow',
      mods = 'CTRL',
      action = wezterm.action.ScrollByLine(5),
    },

	{
		key = "I",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Up",
			size = { Percent = 50 },
		}),
	},
	{
		key = "K",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},

	{ key = "9", mods = "CTRL", action = act.PaneSelect },
	{ key = "L", mods = "CTRL", action = act.ShowDebugOverlay },
	{
		key = "O",
		mods = "CTRL|ALT",
		-- toggling opacity
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

-- For example, changing the color scheme:
config.color_scheme = "Cloud (terminal.sexy)"
config.colors = {

	background = "#0c0b0f",

	cursor_border = "#bea3c7",

	cursor_bg = "#bea3c7",


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

config.window_frame = {
	font = wezterm.font({ family = "Iosevka Custom", weight = "Regular" }),
	active_titlebar_bg = "#47FF9C",

}

config.window_decorations = "NONE | RESIZE"
config.default_prog = { "pwsh", "-NoLogo" }
config.initial_cols = 80

return config
