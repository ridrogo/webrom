local plugin = {}

local function do_keyboard_vote(user_id)
	return {
		inline_keyboard = {
			{
				{text = _("☑ Yes"), callback_data = string.format('voteban:increase:%d', user_id)},
				{text = _("❎ No"), callback_data = string.format('voteban:decrease:%d', user_id)},
			},
			{
				{text = _("Usuarios"), callback_data = string.format('voteban:usuarios:%d', user_id)},
				{text = '➖', callback_data = string.format('usuarios:dim:%d', user_id)},
		    	{text = '➕', callback_data = string.format('usuarios:raise:%d', user_id)},
--				{text = _("Duracion"), callback_data = string.format('voteban:duracion:%d', user_id)},
			},
			{
				{text = _("Revoke the vote"), callback_data = string.format('voteban:revoke:%d', user_id)},
				{text = _("Cancel the poll"), callback_data = string.format('voteban:cancel:%d', user_id)},
			},
		}
	}
end

-- return text of messages with current information about ballot
local function get_header(initiator, defendant, supports, oppositionists, quorum, expired, informative, previous_exists)
	assert(supports + oppositionists < quorum)
	assert(not informative  -- the usual poll
		or informative == 'against bot'  -- attempt to ban the bot
		or informative == 'against himself'  -- attempt to ban himself
		or informative == 'against admin'  -- attempt to ban an admin
		or informative == 'bot not admin')  -- the bot isn't an admin
	local lines = {}
	
	if previous_exists then
		table.insert(lines, _("ℹ This is _continuation_ of the previous poll."))
	end

	if defendant.id == initiator.id then
		table.insert(lines, _("%s suggests to ban himself. Ban him?\n"):format(full_name(initiator)))
	elseif defendant.id == bot.id then
		table.insert(lines, _("%s suggests to ban me. Do you really want to ban me? 😓\n"):format(full_name(initiator)))
	else
		table.insert(lines, _("%s suggests to ban %s. Ban him?\n"):format(full_name(initiator), full_name(defendant)))
	end

	-- TODO: make plural forms
	table.insert(lines, _("🔨 %d users voted *for ban*."):format(supports))
	table.insert(lines, _("❎ %d users voted *against ban*."):format(oppositionists))
	table.insert(lines, _("❗ Requires additional %d users."):format(quorum - supports - oppositionists))
	table.insert(lines, _("🕒 The poll will be automatically closed in %d minutes"):format((expired - os.time()) / 60))

	if informative == 'against bot' then
		table.insert(lines, _("\n*Informative poll*. You can't vote for ban me."))
	end
	if informative == 'against himself' then
		table.insert(lines, _("\n*Informative poll*. You can't vote for ban yourself."))
	end
	if informative == 'against admin' then
		table.insert(lines, _("\n*Informative poll*. User won't banned because he is an admin."))
	end
	if informative == 'bot not admin' then
		-- TODO: add info about how to make the bot admin
		table.insert(lines, _("\n*Informative poll*. User won't banned because I'am not an admin."))
	end

	return table.concat(lines, '\n')
end

-- return text of messages with information about a finished poll
local function conclusion(initiator, defendant, supports, oppositionists, quorum, upshot, informative)
	assert(not upshot and informative  -- that was informative poll
		or upshot == 'was banned'  -- the user was successfull banned
		or upshot == 'bot not admin'  -- ban fail, because the bot ceased to be an admin
		or upshot == 'already admin'  -- ban fail, because the user became an admin
		or upshot == 'was protected'  -- a community interceded for the user
		or upshot == 'no decision'  -- the voting time has expired
		or upshot == 'canceled')  -- the poll was closed by initiator
	assert(not informative  -- the usual poll
		or informative == 'against bot'  -- attempt to ban the bot
		or informative == 'against himself'  -- attempt to ban himself
		or informative == 'against admin'  -- attempt to ban an admin
		or informative == 'bot not admin')  -- the bot was not an admin
	assert(supports + oppositionists == quorum and supports > oppositionists and upshot == 'was banned'
		or supports + oppositionists == quorum and supports > oppositionists and upshot == 'bot not admin'
		or supports + oppositionists == quorum and supports > oppositionists and upshot == 'already admin'
		or supports + oppositionists == quorum and supports <= oppositionists and upshot == 'was protected'
		or supports + oppositionists == quorum and not upshot and informative
		or supports + oppositionists < quorum and upshot == 'no decision'
		or supports + oppositionists < quorum and upshot == 'canceled')
	local lines = {}

	local defendant_name = full_name(defendant)
	if upshot == 'was banned' then
		table.insert(lines, _("The voting was closed, and %s was banned according "
			.. "to decision of community. The results:\n"):format(defendant_name))
	end
	if upshot == 'bot not admin' then
		table.insert(lines, _("⚠ The voting was closed, a community decided ban %s, "
			.. "but error ocured while ban this user, because I ceased to be "
			.. "_an admin_. The results:\n"):format(defendant_name))
	end
	if upshot == 'already admin' then
		table.insert(lines, _("⚠ The voting was closed, a community decided ban %s, "
			.. "but error ocured while ban this user, because he became "
			.. "_an admin_. The results:\n"):format(defendant_name))
	end
	if upshot == 'was protected' then
		table.insert(lines, _("The voting was closed. %s suggested to ban %s, but "
			.. "a community protected him. The results:\n")
			:format(full_name(initiator), full_name(defendant)))
	end
	if upshot == 'no decision' then
		table.insert(lines, _("The voting was closed, because not get enough number of people "
			.. "for ban %s. The results:\n"):format(full_name(defendant)))
	end
	if upshot == 'canceled' then
		table.insert(lines, _("The poll against %s was closed by initiator. The results:\n"):format(full_name(defendant)))
	end
	if informative and not upshot then
		table.insert(lines, _("The voting was closed, but it was informative so %s hadn't "
			.. "been banned. The results:\n"):format(full_name(defendant)))
	end

	-- TODO: make plural forms
	table.insert(lines, _("🔨 %d users voted *for ban*."):format(supports))
	table.insert(lines, _("❎ %d users voted *against ban*."):format(oppositionists))
	if upshot == 'no decision' then
		table.insert(lines, _("❗ It was not enough votes from %d users"):format(quorum - supports - oppositionists))
	end

	if upshot ~= 'was protected' then
		if informative == 'against bot' then
			table.insert(lines, _("\n*That was informative poll*. Against me they can't vote."))
		end
		if informative == 'against himself' then
			table.insert(lines, _("\n*That was informative poll*. The user wanted to ban himself."))
		end
		if informative == 'against admin' then
			table.insert(lines, _("\n*That was informative poll*. User was not banned because he is an admin."))
		end
		if informative == 'bot not admin' then
			table.insert(lines, _("\n*That was informative poll*. User was banned because I'am not an admin."))
		end
	end

	return table.concat(lines, '\n')
end

local function generate_poll(msg, defendant)
	if not defendant then
		api.sendMessage(msg.chat.id, _("Against whom do you vote?"))
		return false
	end

	local hash = string.format('chat:%d:voteban', msg.chat.id)
	local quorum = tonumber(db:hget(hash, 'quorum') or config.chat_settings.voteban.quorum)
	local duration = tonumber(db:hget(hash, 'duration') or config.chat_settings.voteban.duration)

	-- Detect if previous poll was or not and set the initiator
	local hash = string.format('chat:%d:voteban:%d', msg.chat.id, defendant.id)
	local user_id = tonumber(db:hget(hash, 'initiator'))
	local initiator, was_active_previous
	if user_id and user_id ~= msg.from.id and user_id ~= defendant.id then
		-- the poll already exists. Continue it
		initiator, was_active_previous = api.getChat(user_id).result, true
	else
		-- new poll
		initiator = msg.from
		db:hdel(hash, 'informative')
		db:hset(hash, 'initiator', msg.from.id)
	end

	-- Detect informative poll
	local informative
	if defendant.id == bot.id then
		informative = 'against bot'
	elseif initiator.id == defendant.id then
		informative = 'against himself'
	elseif roles.is_admin_cached(msg.chat.id, defendant.id) then
		informative = 'against admin'
	elseif not roles.bot_is_admin(msg.chat.id) then
		informative = 'bot not admin'
	end

	-- Send the keyboard into the chat
	local supports = tonumber(db:scard(hash .. ':supports'))
	local oppositionists = tonumber(db:scard(hash .. ':oppositionists'))
	local keyboard = do_keyboard_vote(defendant.id)
	local text = get_header(initiator, defendant, supports, oppositionists,
							quorum, os.time() + duration, informative, was_active_previous)
	local res = api.sendMessage(msg.chat.id, text, true, keyboard)
	if not res then return false end

	-- Close previous poll if it exists
	local previous_id = tonumber(db:hget(hash, 'msg_id'))
	if previous_id then
		local text
		if res.result.chat.username then
			local link = string.format('https://telegram.me/%s/%d', res.result.chat.username, res.result.message_id)
			text = _("⬇ The poll for ban of %s was closed because [new poll](%s) was created")
				:format(full_name(defendant), link)
		else
			text = _("⬇ The poll for ban of %s was closed because *new poll* was created")
				:format(full_name(defendant))
		end
		api.editMessageText(msg.chat.id, previous_id, text, true)
	end

	-- Store information about new poll
	db:hset(hash, 'expired', res.result.date + duration)
	db:hset(hash, 'msg_id', res.result.message_id)
	db:hset(hash, 'quorum', quorum)
	if informative then
		db:hset(hash, 'informative', informative)
	end
	if previous_id then
		db:hset(hash, 'was_active_previous', 'yes')
	end

	return true
end

-- edits the message which was associated with the poll
local function rebuild_poll_message(chat_id, user_id, problems)
	local hash = string.format('chat:%d:voteban:%d', chat_id, user_id)
	local initiator = tonumber(db:hget(hash, 'initiator'))
	local expired = tonumber(db:hget(hash, 'expired'))
	local msg_id = tonumber(db:hget(hash, 'msg_id'))
	local quorum = tonumber(db:hget(hash, 'quorum'))
	local informative = db:hget(hash, 'informative')
	local was_active_previous = db:hget(hash, 'was_active_previous')

	local supports = tonumber(db:scard(hash .. ':supports'))
	local oppositionists = tonumber(db:scard(hash .. ':oppositionists'))
	assert(supports + oppositionists < quorum)

	local defendant = api.getChat(user_id).result
	initiator = api.getChat(initiator).result

	local keyboard = do_keyboard_vote(defendant.id)
	local text = get_header(initiator, defendant, supports, oppositionists,
							quorum, expired, informative, was_active_previous)
	return api.editMessageText(chat_id, msg_id, text, true, keyboard)
end

-- disposes the vote and returns true if decision has changed
local function cast_vote(chat_id, defendant_id, voter_id, value)
	local hash = string.format('chat:%d:voteban:%d', chat_id, defendant_id)
	if value > 0 then
		db:srem(hash .. ':oppositionists', voter_id)
		return db:sadd(hash .. ':supports', voter_id) == 1
	elseif value < 0 then
		db:srem(hash .. ':supports', voter_id)
		return db:sadd(hash .. ':oppositionists', voter_id) == 1
	else
		return db:srem(hash .. ':supports', voter_id) == 1
			or db:srem(hash .. ':oppositionists', voter_id) == 1
	end
end

-- counts of votes, edits message header and returns text for callback answer
local function change_votes_machinery(chat_id, user_id, from_id, value)
	local hash = string.format('chat:%d:voteban:%d', chat_id, user_id)
	local informative = db:hget(hash, 'informative')

	if from_id == user_id and informative ~= 'against himself' then
		return _("🚷 You can't vote about yourself")
	end

	local text, without_name
	if cast_vote(chat_id, user_id, from_id, value) then
		local supports = tonumber(db:scard(hash .. ':supports'))
		local oppositionists = tonumber(db:scard(hash .. ':oppositionists'))
		local quorum = tonumber(db:hget(hash, 'quorum'))
		if supports + oppositionists >= quorum then
			local msg_id = tonumber(db:hget(hash, 'msg_id'))
			local send_confirmation, code
			if not informative and supports > oppositionists then
				send_confirmation, code = api.banUser(chat_id, user_id)
			end

			local upshot, initiator
			if send_confirmation then
				upshot = 'was banned'
			elseif code == 101 or code == 105 or code == 107 then
				upshot = 'bot not admin'
			elseif code == 102 or code == 104 then
				upshot = 'already admin'
			elseif supports <= oppositionists then
				upshot = 'was protected'
				initiator = api.getChat(db:hget(hash, 'initiator')).result
			end
			local defendant = api.getChat(user_id).result

			local text = conclusion(initiator, defendant, supports, oppositionists, quorum, upshot, informative)
			api.editMessageText(chat_id, msg_id, text, true)

			if send_confirmation then
				local text = _("%s has been banned ✨"):format(full_name(defendant))
				api.sendMessage(chat_id, text, true, nil, msg_id)
			end
			db:del(hash, hash .. ':supports', hash .. ':oppositionists')
		else
			rebuild_poll_message(chat_id, user_id)
		end

		if value > 0 then
			text = _("☑ You have voted against %s")
		elseif value < 0 then
			text = _("❎ You have voted to save %s")
		else
			text, without_name = _("🔁 You have revoked your vote"), true
		end
	elseif value > 0 then
		text = _("☑ You already voted against %s")
	elseif value < 0 then
		text = _("❎ You already voted to save %s")
	else
		text, without_name = _("🔁 You already revoked your vote"), true
	end

	if not without_name then
		text = text:format(full_name(api.getChat(user_id).result, true))
	end
	return text
end

function plugin.cron()
	-- FIXME: they don't recommend use keys function
	for i, hash in pairs(db:keys('chat:*:voteban:*')) do
		local chat_id, user_id = hash:match('chat:(-?%d+):voteban:(-?%d+)$')
		-- lua sucks because it have no continue statement
		if not chat_id or not user_id then goto continue end

		local expired = tonumber(db:hget(hash, 'expired'))
		local msg_id = tonumber(db:hget(hash, 'msg_id'))
		if expired < os.time() then
			-- Poll is finished
			local defendant = api.getChat(user_id).result
			local supports = tonumber(db:scard(hash .. ':supports'))
			local oppositionists = tonumber(db:scard(hash .. ':oppositionists'))
			local quorum = tonumber(db:hget(hash, 'quorum'))
			local informative = db:hget(hash, 'informative')

			local text = conclusion(nil, defendant, supports, oppositionists, quorum, 'no decision', informative)
			api.editMessageText(chat_id, msg_id, text, true)

			db:del(hash, hash .. ':supports', hash .. ':oppositionists')
		else
			-- Poll is continue
			rebuild_poll_message(chat_id, user_id)
		end
		::continue::
	end
end

function plugin.onTextMessage(msg, blocks)
	if blocks[1] == 'voteban' then
		local hash = string.format('chat:%d:settings', msg.chat.id)
		local status = db:hget(hash, 'voteban') or config.chat_settings.settings.voteban
		if status == 'off' and not roles.is_admin_cached(msg) then return end
		hash = string.format('chat:%d:voteban', msg.chat.id)

		-- choose the hero
		local nominated
		if msg.mentions then
			nominated = next(msg.mentions)
			if next(msg.mentions, nominated) then
				api.sendMessage(msg.chat.id, _("*Warning*: Multiple mentions still isn't supported"), true)
			end
			-- FIXME: make that the follow variable would store the user object for decrease number of API queries
			nominated = api.getChat(nominated).result
		elseif msg.reply then
			nominated = msg.reply.from
		elseif tonumber(blocks[2]) then
			local res = api.getChatMember(msg.chat.id, blocks[2])
			-- theoretically we can vote for ban of left users
			if res and res.result.status ~= 'kicked' then
				nominated = res.result.user
			else
				api.sendMessage(msg.chat.id, _("This user isn't a chat member"))
				return
			end
		elseif blocks[2] and blocks[2]:byte(1) == string.byte('@') then
			-- FIXME: double call of getChat
			local user_id = misc.resolve_user(blocks[2])
			if not user_id then
				api.sendMessage(msg.chat.id, _("I've never seen this user before.\n"
					.. "If you want to teach me who is he, forward me a message from him"))
				return
			end
			-- FIXME: avoid copypaste
			local res = api.getChatMember(msg.chat.id, user_id)
			-- theoretically we can vote for ban of left users
			if res and res.result.status ~= 'kicked' then
				nominated = res.result.user
			else
				api.sendMessage(msg.chat.id, _("This user isn't a chat member"))
				return
			end
		end

		generate_poll(msg, nominated)
	end
end

function plugin.onCallbackQuery(msg, blocks)
	local defendant = tonumber(blocks[2])
	local hash = string.format('chat:%d:voteban', msg.chat.id)
	local quorum = tonumber(db:hget(hash, 'quorum') or config.chat_settings.voteban.quorum)
	local duration = tonumber(db:hget(hash, 'duration') or config.chat_settings.voteban.duration)
	local text
	if blocks[1] == 'increase' then
		text = change_votes_machinery(msg.chat.id, defendant, msg.from.id, 1)
	end
	if blocks[1] == 'decrease' then
		text = change_votes_machinery(msg.chat.id, defendant, msg.from.id, -1)
	end
	if blocks[1] == 'usuarios' then
		local current =	quorum
			if blocks[2] == 'dim' then
					if current > 1 then
						text = _("⚙ The new value is too low ( < 1)")
					else
						local new = db:hset(hash, 'quorum', -1)
						text = string.format('⚙ %d → %d', current, new)
					end
				elseif blocks[2] == 'raise' then
					if current > 1 then
						text = _("⚙ The new value is too high ( > 12)")
					else
						local new = db:hset(hash, 'quorum', 1)
						text = string.format('⚙ %d → %d', current, new)
					end
				end 
	end
--	if blocks[1] == 'duracion' then
--		local current = db:hset(hash, 'expired', res.result.date + duration)
--	end
	if blocks[1] == 'revoke' then
		text = change_votes_machinery(msg.chat.id, defendant, msg.from.id, 0)
	end
	if blocks[1] == 'cancel' then
		local hash = string.format('chat:%d:voteban:%d', msg.chat.id, defendant)
		local initiator = tonumber(db:hget(hash, 'initiator'))
		if msg.from.id == initiator then
			defendant = api.getChat(defendant).result
			local supports = tonumber(db:scard(hash .. ':supports'))
			local oppositionists = tonumber(db:scard(hash .. ':oppositionists'))
			local quorum = tonumber(db:hget(hash, 'quorum'))
			local informative = db:hget(hash, 'informative')

			local text = conclusion(nil, defendant, supports, oppositionists, quorum, 'canceled', informative)
			api.editMessageText(msg.chat.id, msg.message_id, text, true)
			db:del(hash, hash .. ':supports', hash .. ':oppositionists')
		elseif roles.is_admin_cached(msg.chat.id, msg.from.id) then
			api.editMessageText(msg.chat.id, msg.message_id, _("The poll was closed by administrator"))
			db:del(hash, hash .. ':supports', hash .. ':oppositionists')
		else
			text = _("🚷 Only administrators or initiator can close the poll")
		end
	end
	if text then
		api.answerCallbackQuery(msg.cb_id, text)
	end
end

plugin.triggers = {
	onTextMessage = {
		config.cmd..'(voteban) ([^%s]*) ?(.*)',
		config.cmd..'(voteban)$',
	},
	onCallbackQuery = {
		'^###cb:voteban:(.*):(-?%d+)$',
		'^###cb:usuarios:(%a+):(-?%d+)',
	},
}

return plugin