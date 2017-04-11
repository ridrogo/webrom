local plugin = {}

-- detecta alias de canales y supergrupos
local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function n2s(s)
	if s == nil then return "" else return s end
end

function plugin.onTextMessage(msg, blocks)
	local id = msg.from.id
	local name = msg.from.first_name

	if blocks[1] == "lb" and #blocks >= 2 and roles.is_admin_cached(msg) or config.superadmins[msg.from.id] then
		--set y add
		if blocks[2] == "set" or blocks[2] == "add" then
			if (not msg.entities) or (#msg.entities == 1 and msg.entities[1].offset == 0) or (#msg.entities == 0) then
				api.sendMessage(msg.chat.id, "ℹ️ Introduce una lista de canales a permitir en este grupo")
				return false
			end
			if blocks[2] == "set" then
				canales = ""
			else
				canales = n2s(db:hget('chat:'..msg.chat.id..':settings', 'listablanca'))
			end
			nocanal={}
			repes={}
			modified=false
			for i,entity in pairs(msg.entities) do
				canal = trim(string.sub(msg.text, entity.offset+1, entity.offset+entity.length+1))
				if canal ~= "/"..blocks[1] then
					if api.getChat(canal) then
						if string.match(canales, canal) == nil then
							canales = canales..","..canal
							modified=true
						else
							repes[#repes+1]=canal
						end
					else
						nocanal[#nocanal+1]=canal
					end
				end
			end
			db:hset('chat:'..msg.chat.id..':settings', 'listablanca', canales)
			if modified then
				if blocks[2] == "set" then
					message="✅ Lista seteada correctamente. Esos alias seran ignorados por el antispam en este grupo."
				else
					message="✅ Añadidas excepciones correctamente. Esos alias seran ignorados por el antispam en este grupo."
				end
			else
				message=""
			end
			if #nocanal > 0 then
				message = message.."\n\n"
				for i,canal in pairs(nocanal) do
					if i == 1 then
						message=message..canal
					elseif i == #nocanal then
						message=message.." y "..canal
					else
						message=message..", "..canal
					end
				end
				if #nocanal == 1 then
					message=message.." no es un canal válido, no se añadirá a la lista."
				else
					message=message.." no son canales válidos, no se añadirán a la lista."
				end
			end
			if #repes > 0 then
				message = message.."\n\n"
				for i,canal in pairs(repes) do
					if i == 1 then
						message=message..canal
					elseif i == #repes then
						message=message.." y "..canal
					else
						message=message..", "..canal
					end
				end
				if #repes == 1 then
					message=message.." está repetido, no se añadirá a la lista."
				else
					message=message.." están repetidos, no se añadirán a la lista."
				end
			end
			api.sendReply(msg, message)
			return false
		end
		--reset
		if blocks[2] == "reset" then
			db:hdel('chat:'..msg.chat.id..':settings', 'listablanca')
			api.sendReply(msg, "🔁 Lista blanca reseteada para este grupo")
			return false
		end
		--del
		if blocks[2] == "del" then
			if (not msg.entities) or (#msg.entities == 1 and msg.entities[1].offset == 0) or (#msg.entities == 0) then
				api.sendMessage(msg.chat.id, "ℹ️ Introduce una lista de canales a eliminar en este grupo")
				return false
			end
			canales = db:hget('chat:'..msg.chat.id..':settings', 'listablanca')
			if canales == nil or canales == "" then
				api.sendReply(msg, "ℹ️ No hay ningun canal en la lista blanca para eliminar")
				return false
			end
			t1 = {}
			for _,entity in pairs(msg.entities) do
				canal = trim(string.sub(msg.text, entity.offset+1, entity.offset+entity.length+1))
				canales = string.gsub(canales, ","..canal, "")
			end
			db:hset('chat:'..msg.chat.id..':settings', 'listablanca', canales)
			api.sendReply(msg, "🔁 Canal/es eliminado/s de la lista blanca de este grupo")
			return false
		end
		--show
		if blocks[2] == "show" then
			canales = db:hget('chat:'..msg.chat.id..':settings', 'listablanca')
			if canales == nil or canales == "" then
				api.sendReply(msg, "ℹ️ No hay ningun canal en la lista blanca")
				return false
			else
				api.sendReply(msg, "✅ Lista de canales *permitidos* en este grupo:\n"..string.gsub(trim(string.gsub(canales, ",", " ")), " ", ", ").." y por último, pero no por ello menos importante: @APirateK\n\n*Al poner algun alias de esa lista, no seras expulsado.*", true)
				return false
			end
		end

		if blocks[2] == "help" then
			api.sendReply(msg, [[
*Comandos de lb (lista blanca)*
`!lb set <canales>` - Inicia una nueva lista blanca con los canales especificados
`!lb add <canales>` - Añade canales a una lista blanca ya existente.
`!lb del <canales>` - Elimina uno o varios canales de la lista blanca.
`!lb show` - Muestra la lista de canales permitidos.
`!lb reset` - Elimina todos los canales de la lista blanca
*Recuerda tener el antispam activado *para que esto funcione*
*Algunos ejemplos:*
`!lb set` @micanal1 @micanal2
`!lb add` @micanal3
`!lb del` @micanal1 @micanal2
`Los canales que no esten en la lista blanca de este grupo, seran detectados como spam y el usuario sera` *expulsado*
			]], true)
			return false
		end
	end

	if msg.chat.type == 'private' or roles.is_admin_cached(msg) then return true end

    local antispamp_status = (db:hget('chat:'..msg.chat.id..':antispam', 'AntispamPro')) or 'kick'
    if antispamp_status == 'notalwd' or antispamp_status == 'ban' then
		canales = db:hget('chat:'..msg.chat.id..':settings', 'listablanca')
		canales = "@apiratek,@wamodss,@GroupButlerEsp"..n2s(canales)
		listablanca={}
		for i,alias in pairs(canales:split(",")) do
			listablanca[#listablanca+1] = alias
		end
		for _,canal in pairs(blocks) do
			for _,alias in pairs(listablanca) do
				if canal:lower() == alias:lower() then goto continue end
			end

			chat = api.getChat(canal)
			if chat then
				if chat.ok == true then
		    	local name = misc.getnames_complete(msg, blocks)
                local iduser = msg.from.id
    	        local res
    	    if antispamp_status == 'notalwd' then
    	        res = api.kickUser(msg.chat.id, msg.from.id, ln)
    	    elseif antispamp_status == 'ban' then
    	        res = api.banUser(msg.chat.id, msg.from.id, msg.normal_group, ln)
    	    end
    	    if res then
    	        misc.saveBan(msg.from.id, 'antispam') --save ban
    	        if antispamp_status == 'notalwd' then
    	        local message = name..' ('..iduser.. ') ha sido <b>expulsad@</b> por hacer SPAM 🔨 Para conocer mas sobre el spam y los terminos, usa /spamhelp\n\n🔸 <code>Informe enviado al administrador (si está activado)</code> '
    	        api.sendMessage(msg.chat.id, message, 'html')
    	        end
    	        if antispamp_status == 'ban' then
    	            misc.addBanList(msg.chat.id, msg.from.id, name, 'Antispam')
    	            text = name.. ' ('..iduser.. ') ha sido *banead@* por hacer SPAM 🔨 Para conocer mas sobre el spam y los terminos, usa /spamhelp\n\n🔸 `Informe enviado al administrador (si está activado)` '
                    api.sendKeyboard(msg.chat.id, text, {inline_keyboard = {{{text = 'Desbanear', callback_data = 'unban:'..iduser}}}}, true)    	       
					api.sendVideo(msg.chat.id, './enviar/gif/ban.gif')
    	        end
    	        local alert_status = db:hget('chat:'..msg.chat.id..':settings', 'alert') or 'enable'
                if alert_status and alert_status == 'enable' then
    	        forwardToAdmins(msg.chat.id, msg.message_id)
				sendMessageToAdmins(msg.chat.id, '👆 SPAM en el grupo: ➡️ *'..msg.chat.title..'*')
                return true
    	    end
	  end
end
end
end
::continue::
end
	return true
end

plugin.triggers = {
	onTextMessage = {
		'(@%a[%w_][%w_][%w_][%w_]+)',
		config.cmd..'(lb) (set) (.*)$',
		config.cmd..'(lb) (reset)$',
		config.cmd..'(lb) (add) (.*)$',
		config.cmd..'(lb) (del) (.*)$',
		config.cmd..'(lb) (show)$',
		config.cmd..'(lb) (help)$'
	}
}

return plugin
