--
--  SoundBoard
--  Based heavily on piepan example
--

config.soundboard = require("modules/soundboard/config")

function sounds()
    message = '<br /><br /><strong>Soundboard Sounds:</strong><br />#cheer, #hello, #huh, #image, #lol, #mock, #nice'
    return message
end

piepan.On('message', function(e)
	if string.sub(e.Message, 0, 1) == config.soundboard.sound_prefix then
        runSound(e)
    end
end)

function runSound(e)
    local search = string.match(e.Message, "#(%w+)")
    if search and config.soundboard.sounds[search] then
        local soundFile = 'modules/soundboard/data/' .. config.soundboard.sounds[search]
        if config.soundboard.require_registered and e.Sender.UserID == nil then
            e.Sender.Send("You must be registered on the server to trigger sounds.")
            return
        end
        if piepan.Audio.IsPlaying() and not config.soundboard.interrupt_sounds then
            return
        end

        piepan.Audio.Stop()
		channelTargets(e.Sender.Channel)
        piepan.Audio.Play({
    	    filename = soundFile
        })
    end
end

config.soundboard.help = sounds()