local plugin = {}

local function do_keyboard_start2()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = ' Ir al Chat Privado', url = 'https://t.me/'..bot.username}
	    }
    }
    return keyboard
end

function do_pruebas(user_id)
	local keyboard = {
	inline_keyboard = {
    	{{text = '✅ Pruebas', callback_data = 'pruebasbuttom:pruebas2:'..user_id}},
	}
}
	return keyboard
end

local function grep_reply(msg)
		local action = io.popen('grep -rn "'..msg.reply.from.id..'" ./data/gbans.lua')
		local read = action:read("*a")
		return read
end

local function grep_blocks(msg, blocks)
		local action = io.popen('grep -rn "'..blocks[2]..'" ./data/gbans.lua')
		local read = action:read("*a")
		return read
end


function plugin.onTextMessage(msg, blocks)

if roles.is_superadmin(msg.from.id) then
if blocks[1] == 'gbanlist' then
api.sendDocument(msg.chat.id, './data/gbans.lua')
api.sendDocument(msg.chat.id, './data/pfilos.lua')
end


 if blocks[1] == "gban" then
 	
 if not blocks[2] then
 		if msg.reply then
			get = grep_reply(msg)
			action_sucess = api.banUser(msg.chat.id, msg.reply.from.id)
			if action_sucess then
			 if get == '' then
			 	os.execute('perl -pi -e "s[gbans = \\{][gbans = {\n\t'..msg.reply.from.id..',]g" data/gbans.lua')
				api.sendReply(msg, "Usuario *expulsado*.\nID " ..msg.reply.from.id.. " *globalmente baneada*.", true)
				bot_init(true)
			 else
			 	api.sendMessage(msg.chat.id, 'Esta ID *ya había sido globalmente baneada* anteriormente.', true)
			 	return nil
			 end
			end
			if not action_sucess then
			 if get == '' then
			 	os.execute('perl -pi -e "s[gbans = \\{][gbans = {\n\t'..msg.reply.from.id..',]g" data/gbans.lua')
				api.sendReply(msg, "Usuario *no expulsado*.\nID " ..msg.reply.from.id.. " *globalmente baneada*.", true)
				bot_init(true)
			 else
			 	api.sendMessage(msg.chat.id, 'Esta ID *ya había sido globalmente baneada* anteriormente.', true)
			 	return nil
			 end
			end
		else
			api.sendMessage(msg.chat.id, "Este comando necesita respuesta")
		end
	else
	if blocks[2]:match('(%d+)') and blocks[3] == 'pedofilo' then
		get = grep_blocks(msg, blocks)
	 if get == '' then
  		os.execute('perl -pi -e "s[pfilos = \\{][pfilos = {\n\t'..blocks[2]..',\t--\tMotivo:\t'..blocks[3]..']g" data/gbans.lua')
		local user = api.resolveUsernameTG(blocks[2], msg.chat.id)
		api.sendMessage(msg.chat.id, "" ..user.. " \n*Globalmente baneado*.\n Motivo: *"..blocks[3].."*", true)
		end
	elseif blocks[2]:match('(%d+)') and blocks[3] == 'spammer' then
		get = grep_blocks(msg, blocks)
	 if get == '' then
  		os.execute('perl -pi -e "s[spammers = \\{][spammers = {\n\t'..blocks[2]..',\t--\tMotivo:\t'..blocks[3]..']g" data/gbans.lua')
		local user = api.resolveUsernameTG(blocks[2], msg.chat.id)
		api.sendMessage(msg.chat.id, "" ..user.. " \n*Globalmente baneado*.\n Motivo: *"..blocks[3].."*", true)
		end
	elseif blocks[2]:match('(%d+)') and blocks[3] then
		get = grep_blocks(msg, blocks)
	 if get == '' then
  		os.execute('perl -pi -e "s[gbans = \\{][gbans = {\n\t'..blocks[2]..',\t--\tMotivo:\t'..blocks[3]..']g" data/gbans.lua')
		local user = api.resolveUsernameTG(blocks[2], msg.chat.id)
		api.sendMessage(msg.chat.id, "" ..user.. " \n*Globalmente baneado*.\n Motivo: *"..blocks[3].."*", true)
		bot_init(true)
		end
	elseif blocks[2]:match('(%d+)') then
		get = grep_blocks(msg, blocks)
--		local allbanned = all_gbanned(blocks[2])
	 if get == '' then
  		os.execute('perl -pi -e "s[gbans = \\{][gbans = {\n\t'..blocks[2]..',]g" data/gbans.lua')
		local user = api.resolveUsernameTG(blocks[2], msg.chat.id)
		api.sendMessage(msg.chat.id, "" ..user.. " \n*Globalmente baneado*.", true)
		bot_init(true)
		end
	 else
	 	api.sendMessage(msg.chat.id, 'Este usuario *ya había sido baneado* anteriormente.', true)
		return nil
 end
end
end
 
 if blocks[1] == "ungban" then
 	
 	 if not blocks[2] then
		if msg.reply then
			get = grep_reply(msg)
			action_sucess = api.unbanChatMember(msg.chat.id, msg.reply.from.id)
			if action_sucess then
			 if get == '' then
	 			api.sendReply(msg, 'Esta ID *ya había sido globalmente desbaneada* anteriormente.', true)
	  			return nil
	 		 else
	 		 	os.execute('sed -i "/' ..msg.reply.from.id.. '/d" ./data/gbans.lua')
				api.sendReply(msg, "ID " ..msg.reply.from.id.. " *globalmente desbaneada*.\nEste usuario, ya puede ingresar al grupo de nuevo.", true)
				bot_init(true)
			 end
			end
			if not action_sucess then
			 if get == '' then
	 			api.sendReply(msg, 'Esta ID *ya había sido globalmente desbaneada* anteriormente.', true)
	  			return nil
	 		 else
	 		 	os.execute('sed -i "/' ..msg.reply.from.id.. '/d" ./data/gbans.lua')
				api.sendReply(msg, "ID " ..msg.reply.from.id.. " *globalmente desbaneada*.\nEste usuario aún no puede ingresar al grupo de nuevo.", true)
				bot_init(true)
			 end
			end
		else
			api.sendMessage(msg.chat.id, "Este comando necesita respuesta")
		end
	else
	get = grep_blocks(msg, blocks)
	 if get == '' then
	 	api.sendMessage(msg.chat.id, 'Esta ID *ya había sido globalmente desbaneada*.', true)
	  	return nil
	 else
	 	if blocks[2]:match('(%d+)') then
	  	os.execute('perl -pi -e "s['..blocks[2]..',][\t]g" data/gbans.lua')
		api.sendReply(msg, "ID " ..blocks[2].. " *globalmente desbaneada*.", true)
	  	elseif blocks[2]:match('(%d+)') and blocks[3] then
	  	os.execute('perl -pi -e "s['..blocks[2]..',\t--\tMotivo:\t'..blocks[3]..'][\t]g" data/gbans.lua')
--	  	os.execute('sed -i "/--/d" ./data/gbans.lua')
		api.sendReply(msg, "ID " ..blocks[2].. " *globalmente desbaneada*.", true)
		bot_init(true)
		return nil
		end
	 end
	end
	
end

if blocks[1] == "targetgroupcp" then
pid = sis.fork()
if pid == 0 then
--		db:set("subproceso:"..msg.from.id..":ok", sis.getpid('pid'))
             mensaje = msg.message_id + 1
             api.sendMessage(msg.chat.id, 'Espera con paciencia, la peticion tardará 1 a 2 minutos máximo')
             sleep(1)
             for i = 1-1, 0, -1 do
             api.editMessageText(msg.chat.id, mensaje, tostring(i))
             sleep(1)
             end
            api.editMessageText(msg.chat.id, mensaje, 'Espera con paciencia, la peticion tardará 1 a 2 minutos máximo')
			local txt = ''
			local pfilos = api.targetcp(blocks[2])
			local resgroup = api.getChat(blocks[2])
			if not pfilos then
				txt = txt..'No hay pedofilos de la lista en '..resgroup.result.title..' ID: '..blocks[2]
				api.editMessageText(msg.chat.id, mensaje, 'No hay pedofilos de la lista en '..resgroup.result.title..' \nID: '..blocks[2], false, true)
			elseif pfilos.allow_kick == false then
				txt = txt..'No puedo expulsar pedofilos de la lista de este grupo '..resgroup.result.title..' \nID: '..blocks[2]
				api.editMessageText(msg.chat.id, mensaje, 'No puedo expulsar pedofilos de este grupo '..resgroup.result.title..' \nID: '..blocks[2], false, true)
			elseif pfilos.bot_admin == true and pfilos.count == 0 then
				txt = txt..'No hay pedofilos de la lista en '..resgroup.result.title..' \nID: '..blocks[2]
				api.editMessageText(msg.chat.id, mensaje, 'No hay pedofilos de la lista en '..resgroup.result.title..' \nID: '..blocks[2], false, true)				
			elseif pfilos.bot_admin == true and pfilos.result.status == 'member' then
				local gname = api.getChat(pfilos.result.user_id)
				local ban = api.banUser(blocks[2], pfilos.result.user_id)
				if ban then
				txt = txt..'Atento!!, <b>Pedofilo</b> '..gname.result.first_name..' \n<b>Baneado de Grupo:</b> '..gname.result.title..' \n<b>ID:</b> '..blocks[2]
	    		api.editMessageText(msg.chat.id, mensaje, 'Atento!!, *Pedofilo* '..gname.result.first_name:mEscape()..' \n*Baneado de Grupo:* '..gname.result.title:mEscape()..' \n*ID:* '..blocks[2], false, true)
	        	print('Pedofilo en Chat', blocks[2])
	        	end
			 end
			misc.write_file("./logs/targetcpban.html", txt)
			api.sendDocument(config.admin.owner, './logs/targetcpban.html')
			api.sendMessage(config.log_chat, txt, 87)
--			db:del("subproceso:"..msg.from.id..":ok")
			sis._exit(0)
		end
end


if blocks[1] == "targetcp" then
		pid = sis.fork()
       	if pid == 0 then
		local txt = ''
       	local grep = io.popen("grep "..blocks[2].. " ./data/pfilos.lua")
		local list = grep:read("*a")
		local keyboard = do_pruebas(blocks[2])
	    local gids = db:smembers('bot:groupsid')
	    user = api.resolveUsernameTG(blocks[2])
	    if list == "" then
		api.sendMessage(msg.chat.id, user..' \nNo es pedófilo o no se encuentra listado', true)
		else
		for i,chat_id in pairs(gids) do
			local res = api.getChatMember(chat_id, blocks[2])
			if not res then
			else
				if res.result.status == 'member' then
				local gname = api.getChat(chat_id)
				local pname = api.getChat(blocks[2])
				local ban = api.banUser(chat_id, blocks[2])
				if ban then
				txt = txt..'<pre><b>Atento!!, Pedofilo</b> '..getname_link_html(pname.result.first_name, pname.result.username)..' \n<b>Baneado de Grupo:</b> '..gname.result.title:mEscape()..' \n<b>ID:</b> '..chat_id..'</pre>'
	    		api.sendKeyboard(chat_id, 'Atento!!, *Pedofilo* '..user..' \n*Baneado de Grupo:* '..gname.result.title:mEscape()..' \n*ID:* '..chat_id, keyboard, true)
	        	print('Pedofilo en Chat', chat_id)
	        	end
	    		else
	--	 		txt = txt..'<pre> \nPedofilo '..getname_link_html(pname.result.first_name, pname.result.username)..' no se encuentra en grupo '..gname.result.title:mEscape()..' \nID: '..chat_id..' o es Creador y/o Administrador de Grupo</pre>'
--	    	   	api.sendMessage(msg.chat.id, user..' \nPedofilo no se encuentra en grupo '..gname.result.title:mEscape()..' \n*ID:* '..chat_id..' o es Creador y/o Administrador de Grupo', true)
	    		end
	      	print(txt)
	    	end
		 end
		write_file("./logs/targetcp.html", txt)
		api.sendDocument(config.admin.owner, './logs/targetcp.html')
		local send = api.sendMessage(msg.chat.id, txt, 87)
		if not send then
			api.sendMessage(msg.chat.id, 'Mensaje muy largo, revisa el log en tu chat privado.')
		end
	end
		sis._exit(0)
		end
	end

end

 if blocks[1] == "isgban" then
 	
  	if not blocks[2] then
		if msg.reply then
		local grep = io.popen("grep "..msg.reply.from.id.. " ./data/gbans.lua")
		local list = grep:read("*a")
		local user = api.resolveUsernameTG(msg.reply.from.id, msg.chat.id)
		if list == "" then
		api.sendReply(msg, "_Esta ID no esta globalmente baneada_", true)
		else
	        api.sendReply(msg, ""..user.." \nEstá *Globalmente baneado*", true)
		end
		end
	else
	if blocks[2] then
		local grep = io.popen("grep "..blocks[2].." ./data/gbans.lua")
		local list = grep:read("*a")
		local user = api.resolveUsernameTG(blocks[2], msg.chat.id)
		if list == "" then
		api.sendMessage(msg.chat.id, "_No se encontraron coincidencias_", true)
		else
			api.sendMessage(msg.chat.id, ""..user.."* \nEstá Globalmente Baneado\n\n"..list:gsub('(%d+)(.)(.)(.)(.)','').."*", true)
			end
	end
	

		end
end

 if blocks[1] == "iscp" then
	if blocks[2] then
		local keyboard = do_pruebas(blocks[2])
		local grep = io.popen("grep "..blocks[2].. " ./data/pfilos.lua")
		local list = grep:read("*a")
		user = api.resolveUsernameTG(blocks[2], msg.chat.id)
		if list == "" then
		api.sendMessage(msg.chat.id, "_ID no encontrada en base de datos_\n\n"..user, true)
		else
		api.sendKeyboard(msg.chat.id, "*PEDÓFILO*\nAtento "..user.." encontrado en base de datos.", keyboard, true)
		end
	end
	
 	if not blocks[2] then
		if msg.reply then
		local keyboard = do_pruebas(msg.reply.from.id)
		local grep = io.popen("grep "..msg.reply.from.id.. " ./data/pfilos.lua")
		local list = grep:read("*a")
		user = api.resolveUsernameTG(msg.reply.from.id, msg.chat.id)
		if list == "" then
		api.sendReply(msg, "_ID no encontrada en base de datos_\n\n"..user, true)
		else
	    api.sendKeyboard(msg.chat.id, "*PEDÓFILO*\nAtento "..user.." encontrado en base de datos.", keyboard, true)
		end
		end
	end
end

end

function plugin.onCallbackQuery(msg, blocks)
if blocks[1] == 'pruebas2' then
	    api.editMessageText(msg.chat.id, msg.message_id, 'Pruebas Enviadas al chat privado '..getname_link(msg.from.first_name, msg.from.username), do_keyboard_start2(), true)            
		if blocks[2] then
		pruebas = api.obtener_pruebas(blocks[2])
		else
		pruebas = api.obtener_pruebas(msg.reply.from.id)
		end
		if not pruebas then
			api.sendMessage(msg.from.id, " \n*Id inválida*", true)	
		elseif pruebas.result.statusid == 0 then
			api.sendMessage(msg.from.id, " \n*No esta en lista de Ceperos*", true)	
		elseif pruebas.result.statusid == 1 then
			api.sendMessage(msg.from.id, " \n*En lista de Ceperos, pero no tiene pruebas*", true)	
		elseif pruebas.result.statusid == 2 then
	    local BASE_URL = 'https://api.telegram.org/file/bot' .. config.bot_api_key
		local file = api.getFile(pruebas.result.photos[1])
		local file2 = api.getFile(pruebas.result.photos[2])
		local success = tostring(download_to_file(BASE_URL .. '/' .. file.result.file_path:gsub('//', '/'):gsub('/$', ''), 'prueba1.png'))
		local success2 = tostring(download_to_file(BASE_URL .. '/' .. file2.result.file_path:gsub('//', '/'):gsub('/$', ''), 'prueba2.png'))
		api.sendPhoto(msg.from.id, success)
		api.sendPhoto(msg.from.id, success2)
		sleep(1)
		api.sendMessage(msg.from.id, "Pruebas de *Pédofilo*\n"..user.." *Enviadas correctamente*", true)
	end
end
end

plugin.triggers = {
    onTextMessage = {
		config.cmd..'(gban)$',
		config.cmd..'(gban) (%d+)$',
		config.cmd..'(gban) (%d+) (.*)$',
		config.cmd..'(ungban)$',
		config.cmd..'(ungban) (%d+)$',
		config.cmd..'(isgban)$',
		config.cmd..'(isgban) (%d+)$',
		config.cmd..'(iscp)$',
		config.cmd..'(iscp) (%d+)$',
		config.cmd..'(targetcp) (%d+)$',
--		config.cmd..'(targetgroupcp) (-%d+)$',
		config.cmd..'(gbanlist)'
    },
	onCallbackQuery = {
		'^###cb:pruebasbuttom:(pruebas2):(%d+)$',
    }
}

return plugin
