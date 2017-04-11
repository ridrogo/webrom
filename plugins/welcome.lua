local plugin = {}

local function user_in_gbans(msg)
local var = false
  for v,users in pairs(gbans.gbans) do
     if msg.new_chat_member.id == users then
     var = true
     if msg.new_chat_member.username then
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name.."(@"..msg.new_chat_member.username:escape()..")")
      else
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name)
      end
     end
  end
  return var
end

local function user_in_gbans_pfilos(msg)
local var = false
  for v,users in pairs(gbans.pfilos) do
     if msg.new_chat_member.id == users then
     var = true
     if msg.new_chat_member.username then
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name.."(@"..msg.new_chat_member.username:escape()..")")
      else
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name)
      end
     end
  end
  return var
end

local function user_in_gbans_pedofilos(msg)
local var = false
  for v,users in pairs(pfilos.gbans) do
     if msg.new_chat_member.id == users then
     var = true
     if msg.new_chat_member.username then
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name.."(@"..msg.new_chat_member.username:escape()..")")
      else
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name)
      end
     end
  end
  return var
end

local function user_in_gbans_spammers(msg)
local var = false
  for v,users in pairs(gbans.spammers) do
     if msg.new_chat_member.id == users then
     var = true
     if msg.new_chat_member.username then
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name.."(@"..msg.new_chat_member.username:escape()..")")
      else
      	print("Usuario globalmente baneado ("..msg.new_chat_member.id..")", msg.new_chat_member.first_name)
      end
     end
  end
  return var
end

local function grep_added(msg, blocks)
		local action = io.popen('grep -rn "'..msg.target_id..'" ./data/gbans.lua')
		local read = action:read("*a")
		return read
end

local function do_ban(user_id)
	local keyboard = {
		inline_keyboard = {
			{
			{text ='Banear', callback_data = 'banbutton:eliminar:'..user_id},
			{text ='Permitir', callback_data = 'banbutton:permitir:'..user_id},
			},
		}
    }
	
	return keyboard
end

local function is_locked(chat_id, thing)
  	local hash = 'chat:'..chat_id..':settings'
  	local current = db:hget(hash, thing)
  	if current == 'off' then
  		return true
  	else
  		return false
  	end
end

local function get_welcome(msg)
	if is_locked(msg.chat.id, 'Welcome') then
		return false
	end
	local type = (db:hget('chat:'..msg.chat.id..':welcome', 'type')) or config.chat_settings['welcome']['type']
	local content = (db:hget('chat:'..msg.chat.id..':welcome', 'content')) or config.chat_settings['welcome']['content']
	if type == 'media' then
		local file_id = content
		api.sendDocumentId(msg.chat.id, file_id)
		return false
	elseif type == 'custom' then
		return content:replaceholders(msg)
	else
		return _("Hi %s, and welcome to *%s*!"):format(msg.new_chat_member.first_name:escape(), msg.chat.title:escape_hard('bold'))
	end
end

local function get_goodbye(msg)
	if is_locked(msg.chat.id, 'Goodbye') then
		return false
	end
	local type = db:hget('chat:'..msg.chat.id..':goodbye', 'type') or 'custom'
	local content = db:hget('chat:'..msg.chat.id..':goodbye', 'content')
	if type == 'media' then
		local file_id = content
		api.sendDocumentId(msg.chat.id, file_id)
		return false
	elseif type == 'custom' then
		if not content then
			local name = msg.left_chat_member.first_name:escape()
			if msg.left_chat_member.username then
				name = name:escape() .. ' (@' .. msg.left_chat_member.username:escape() .. ')'
			end
			return _("Goodbye, %s!"):format(name)
		end
		return content:replaceholders(msg)
	end
end

function plugin.onTextMessage(msg, blocks)
    if blocks[1] == 'welcome' then
        
        if msg.chat.type == 'private' or not roles.is_admin_cached(msg) then return end
        
        local input = blocks[2]
        
        if not input and not msg.reply then
			api.sendReply(msg, _("Welcome and...?")) return
        end
        
        local hash = 'chat:'..msg.chat.id..':welcome'
        
        if not input and msg.reply then
            local replied_to = misc.get_media_type(msg.reply)
            if replied_to == 'sticker' or replied_to == 'gif' then
                local file_id
                if replied_to == 'sticker' then
                    file_id = msg.reply.sticker.file_id
                else
                    file_id = msg.reply.document.file_id
                end
                db:hset(hash, 'type', 'media')
                db:hset(hash, 'content', file_id)
                api.sendReply(msg, _("A form of media has been set as the welcome message: `%s`"):format(replied_to), true)
            else
                api.sendReply(msg, _("Reply to a `sticker` or a `gif` to set them as the *welcome message*"), true)
            end
        else
            db:hset(hash, 'type', 'custom')
            db:hset(hash, 'content', input)
            local res, code = api.sendReply(msg, input:gsub('$rules', misc.deeplink_constructor(msg.chat.id, 'rules')), true)
            if not res then
                db:hset(hash, 'type', 'no') --if wrong markdown, remove 'custom' again
                db:hset(hash, 'content', 'no')
                api.sendMessage(msg.chat.id, misc.get_sm_error_string(code), true)
            else
                local id = res.result.message_id
                api.editMessageText(msg.chat.id, id, _("*Custom welcome message saved!*"), true)
            end
        end
    end
	if blocks[1] == 'goodbye' then
		if msg.chat.type == 'private' or not roles.is_admin_cached(msg) then return end

		local input = blocks[2]
		local hash = 'chat:'..msg.chat.id..':goodbye'

		-- ignore if not input text and not reply
		if not input and not msg.reply then
			api.sendReply(msg, _("No goodbye message"), false)
			return
		end

		if not input and msg.reply then
			local replied_to = misc.get_media_type(msg.reply)
			if replied_to == 'sticker' or replied_to == 'gif' then
				local file_id
				if replied_to == 'sticker' then
					file_id = msg.reply.sticker.file_id
				else
					file_id = msg.reply.document.file_id
				end
				db:hset(hash, 'type', 'media')
				db:hset(hash, 'content', file_id)
				api.sendReply(msg, _("New media setted as goodbye message: `%s`"):format(replied_to), true)
			else
				api.sendReply(msg, _("Reply to a `sticker` or a `gif` to set them as *goodbye message*"), true)
			end
			return
		end

		input = input:gsub('^%s*(.-)%s*$', '%1') -- trim spaces
		db:hset(hash, 'type', 'custom')
		db:hset(hash, 'content', input)
		local res, code = api.sendReply(msg, input, true)
		if not res then
			db:hset(hash, 'type', 'composed') --if wrong markdown, remove 'custom' again
			db:hset(hash, 'content', 'no')
			api.sendMessage(msg.chat.id, misc.get_sm_error_string(code), true)
		else
			local id = res.result.message_id
			api.editMessageText(msg.chat.id, id, _("*Custom goodbye message saved!*"), true)
		end
	end
    if blocks[1] == 'new_chat_member' then
		if not msg.service then return end
		
--[[		if msg.new_chat_member.username then
			local username = msg.new_chat_member.username:lower()
			if username:find('bot', -3) then
				return
			end
		end]]
		
	if msg.new_chat_member.first_name:find('([\216-\219][\128-\191])') or msg.new_chat_member.last_name and msg.new_chat_member.last_name:find('([\216-\219][\128-\191])') then
		local user_id = msg.new_chat_member.id
		local keyboard = do_ban(user_id)
		local name
		if msg.new_chat_member.first_name and msg.new_chat_member.last_name then
			name = msg.new_chat_member.first_name:gsub('([%w_])','') and msg.new_chat_member.last_name:gsub('([%w_])','')
		elseif msg.new_chat_member.first_name and not msg.new_chat_member.last_name then
			name = msg.new_chat_member.first_name:gsub('([%w_])','')
		elseif msg.new_chat_member.last_name and not msg.new_chat_member.first_name then
			name = msg.new_chat_member.last_name:gsub('([%w_])','')
		end
		api.sendMessage(msg.chat.id, '<b>Usuario ID:</b> ' ..user_id.. ' tiene nombre y/o apellido árabe ('..name..')', 'html', keyboard)
--		api.sendMessage(msg.chat.id, '_Usuario ID:_ *' ..user_id.. '* tiene nombre y/o apellido árabe *('..name..')*, \n', 'string')
		return
	end

	if user_in_gbans(msg) or user_in_gbans_pfilos(msg) or user_in_gbans_spammers(msg) or user_in_gbans_pedofilos(msg) then
		local res = api.kickChatMember(msg.chat.id, msg.new_chat_member.id)
		if res then
		api.sendMessage(msg.chat.id, '_Tú ('..msg.new_chat_member.first_name:escape()..', '..msg.new_chat_member.id..')´ , usuario en lista negra de GBAN_', true)
		end
	end
		
		local extra
		if msg.from.id ~= msg.new_chat_member.id then extra = msg.from end
		misc.logEvent(blocks[1], msg, extra)
		
		local text = get_welcome(msg)
		if text then --if not text: welcome is locked or is a gif/sticker
			local keyboard
			local attach_button = (db:hget('chat:'..msg.chat.id..':settings', 'Welbut')) or config.chat_settings['settings']['Welbut']
			if attach_button == 'on' then
				keyboard = {inline_keyboard={{{text = _('Read the rules'), url = misc.deeplink_constructor(msg.chat.id, 'rules')}}}}
			end
			api.sendMessage(msg.chat.id, text, true, keyboard)
		end
		
		local send_rules_private = db:hget('user:'..msg.new_chat_member.id..':settings', 'rules_on_join')
		if send_rules_private and send_rules_private == 'on' then
		    local rules = db:hget('chat:'..msg.chat.id..':info', 'rules')
		    if rules then
		        api.sendMessage(msg.new_chat_member.id, rules, true)
		    end
	    end
	end
	if blocks[1] == 'left_chat_member' then
		if not msg.service then return end

		if msg.left_chat_member.username and msg.left_chat_member.username:lower():find('bot', -3) then return end
		local text = get_goodbye(msg)
		if text then
			api.sendMessage(msg.chat.id, text, true)
		end
end
	if blocks[1] ==	'new_chat_member:anybot' then
			api.sendMessage(msg.chat.id, '\nBot ID: <b>'..msg.new_chat_member.id..'</b>\nAlias: (@'..msg.new_chat_member.username:escape_html()..') agregado al chat por usuario '..misc.getname_link(msg.from.first_name, msg.from.username), 'html')				
		end
end

function plugin.onCallbackQuery(msg, blocks)
    if blocks[1] == 'permitir' then
        if roles.is_admin_cached(msg) or roles.is_superadmin(msg.from.id) then
            user = misc.getnames_complete(msg, blocks)
            message = 'Árabe Permitido en este Grupo'
            api.answerCallbackQuery(msg.cb_id, message, true)
            api.editMessageText(msg.chat.id, msg.message_id, 'Árabe Permitido por admin '..user..'', 'html')
            return
        else
		api.answerCallbackQuery(msg.cb_id, '❌ Solo un admin puede  usar estos botones', true)
    end
end
	if blocks[1] == 'eliminar' then
	    if roles.is_admin_cached(msg) or roles.is_superadmin(msg.from.id) then
	       	local get = grep_added(msg, blocks)
	       	local res = api.banUser(msg.chat.id, msg.target_id)
	        if get == '' then
	    	os.execute('perl -pi -e "s[spammers = \\{][spammers = {\n\t'..msg.target_id..',\t--\tMotivo:\tspammer]g" data/gbans.lua')
            end
            if res then
            user = misc.getnames_complete(msg, blocks)
            message = 'Árabe Baneado de este Grupo'
            api.answerCallbackQuery(msg.cb_id, message, true)
            api.editMessageText(msg.chat.id, msg.message_id, 'Árabe baneado por admin '..user..' además, <b>Globalmente Baneado</b>.\n Motivo: <b>Árabe Spammer</b>', 'html')            
            return
            else
		api.answerCallbackQuery(msg.cb_id, '❌ Solo un admin puede  usar estos botones', true)
        end
    end
end
end


plugin.triggers = {
	onTextMessage = {
		config.cmd..'(welcome) (.*)$',
		config.cmd..'set(welcome) (.*)$',
		config.cmd..'(welcome)$',
		config.cmd..'set(welcome)$',
		config.cmd..'(goodbye) (.*)$',
		config.cmd..'set(goodbye) (.*)$',
		config.cmd..'(goodbye)$',
		config.cmd..'set(goodbye)$',

		'^###(new_chat_member)$',
		'^###(left_chat_member)$',
		'^###(new_chat_member:anybot)',
		'^###(left_chat_member:anybot)',
	},
	onCallbackQuery = {
		'^###cb:banbutton:(eliminar):(%d+)$',
	    '^###cb:banbutton:(permitir):(%d+)$',
	}
}

return plugin
