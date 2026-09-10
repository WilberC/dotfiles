local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Allow smooth rendering on high-refresh-rate displays.
-- WezTerm still follows the display/compositor refresh rate.
config.max_fps = 240

return config
