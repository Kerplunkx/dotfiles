local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Gruber (base16)'
config.use_fancy_tab_bar = false
config.font_size = 11
config.font = wezterm.font 'JetBrains Mono'

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.keys = {
    {
    key = '|',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'Enter',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}

return config
