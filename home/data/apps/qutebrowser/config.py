config.load_autoconfig()

# Keyboardio (TRY THESE WITH MY NEW KEYBOARDIO!!)
config.bind('<Shift-Left>', 'back')
config.bind('<Shift-Down>', 'tab-next')
config.bind('<Shift-Up>', 'tab-prev')
config.bind('<Shift-Right>', 'forward')

c.fonts.web.family.fantasy = 'JetBrains Mono'

c.content.javascript.enabled = False
config.source('gruvbox.py')
