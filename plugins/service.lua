local plugin = {}

function plugin.onTextMessage(msg, blocks)
	
	if not msg.service then return end
	
	if blocks[1] == 'new_chat_member:mybot' or blocks[1] == 'migrate_from_chat_id' then
		-- set the language
		--[[locale.language = db:get(string.format('lang:%d', msg.from.id)) or 'en'
		if not config.available_languages[locale.language] then
			locale.language = 'en'
		end]]

		if misc.is_blocked_global(msg.from.id) then
			api.sendMessage(msg.chat.id, _("_You (user ID: %d) are in the blocked list_"):format(msg.from.id), true)
			api.leaveChat(msg.chat.id)
			return
		end
		if config.bot_settings.admin_mode and not roles.is_superadmin(msg.from.id) then
			api.sendMessage(msg.chat.id, _("_Admin mode is on: only the bot admin can add me to a new group_"), true)
			api.leaveChat(msg.chat.id)
			return
		end
		if not roles.bot_is_admin(msg.chat.id) then
            local res = api.sendMessage(msg.chat.id, 'No puedes agregarme sin darme administración lo siento', true)
            if res then
            api.leaveChat(msg.chat.id)
        	else
   		 api.sendMessage(msg.chat.id, 'Gracias por Brindarme administración, ahora comenzará la limpieza de tu grupo, a por ello!!.', true)	
	   end
	end
		-- save language
		--[[if locale.language then
			db:set(string.format('lang:%d', msg.chat.id), locale.language)
		end]]
		misc.initGroup(msg.chat.id)

		-- send manuals
		local text
		if blocks[1] == 'new_chat_member:mybot' then
			text = _("Hola a Todos!\n"
				.. "Mi nombre es %s, y soy un bot moderador para supergrupos, gracias por darme admin, te ayudaré a administrar tu grupo.\n")
				:format(bot.first_name:escape())
		else
			text = _("Yay! This group has been upgraded. You are great! Now I can work properly :)\n")
		end
--		if not roles.is_admin_cached(msg.chat.id, bot.id) then
--			if roles.is_owner_cached(msg.chat.id, msg.from.id) then
--				text = text .. _("No soy admin en tu grupo."
--					.. "Debes hacerme admin para que uedas usarme correctamente. "
--					.. "Mira [aqui](http://telegram.me/GroupButlerEsp/1) para que puedas darme admin.\n")
--			else
--				text = text .. _("Hmm… apparently I'm not an administrator. "
--					.. "I can be more useful if I'm an admin. Ask a creator to make me an admin. "
--					.. "If he doesn't know how, there is a good [guide](https://telegram.me/GroupButler_ch/104).\n")
--			end
--		end
--		text = text .. _("I can do a lot of cool things. To discover about them, "
--				-- TODO: old link, update it
--			.. "watch this [video-tutorial](https://youtu.be/uqNumbcUyzs).")
		api.sendMessage(msg.chat.id, text, true)
	elseif blocks[1] == 'left_chat_member:mybot' then
				
		local realm_id = db:get('chat:'..msg.chat.id..':realm')
		if realm_id then
			if db:hget('realm:'..realm_id..':subgroups', msg.chat.id) then
				api.sendMessage(realm_id, _("I've been removed from %s [<code>%d</code>], one of your subgroups"):format(msg.chat.title:escape_html(), msg.chat.id), 'html')
			end
		end
		
		misc.remGroup(msg.chat.id)
	else
		misc.logEvent(blocks[1], msg)
	end
	
end

plugin.triggers = {
	onTextMessage = {
		'^###(new_chat_member:mybot)',
		'^###(new_chat_member:anybot)',
		'^###(migrate_from_chat_id)',
		'^###(left_chat_member:mybot)',
		'^###(left_chat_member:anybot)',
		'^###(pinned_message)$',
		'^###(new_chat_title)$',
		'^###(new_chat_photo)$',
		'^###(delete_chat_photo)$'
	}
}

return plugin
