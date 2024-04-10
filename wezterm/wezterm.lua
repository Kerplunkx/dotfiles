local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Gruber (base16)'
config.use_fancy_tab_bar = false
config.font_size = 13
-- config.font = wezterm.font 'JetBrains Mono'
config.font = wezterm.font 'Iosevka Nerd Font'

config.window_padding = {
  left = 0,
  right = 0,
  top = 5,
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
