--
-- SoundBoard Config
--
local config = {}

config.help = ""
config.comment = ""

-- Sound Command Prefix
config.sound_prefix = "#"

-- Should I stop playing when another sound is running?
config.interrupt_sounds = false

config.require_registered = true

config.sounds = {
    cheer = "cheer.ogg",
    hello = "hello.ogg",
    huh = "huh.ogg",
    image = "image.ogg",
    lol = "lol.ogg",
    mock = "mock.ogg",
    nice = "nice.ogg"
}

return config