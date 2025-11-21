-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28
config.font_size = 9
config.default_prog = {'/usr/bin/fish', '-l'}

-- Font settings
config.font = wezterm.font_with_fallback({
 { family = "JetBrainsMono", weight = "Regular" }, "Noto Sans Mono"
})

config.font_size = 10.0

config.color_scheme = "nordfox"

return config