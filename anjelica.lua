-- Include persistence library
if not _G.persistence then require 'includes/persistence' end

-- Load base config
config = require("config")
modules = require("modules")

--[[
	START CORE
]]

piepan.On('connect', function(e)
    config.admins = persistence.load("data/adminsList.dat")
    config.mods = persistence.load("data/modsList.dat")
    piepan.Audio.SetVolume(config.default_volume)
end)

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function ban(user, arg)
    if isAdmin(user) then
        for _,userTable in pairs(piepan.Users) do
            if string.match(arg, userTable.Name:upper()) then
                piepan.Audio.Play({
                    filename = config.prefix .. 'lol.ogg'
                })
                userTable.Ban("The admin hates you.")
            end
        end
    else
        issueWarning(user, "Permission Denied.")
    end
end

function showMods(user)
    message = '<br /><strong>Admins:</strong>'
    for admin,value in pairs(config.admins) do
        message = message .. '<br />' .. admin
    end
    message = message .. '<br /><br /><strong>Moderators:</strong>'
    for mod,value in pairs(config.mods) do
        if value == true then
            message = message .. '<br />' .. mod
        end
    end
    user.Send(message)
end

function isEmpty(s)
    return s == nil or s == ''
end

function explode(div,str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    for st,sp in function() return string.find(str,div,pos,true) end do
        table.insert(arr,string.sub(str,pos,st-1))
        pos = sp + 1
    end
    table.insert(arr,string.sub(str,pos))
    return arr
end

function countUsers()
    counter = 0
    for name,_ in pairs(piepan.users) do
        counter = counter + 1
    end
    return counter
end

function isMod(user)
    if isAdmin(user) then
        return true
    end
    for mod,value in pairs(config.mods) do
        if tostring(user.UserID) == mod and value == true then
            return true
        end
    end
    return false
end

function isAdmin(user)
    for admin,value in pairs(config.admins) do
        if tostring(user.UserID) == admin and value == true then
            return true
        end
    end
    return false
end

function addMod(user, arg)
    if isAdmin(user) then
        for _,userTable in pairs(piepan.Users) do
            if string.match(arg, userTable.Name:upper()) then
                config.mods[tostring(userTable.UserID)] = true
                persistence.store("data/modsList.dat", config.mods);
                user.Send(userTable.UserID .. " was added to moderators.")
            end
        end
    else
        issueWarning(user, "Permission Denied.")
    end
end

function addAdmin(user, arg)
    --if isAdmin(user) then
        for _,userTable in pairs(piepan.Users) do
            if string.match(arg, userTable.Name:upper()) then
                config.admins[tostring(userTable.UserID)] = true
                persistence.store("data/adminsList.dat", config.admins);
                user.Send(userTable.UserID .. " was added to admins.")
            end
        end
    --else
      --  issueWarning(user, "Permission Denied.")
    --end
end

function delMod(user, arg)
    if isAdmin(user) then
        for _,userTable in pairs(piepan.Users) do
            if string.match(arg, userTable.Name:upper()) then
                config.mods[tostring(userTable.UserID)] = false
                persistence.store("data/modsList.dat", config.mods);
                user.Send(userTable.UserID .. " was removed from moderators.")
            end
        end
    else
        issueWarning(user, "Permission Denied.")
    end
end

function showMods(user)
    message = '<br /><strong>Admins:</strong>'
    for admin,value in pairs(config.admins) do
        message = message .. '<br />' .. admin
    end
    message = message .. '<br /><br /><strong>Moderators:</strong>'
    for mod,value in pairs(config.mods) do
        if value == true then
            message = message .. '<br />' .. mod
        end
    end
    user.Send(message)
end


function move(user, arg, arg2)
    if isMod(user) then
        for _,userTable in pairs(piepan.Users) do
            if userTable.Name:upper() == arg then
                user.Send(userTable.Name .. " has been moved to channel '" .. piepan.Channels[tonumber(arg2)].Name() .. "' by " .. user.Name, false)
                userTable.Move(piepan.Channels[tonumber(arg2)])
            end
        end
    else
        issueWarning(user, "Permission Denied.")
    end
end

function set_volume(volume, user)
	if volume > 0 and volume <= 1 then
		piepan.Audio.SetVolume(volume)
		piepan.Self.Channel.Send(user.Name .. " changed volume to " .. tostring(volume) .. ".", false)
	else
		user.Send("Volume must be between 0.1 and 1.0.", false)
	end
end

function channelTargets(channel)
	target = piepan.Audio.NewTarget(10)
	target.AddChannel(channel, false, false, "")
	piepan.Audio.SetTarget(target)
end

function issueWarning(user, message)
    --ToDo Detect abuse and autoban/report
    user.Send(message)
end



piepan.On('message', function(e)
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

    -- Help command
    if cmd == "KILL" then
		if isMod(e.Sender) then
			piepan.Disconnect()
		end
	elseif cmd == "VOLUME" or cmd == "VOL" then
		set_volume(tonumber(arg), e.Sender)
    elseif cmd == "MOVE" then
        move(e.Sender, arg, arg2)
    elseif cmd == "ADDMOD" then
        addMod(e.Sender, arg)
    elseif cmd == "DELMOD" then
        delMod(e.Sender, arg)
    elseif cmd == "BAN" then
        ban(e.Sender, arg)
    elseif cmd == "ADDADMIN" then
        addAdmin(e.Sender, arg)
	elseif cmd == "MODS" then
        showMods(e.Sender)
	elseif cmd == "HELP" then
        showHelp(e.Sender)
	end
end)

function showHelp(user)
	message = help()
	for i, module in ipairs(modules) do
		loadstring("message = message .. config." .. module .. ".help")()
	end
	user.Send(message)
end

function updateComment()
	if config.set_comment == true then
		message = ''
		for i, module in ipairs(modules) do
			loadstring("message = message .. config." .. module .. ".comment")()
		end
	piepan.Self.SetComment(message)
	end
end

function help()
	message = '<br /><strong>Help Menu:</strong>'
    message = message .. '<br /><br /><strong>Commands:</strong><br />!mods - List all admins and moderators.<br />!vol <em>0.1 - 1</em> - Change ' .. config.bot_name .. ' volume.'
    message = message .. '<br /><br /><strong>Moderator Tasks:</strong><br />!kick <em>user</em> - Kick a user immediately.<br />!channels - Lists channel numbers.'
    message = message .. '<br />!move <em>user</em> <em>channel#</em> - Move a user to another channel.'
    message = message .. '<br /><br /><strong>Admin Tasks:</strong><br />!addmod <em>user</em> - Adds a user to the list of moderators.<br />!delmod <em>user</em> - Removes a user from the list of moderators.'
    message = message .. '<br />!ban <em>user</em> - Bans a user from the server.'
    return message
end

--[[
	END CORE
]]


--[[ 
	Load enabled modules
]]

for i, module in ipairs(modules) do
	require("modules/" .. module .. "/" .. module)
end

--[[
	End load modules
]]