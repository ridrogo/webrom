local plugin = {}

--GBAN
local function user_gbanned(msg)
local var = false
  for v,users in pairs(gbans.gbans) do
    if msg.from.id == users then
      var = true
      if msg.from.username then
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name.."(@"..msg.from.username..")")
      else
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name)
      end
    end
  end
  return var
end

local function user_gbanned_pfilos(msg)
local var = false
  for v,users in pairs(gbans.pfilos) do
    if msg.from.id == users then
      var = true
      if msg.from.username then
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name.."(@"..msg.from.username..")")
      else
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name)
      end
    end
  end
  return var
end

local function user_gbanned_pedofilos(msg)
local var = false
  for v,users in pairs(pfilos.gbans) do
    if msg.from.id == users then
      var = true
      if msg.from.username then
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name.."(@"..msg.from.username..")")
      else
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name)
      end
    end
  end
  return var
end

local function user_gbanned_spammers(msg)
local var = false
  for v,users in pairs(gbans.spammers) do
    if msg.from.id == users then
      var = true
      if msg.from.username then
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name.."(@"..msg.from.username..")")
      else
      	print("Usuario globalmente baneado ("..msg.from.id..")", msg.from.first_name)
      end
    end
  end
  return var
end

local function max_reached(chat_id, user_id)
    local max = tonumber(db:hget('chat:'..chat_id..':warnsettings', 'mediamax')) or 2
    local n = tonumber(db:hincrby('chat:'..chat_id..':mediawarn', user_id, 1))
    if n >= max then
        return true, n, max
    else
        return false, n, max
    end
end

local function is_ignored(chat_id, msg_type)
    local hash = 'chat:'..chat_id..':floodexceptions'
    local status = (db:hget(hash, msg_type)) or 'no'
    if status == 'yes' then
        return true
    elseif status == 'no' then
        return false
    end
end

local function is_flooding_funct(msg)
    local spamhash = 'spam:'..msg.chat.id..':'..msg.from.id
    
    local msgs = tonumber(db:get(spamhash)) or 1
    
    local max_msgs = tonumber(db:hget('chat:'..msg.chat.id..':flood', 'MaxFlood')) or 5
    if msg.cb then max_msgs = 15 end
    
    local max_time = 5
    db:setex(spamhash, max_time, msgs+1)
    
    if msgs > max_msgs then
        return true, msgs, max_msgs
    else
        return false
    end
end

local function is_blocked(id)
	if db:sismember('bot:blocked', id) then
		return true
	else
		return false
	end
end

function plugin.onEveryMessage(msg)
    
    if not msg.inline then
    
    local msg_type = 'text'
	if msg.forward_from or msg.forward_from_chat then msg_type = 'forward' end
	if msg.media_type then msg_type = msg.media_type end
	if not is_ignored(msg.chat.id, msg_type) and not msg.edited then
        local is_flooding, msgs_sent, msgs_max = is_flooding_funct(msg)
        if is_flooding then
            local status = (db:hget('chat:'..msg.chat.id..':settings', 'Flood')) or config.chat_settings['settings']['Flood']
            if status == 'on' and not msg.cb and not roles.is_admin_cached(msg) then --if the status is on, and the user is not an admin, and the message is not a callback, then:
                local action = db:hget('chat:'..msg.chat.id..':flood', 'ActionFlood')
                local name = misc.getname_final(msg.from)
                local res, message
                --try to kick or ban
                if action == 'ban' then
        	        res = api.banUser(msg.chat.id, msg.from.id)
        	    else
        	        res = api.kickUser(msg.chat.id, msg.from.id)
        	    end
        	    --if kicked/banned, send a message
        	    if res then
        	        local log_hammered = action
        	        if msgs_sent == (msgs_max + 1) or msgs_sent == msgs_max + 5 then --send the message only if it's the message after the first message flood. Repeat after 5
        	            misc.saveBan(msg.from.id, 'flood') --save ban
        	            if action == 'ban' then
        	                message = _("%s <b>banned</b> for flood!"):format(name)
        	            else
        	                message = _("%s <b>kicked</b> for flood!"):format(name)
        	            end
        	            api.sendMessage(msg.chat.id, message, 'html')
        	        end
        	        misc.logEvent('flood', msg, {hammered = log_hammered})
        	    end
        	end
            
            if msg.cb then
                api.answerCallbackQuery(msg.cb_id, _("‼️ Please don't abuse the keyboard, requests will be ignored"))
            end
            return false --if an user is spamming, don't go through plugins
        end
    end
    
    if msg.media and msg.chat.type ~= 'private' and not msg.cb and not msg.edited then
        local media = msg.media_type
        local hash = 'chat:'..msg.chat.id..':media'
        local media_status = (db:hget(hash, media)) or 'ok'
        local out
        if not(media_status == 'ok') then
            if not roles.is_admin_cached(msg) then --ignore admins
                local status
                local name = misc.getname_final(msg.from)
                local max_reached_var, n, max = max_reached(msg.chat.id, msg.from.id)
    	        if max_reached_var then --max num reached. Kick/ban the user
    	            status = (db:hget('chat:'..msg.chat.id..':warnsettings', 'mediatype')) or config.chat_settings['warnsettings']['mediatype']
    	            --try to kick/ban
    	            if status == 'kick' then
                        res = api.kickUser(msg.chat.id, msg.from.id)
                    elseif status == 'ban' then
                        res = api.banUser(msg.chat.id, msg.from.id)
    	            end
    	            if res then --kick worked
    	                misc.saveBan(msg.from.id, 'media') --save ban
    	                db:hdel('chat:'..msg.chat.id..':mediawarn', msg.from.id) --remove media warns
    	                local message
    	                if status == 'ban' then
			    			message = _("%s <b>banned</b>: media sent not allowed!\n❗️ <code>%d/%d</code>"):format(name, n, max)
    	                else
			    			message = _("%s <b>kicked</b>: media sent not allowed!\n❗️ <code>%d/%d</code>"):format(name, n, max)
    	                end
    	                api.sendMessage(msg.chat.id, message, 'html')
    	            end
	            else --max num not reached -> warn
			    	local message = _("%s, this type of media is <b>not allowed</b> in this chat.\n(<code>%d/%d</code>)"):format(name, n, max)
	                api.sendReply(msg, message, 'html')
	            end
	            misc.logEvent('mediawarn', msg, {warns = n, warnmax = max, media = _(media), hammered = status})
    	    end
    	end
    end
    
    local rtl_status = (db:hget('chat:'..msg.chat.id..':char', 'Rtl')) or 'allowed'
    if rtl_status == 'kick' or rtl_status == 'ban' then
        local rtl = '‮'
        local last_name = 'x'
        if msg.from.last_name then last_name = msg.from.last_name end
        local check = msg.text:find(rtl..'+') or msg.from.first_name:find(rtl..'+') or last_name:find(rtl..'+')
        if check ~= nil and not roles.is_admin_cached(msg) then
            local name = misc.getname_final(msg.from)
            local res
            if rtl_status == 'kick' then
                res = api.kickUser(msg.chat.id, msg.from.id)
            elseif status == 'ban' then
                res = api.banUser(msg.chat.id, msg.from.id)
            end
    	    if res then
    	        misc.saveBan(msg.from.id, 'rtl') --save ban
    	        local message = _("%s <b>kicked</b>: RTL character in names / messages not allowed!"):format(name)
    	        if rtl_status == 'ban' then
					message = _("%s <b>banned</b>: RTL character in names / messages not allowed!"):format(name)
    	        end
    	        api.sendMessage(msg.chat.id, message, 'html')
				return false -- not execute command already kicked out and not welcome him
    	    end
        end
    end
    
    if msg.text and msg.text:find('([\216-\219][\128-\191])') then
        local arab_status = (db:hget('chat:'..msg.chat.id..':char', 'Arab')) or 'allowed'
        if arab_status == 'kick' or arab_status == 'ban' then
    	    if not roles.is_admin_cached(msg) then
    	        local name = misc.getname_final(msg.from)
    	        local res
    	        if arab_status == 'kick' then
    	            res = api.kickUser(msg.chat.id, msg.from.id)
    	        elseif arab_status == 'ban' then
    	            res = api.banUser(msg.chat.id, msg.from.id)
    	        end
    	        if res then
    	            misc.saveBan(msg.from.id, 'arab') --save ban
    	            local message = _("%s <b>kicked</b>: arab/persian message detected!"):format(name)
    	            if arab_status == 'ban' then
						message = _("%s <b>banned</b>: arab/persian message detected!"):format(name)
    	            end
    	            api.sendMessage(msg.chat.id, message, 'html')
					return false
    	        end
            end
        end
    end
    
if msg.media and msg.chat.type == 'private' then
    local BASE_URL = 'https://api.telegram.org/file/bot' .. config.bot_api_key
    
    if not msg.document then
    	return msg, true
    else
    if msg.document.file_name == 'gbans.lua' then

    local file = api.getFile(msg.document.file_id)
    if not file then
        api.sendReply(msg, 'I couldn\'t get this file, it\'s probably too old.')
    end
    local success = tostring(misc.download_to_file(BASE_URL .. '/' .. file.result.file_path:gsub('//', '/'):gsub('/$', ''), msg.document.file_name))
    if not success then
        api.sendReply(msg, 'There was an error whilst retrieving this file.') 
    end

    local output = api.sendMessage(msg.chat.id, 'Subido archivo correctamente al servidor - lo encontrarás aquí: <code>' .. config.fileDownloadLocation .. msg.document.file_name:escape_html() .. '</code>!', 'html')

    if output then
    sleep(3)
	io.popen('mv /tmp/gbans.lua /tmp/pfilos.lua && cp /tmp/pfilos.lua /root/GBot/data/')
	api.sendMessage(msg.chat.id, 'Listado Anticp actualizado, créditos a Juan (@Maskaos)', true)
	end
end
	end
end

    end --if not msg.inline then [if statement closed]
    
    if is_blocked(msg.from.id) then --ignore blocked users
        return false --if an user is blocked, don't go through plugins
    end
    
    --don't return false for edited messages: the antispam need to process them
    if user_gbanned(msg) then
     local admin = api.getChatMember(msg.chat.id, msg.from.id)
	 if admin then
    if admin.result.status == "creator" or admin.result.status == "administrator" then
     api.leaveChat(msg.chat.id)
    end
  end
        local id = msg.from.id
		local name = misc.getnames_complete(msg, blocks)
		if msg.chat.type == "supergroup" or msg.chat.type == "group" then
  		local res = api.banUser(msg.chat.id, msg.from.id)
		if res then
            api.sendMessage(msg.chat.id, 'Usuario ' ..name.. ' ID '..id..' <b>Baneado Globalmente</b> y puesto en lista negra, contacta con @webrom_bot si crees que esto en un error.', 'html')
            api.sendVideo(msg.chat.id, './enviar/gif/fuera.mp4')
        end
    return msg, true --if an user is blocked, don't go through plugins
	end
end

    if user_gbanned_pedofilos(msg) then
    local admin = api.getChatMember(msg.chat.id, msg.from.id)
	 if admin then
    if admin.result.status == "creator" or admin.result.status == "administrator" then
     api.leaveChat(msg.chat.id)
    end
  end
        local id = msg.from.id
		local name = misc.getnames_complete(msg, blocks)
		if msg.chat.type == "supergroup" or msg.chat.type == "group" then
  		local res = api.banUser(msg.chat.id, msg.from.id)
		if res then
            api.sendMessage(msg.chat.id, 'Usuario ' ..name.. ' ID '..id..' <b>PEDÓFILO Baneado Globalmente</b> y puesto en lista negra, contacta con @webrom_bot si crees que esto en un error.', 'html')
            api.sendVideo(msg.chat.id, './enviar/gif/fuera.mp4')
        end
    return msg, true --if an user is blocked, don't go through plugins
end
end

    if user_gbanned_pfilos(msg) then
    	     local admin = api.getChatMember(msg.chat.id, msg.from.id)
	 if admin then
    if admin.result.status == "creator" or admin.result.status == "administrator" then
     api.leaveChat(msg.chat.id)
    end
  end
        local id = msg.from.id
		local name = misc.getnames_complete(msg, blocks)
		if msg.chat.type == "supergroup" or msg.chat.type == "group" then
  		local res = api.banUser(msg.chat.id, msg.from.id)
		if res then
            api.sendMessage(msg.chat.id, 'Usuario ' ..name.. ' ID '..id..' <b>PEDÓFILO Baneado Globalmente</b> y puesto en lista negra, contacta con @webrom_bot si crees que esto en un error.', 'html')
            api.sendVideo(msg.chat.id, './enviar/gif/fuera.mp4')
        end
    return msg, true --if an user is blocked, don't go through plugins
end
end
    
    if user_gbanned_spammers(msg) then
	 local admin = api.getChatMember(msg.chat.id, msg.from.id)
	 if admin then
    if admin.result.status == "creator" or admin.result.status == "administrator" then
     api.leaveChat(msg.chat.id)
    end
  end
        local id = msg.from.id
		local name = misc.getnames_complete(msg, blocks)
		if msg.chat.type == "supergroup" or msg.chat.type == "group" then
  		local res = api.banUser(msg.chat.id, msg.from.id)
		if res then
            api.sendMessage(msg.chat.id, 'Usuario ' ..name.. ' ID '..id..' <b>SPAMMER Baneado Globalmente</b> y puesto en lista negra, contacta con @webrom_bot si crees que esto en un error.', 'html')
            api.sendVideo(msg.chat.id, './enviar/gif/fuera.mp4')
        end
    return msg, true --if an user is blocked, don't go through plugins
end
end
    
    return true
end

return plugin
