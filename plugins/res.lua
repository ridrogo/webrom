local plugin = {}

local function get_ban_info(user_id, chat_id)
	local hash = 'ban:'..user_id
	local ban_info = db:hgetall(hash)
	local text
	if not next(ban_info) then
		text = _("Nothing to display\n")
	else
		local ban_index = {
			kick = _("Kicked: *%d*"),
			ban = _("Banned: *%d*"),
			tempban = _("Temporarily banned: *%d*"),
			flood = _("Removed for flooding chat: *%d*"),
			media = _("Removed for forbidden media: *%d*"),
			warn = _("Removed for max warnings: *%d*"),
			arab = _("Removed for arab chars: *%d*"),
			rtl = _("Removed for RTL char: *%d*"),
		}
		text = ''
		for type,n in pairs(ban_info) do
			text = text..ban_index[type]:format(n)..'\n'
		end
		if text == '' then
			return _("Nothing to display")
		end
	end
	local warns = (db:hget('chat:'..chat_id..':warns', user_id)) or 0
	local media_warns = (db:hget('chat:'..chat_id..':mediawarn', user_id)) or 0
	local spam_warns = (db:hget('chat:'..chat_id..':spamwarns', user_id)) or 0
	text = text..'\n`Warnings`: '..warns..'\n`Media warnings`: '..media_warns..'\n`Spam warnings`: '..spam_warns
	return text
end

local function res_usuario(user_id)
	if user_id:match('@[%w_]+') then
	res = api.res_linuxapiuser(user_id)	
	else
	res = api.res_linuxapid(user_id)
	end
	print(res)
	if not res.ok then
		return user_id
	else
	if res.result.last_name and res.result.username then
	   return '🔰📋 <b>Infomacion del usuario:</b>\n\n👤 <b>Nombre:</b> '..res.result.first_name..'\n👤 <b>Apellido:</b> '..res.result.last_name..'\n👤 <b>Usuario 🆔:</b> '..res.result.id..'\n🔸<b>Alias:</b> @'..res.result.username
	elseif not res.result.last_name and res.result.username and not res.result.title then
	   return '🔰📋 <b>Infomacion del usuario:</b>\n\n👤 <b>Usuario:</b> '..res.result.first_name..'\n👤 <b>Usuario 🆔:</b> '..res.result.id..'\n🔸<b>Alias:</b> @'..res.result.username
	elseif not res.result.last_name and not res.result.username and not res.result.title then
	   return 'ID: '..res.result.id
	   ..'\nNombre: ' ..res.result.first_name
	elseif res.result.last_name and not res.result.username then
	   return 'ID: '..res.result.id
	   ..'\nNombre: ' ..res.result.first_name
	   ..'\nApellido: ' ..res.result.last_name
	elseif res.result.id and res.result.last_name and res.result.username then
	   return 'ID: '..res.result.id
	   ..'\nNombre: ' ..res.result.first_name
	   ..'\nApellido: ' ..res.result.last_name
	   ..'\nAlias: @' ..res.result.username
	elseif res.result.title and res.result.username then
	   return 'Chat ID: '..res.result.id
	   ..'\nTítulo: ' ..res.result.title
	   ..'\nAlias: @' ..res.result.username
		end
	end
end

local function get_user_id(msg, blocks)
	if msg.target_id then
		return msg.target_id
	elseif msg.reply then
				local baninfo = get_ban_info(msg.reply.from.id, msg.chat.id)
				local res = api.getChatMember(msg.chat.id, msg.reply.from.id)
		 		if not res then
		 			api.sendReply(msg, lang[ln].status.unknown)
		 			return
		 		end
		 		local status = res.result.status
				if msg.chat.type == 'group' and is_banned(msg.chat.id, msg.reply.from.id) then
					status = 'kicked'
				end
		 		text = make_text(lang[ln].statuss[status])
			local counts = api.getChatMembersCount(msg.chat.id)
			local countstatus = counts.result
    		name = msg.reply.from.first_name
    		username = msg.reply.from.username
    		id = msg.reply.from.id
    		if msg.reply.from.username then
			username = '@'..msg.reply.from.username:escape()
			else
			username = '_❌  Este usuario no dispone de un alias_'
			end
			text = '🔰📋 <b>Infomacion del usuario:</b>\n\n👤 <b>Usuario:</b> '..name..'\n👤 <b>Usuario 🆔:</b> '..id..'\n🔸<b>Alias:</b> '..username..'\n🔸<b>Status:</b> '..text..'\n🔸<b>Fecha y Hora:</b> ' ..os.date("%x a las %H:%M:%S", delay).. '\n🔸<b>Usuarios del Grupo:</b> ' ..countstatus.. '\n🔸<b>Info de Global Baneos:</b> ' ..baninfo
			if not msg.reply then
				return false
			else
				return api.sendReply(msg, text, 'html')
			end
	elseif blocks[2] then
		if blocks[2]:match('@[%w_]+') then
			local user_id = res_usuario(blocks[2])
			if not user_id then
				return false
			else
				return user_id
			end
		elseif blocks[2]:match('%d+') then
			local user_id = res_usuario(blocks[2])
			if not user_id then
				return false
			else
				return user_id
			end
		end
	else
		return false
	end
end

function plugin.onTextMessage(msg, blocks)

	if blocks[1] == 'res' then

		local user_id = get_user_id(msg, blocks)
		local counts = api.getChatMembersCount(msg.chat.id)
		local countstatus = counts.result
		
		if roles.is_superadmin(msg) and msg.reply and not msg.cb then
			if msg.reply.forward_from then
				user_id = msg.reply.forward_from.id
			end
		end
		
		if not user_id and not usuario then
			api.sendReply(msg, 'Usuario no registrado', true)
				else
				local res = api.getChatMember(msg.chat.id, usuario)
				local baninfo = get_ban_info(usuario, msg.chat.id, ln)
		 		if not res then
					message = user_id..'\n🔸<b>Fecha y Hora:</b> ' ..os.date("%d/%m/%y a las %H:%M:%S", delay)
					api.sendMessage(msg.chat.id, message, 87)
				else
		 		local status = res.result.status
				if msg.chat.type == 'group' and is_banned(msg.chat.id, usuario) then
					status = 'kicked'
				end
		 		text = make_text(lang[ln].statuss[status])
			message = ''..user_id..'\n🔸<b>Status:</b> '..text..'\n🔸<b>Fecha y Hora:</b> ' ..os.date("%d/%m/%y a las %H:%M:%S", delay).. '\n🔸<b>Usuarios del Grupo:</b> ' ..countstatus.. '\n🔸<b>Info de Global Baneos:</b> ' ..baninfo
		api.sendMessage(msg.chat.id, message, 'html')
	end
end
end
end

plugin.triggers = {
	onTextMessage = {
		config.cmd..'(res)$',
		config.cmd..'(res) (@[%w_]+)$',
		config.cmd..'(res) (%d+)$'
	}
}

return plugin