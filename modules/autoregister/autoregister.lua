--
--  AutoRegister
--

config.autoregister = {}
config.autoregister.help = ""
config.autoregister.comment = ""

piepan.On('userChange', function(e)
	if e.IsConnected == true then
		if e.User.IsRegistered() ~= true then
			e.User.Register()
			e.User.Send("You have been registered on the server as: " .. e.User.Name)
		end
	end
end)