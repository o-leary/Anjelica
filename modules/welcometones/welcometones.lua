--
--  WelcomeTones
--

config.welcometones = require("modules/welcometones/config")
config.welcometones.tones = persistence.load("modules/welcometones/data/welcomesList.dat")

piepan.On('userChange', function(e)
    if e.IsConnected == true then
		playWelcome(e.User)
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

		if cmd == "ADDWELCOME" then
			addWelcome(e.Sender, arg, arg2)
		elseif cmd == "DELWELCOME" then
			delWelcome(e.Sender, arg)
		end
	end
end)

function playWelcome(user)
	if piepan.Audio.IsPlaying() and not config.welcometones.interrupt_sounds then
        return
    end
    for id,sound in pairs(config.welcometones.tones) do
        if id == tostring(user.UserID) then
            if sound ~= false then
				channelTargets(user.Channel)
                piepan.Audio.Play({
                    filename = "modules/welcometones/data/" .. sound,
                })
            end
        end
    end
end

function addWelcome(user, arg, arg2)
    if isAdmin(user) then
        for _,userTable in pairs(piepan.Users) do
            if string.match(arg, userTable.Name:upper()) then
                config.welcometones.tones[tostring(userTable.UserID)] = arg2
                persistence.store("modules/welcometones/data/welcomesList.dat", config.welcometones.tones);
                user.Send(userTable.Name .. " has welcome message ".. arg2 .. ".")
            end
        end
    else
        issueWarning(user, "Permission Denied.")
    end
end

function delWelcome(user, arg)
    if isAdmin(user) then
        for _,userTable in pairs(piepan.Users) do
            if string.match(arg, userTable.Name:upper()) then
                config.welcometones.tones[tostring(userTable.UserID)] = false
                persistence.store("modules/welcometones/data/welcomesList.dat", config.welcometones.tones);
                user.Send(userTable.Name .. "'s welcome sound was removed.")
            end
        end
    else
        issueWarning(user, "Permission Denied.")
    end
end

function tones()
	message = message .. '<br /><br /><strong>Welcome Tones (Admin Commands):</strong><br />!addwelcome <em>user</em> <em>file.ogg</em> - Add a welcome sound for a user.<br />!delwelcome <em>user</em> - Remove a welcome sound for a user.'
	return message
end

config.welcometones.help = tones()