--
--	JukeBox
--  Heavily based on MumbleDJ by Matthieu Grieger
--

-- Load jukebox config
config.jukebox = require("modules/jukebox/config")
config.jukebox.music = persistence.load("modules/jukebox/data/musicList.dat")

-- do initialization
local deque = require("includes/dequeue")
local song_queue = deque.new()
local skippers = {}
local stopped = false

piepan.On('userChange', function(e)
    if e.IsConnected == true then
		if e.User.IsRegistered() == true then
			config.jukebox.vote_count[e.User.UserID] = {}
			config.jukebox.vote_count[e.User.UserID]['counter'] = 0
			config.jukebox.vote_count[e.User.UserID]['voted'] = 0
			config.jukebox.vote_count[e.User.UserID]['timestamp'] = 0
			loadTargets()
		end
    end
end)

piepan.On('message', function(e)
    if e.Sender == nil then
        return
    end

    if string.sub(e.Message, 0, 1) == config.command_prefix then
        local cmd = ""
		local arg = ""
		local arg2 = ""
		if string.find(e.Message, " ") then
			arrArgs = explode(" ",  string.sub(e.Message, 2))
			cmd = cmd .. arrArgs[1]
			arg = arg .. arrArgs[2]
			arg2 = arg2 .. tostring(arrArgs[3])
		else
			cmd = string.sub(e.Message, 2)
		end

		cmd = cmd:upper()
		arg = arg:upper()

		if cmd == "PLAY" then
			play(e.Sender)
		elseif cmd == "QUIT" then
			quitPlay(e.Sender)
		elseif cmd == "ADD" then
			if string.find(e.Message, " ") then
				cmd = string.sub(e.Message, 2, string.find(e.Message, ' ') - 1)
				arg = string.sub(e.Message, string.find(e.Message, ' ') + 1)
			else
				cmd = string.sub(e.Message, 2)
			end
			if not add_song(arg, e.Sender.Name, e) then
				e.Sender.Send("The URL supplied was not valid.")
			else
				if not piepan.Audio.IsPlaying() then
					return get_next_song()
				end
			end
		elseif cmd == "SKIP" then
			skip(e.Sender)
		elseif cmd == "PLAYING" then
			now_playing(e);
		elseif cmd == "STOP" then
			stop(e.Sender)
		elseif cmd == "START" then
			if not piepan.Audio.IsPlaying() then
				dostart()
				piepan.Self.Channel.Send(e.Sender.Name .. " resumed the music.", false)
			end
		elseif cmd == "MUSIC" then
			e.Sender.Send(music())
		end

    end
end)

function music()
    message = '<br /><br /><strong>Music Commands:</strong><br />!play - Lets you hear the music.<br />!quit - Deafens you from the music.<br />!add <em>url</em> - Adds a song to the playlist.<br />!stop - Stops the music.<br />!start - Resumes the music.<br />!skip - Skips the current song.'
    return message
end

function play(user)
    config.jukebox.music[tostring(user.Name:upper())] = true
    persistence.store("modules/jukebox/data/musicList.dat", config.jukebox.music)
	user.Send('You were added to the music list.')
    loadTargets()
end

function loadTargets()
    local users = {}
	target = piepan.Audio.NewTarget(20)
	for _,user in pairs(piepan.Users) do
        for name,value in pairs(config.jukebox.music) do
            if tostring(user.Name:upper()) == name and value == true then
                target.AddUser(user)
            end
        end
    end
	piepan.Audio.SetTarget(target)
end

function quitPlay(user)
    config.jukebox.music[tostring(user.Name:upper())] = false
    persistence.store("modules/jukebox/data/musicList.dat", config.jukebox.music);
    loadTargets()
end

function skip(user)
    if isMod(user) then
        piepan.Self.Channel.Send(config.jukebox.admin_song_skipped_html, false)
        piepan.Audio.Stop()
    elseif add_skip(user.Name) then
        local skip_ratio = count_skippers()
        if skip_ratio > config.jukebox.skip_ratio then
            piepan.Self.Channel.Send(config.jukebox.song_skipped_html, false)
            piepan.Audio.Stop()
        else
            piepan.Self.Channel.Send(string.format(config.jukebox.user_skip_html, user.Name), false)
        end
    end
end

function stop(user)
    if isMod(user) then
        piepan.Self.Channel.Send(config.jukebox.admin_music_stopped_html, false)
        piepan.Audio.Stop()
		dostop()
	end
end


-- Begins the process of adding a new song to the song queue.
function add_song(url, username, e)
	dostart()
	local patterns = {
		"https?://www%.youtube%.com/watch%?v=([%d%a_%-]+)",
		"https?://youtube%.com/watch%?v=([%d%a_%-]+)",
		"https?://youtu.be/([%d%a_%-]+)",
		"https?://youtube.com/v/([%d%a_%-]+)",
		"https?://www.youtube.com/v/([%d%a_%-]+)"
	}
	
	for _,pattern in ipairs(patterns) do
		local video_id = string.match(url, pattern)
		if video_id ~= nil and string.len(video_id) < 20 then
			return get_youtube_info(video_id, username, e)
		end
	end
	
    return false
end

-- Notifies the channel that a song has been added to the queue, and plays the
-- song if it is the first one in the queue.
function youtube_info_completed(info, e)
	if info == nil then
		return false
	end
	song_queue:push_right(info)

	if e.Sender ~= nil then
		local message = string.format(config.jukebox.song_added_html, info.username, info.title)
        e.Sender.Send(message, false)
    end

	return true
end

-- Sends now playing information to requester
function now_playing(e)
	if e.Sender == nil then
        return
    end
	if config.jukebox.now_playing ~= "" then
		e.Sender.Send(config.jukebox.now_playing, false)
	else
		e.Sender.Send(config.jukebox.nothing_playing, false)
	end
end

-- Deletes the old song and begins the process of retrieving a new one.
function get_next_song()
	reset_skips()
	if file_exists("modules/jukebox/normalized-song.wav") then
		os.remove("modules/jukebox/normalized-song.wav")
	end
	config.jukebox.now_playing = ""
	if config.jukebox.set_comment == true then
		config.jukebox.comment = config.jukebox.now_playing
	end
	if song_queue:length() ~= 0 then
		local next_song = song_queue:pop_left()
		return start_song(next_song)
	end
end

-- Retrieves the metadata for the specified YouTube video via the gdata API.
function get_youtube_info(id, username, e)
	if id == nil then
		return false
	end
	local cmd = [[
		wget -q -O - 'https://www.googleapis.com/youtube/v3/videos?part=snippet&id=%s&key=AIzaSyAS6nM9DORQBQ01fKA-cX3tdJL7fMxyKjE' |
		jshon -Q -e items -e 0 -e snippet -e title -u -p -e thumbnails -e default -e url -u
	]]
	local jshon = io.popen(string.format(cmd, id))
	local name = jshon:read()
	local thumbnail = jshon:read()
	if name == nil then
		return false
	end
	
	local cmd = [[
		wget -q -O - 'https://ytgrabber.p.mashape.com/app/get/%s' --header='X-Mashape-Key: luf0udmgRCmshvQJ2q7nne3upwnUp1IZ22ijsn0SyMvcNYHVL0' --header='Accept: application/json' |
		jshon -e link -e -1 -e url -u
	]]
	local jshon = io.popen(string.format(cmd, id))
        local url = jshon:read()

	return youtube_info_completed({
		id = id,
		title = name,
		thumbnail = thumbnail,
		username = username,
		url = url
	}, e)
end

-- Downloads/encodes the audio file and then begins to play it.
function start_song(info)
        piepan.Process.New(function (success, data)
            if not success then
                piepan.Self.Channel.Send("I hate that song.", false)
				sleep(3)
                get_next_song()
                return false
            end

			if stopped == true then
				return false
			end

            if file_exists("modules/jukebox/normalized-song.wav") then

                    if piepan.Audio.IsPlaying() then
                            piepan.Audio.Stop()
                    end
                    loadTargets()
                    piepan.Audio.Play({ filename="modules/jukebox/normalized-song.wav", callback = get_next_song })
            end

            if piepan.Audio.IsPlaying() then
                    config.jukebox.now_playing = string.format(config.jukebox.now_playing_html, info.thumbnail, info.id, info.title, info.username)
					if config.jukebox.set_comment == true then
						config.jukebox.comment = config.jukebox.now_playing
						updateComment()
					end
                    return true
            end
           
           return false

        end, "modules/jukebox/includes/run_conversion.sh", info.url)
        return true
end

function dostop()
	stopped = true
end

function dostart()
	stopped = false
end

-- Adds the username of a user who requested a skip. If their name is
-- already in the list nothing will happen.
function add_skip(username)
	local already_skipped = false
	for _,name in pairs(skippers) do
		if name == username then
			already_skipped = true
		end
	end
	if not already_skipped then
		table.insert(skippers, username)
		return true
	end

	return false
end

-- Counts the number of users who would like to skip the current song and
-- returns it.
function count_skippers()
	local skipper_count = 0
	for _,name in pairs(skippers) do
		skipper_count = skipper_count + 1
	end
	return skipper_count
end

-- Resets the list of users who would like to skip a song. Called during a transition between songs.
function reset_skips()
	skippers = {}
end

-- Retrieves the length of the song queue and returns it.
function get_length()
	return song_queue:length()
end

-- Checks if a file exists.
function file_exists(file)
	local f=io.open(file,"r")
	if f~=nil then io.close(f) return true else return false end
end



--[[
	Load default music recipients
]]
config.jukebox.help = music()