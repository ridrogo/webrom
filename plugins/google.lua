local plugin = {}

local function google(msg, blocks)
    mi_cx = '000806214854275537751:hrdxyupny-m'
    math.randomseed( os.time() );
 	var = math.random(0,5);
	if var == 0 then
   	   mi_key = config.google_key
	elseif var == 1 then
 	   mi_key = config.google_key2
	elseif var == 2 then
 	   mi_key = config.google_key3
	elseif var == 3 then
 	   mi_key = config.google_key
	elseif var == 4 then
 	   mi_key = config.google_key2
	elseif var == 5 then
 	   mi_key = config.google_key3
    end
    search = msg.text:gsub('[/!#]google', '')
    local url = HTTPS.request('https://www.googleapis.com/customsearch/v1?cx='..mi_cx..'&key='..mi_key..'&q='..URL.escape(search))
    local jdat = JSON.decode(url)
    local text = ''
    if not jdat.items then return false end
    if #jdat.items > 5 then toloop = 5 else toloop = #jdat.items end
    for i = 1,toloop do
        text = text..i..'➡️ <a href="'..jdat.items[i].link..'">'..jdat.items[i].htmlTitle..'</a>\n\n'
--        text = text..i..'➡️ '..jdat.items[i].htmlTitle..':\n'..jdat.items[i].link..'\n\n'
    end
    return text:escape_html_hard()
end

    
function plugin.onTextMessage(msg, blocks)

        if roles.is_admin_cached(msg) or roles.is_superadmin(msg.from.id) then
            local google = google(msg, blocks)
            local name = msg.from.first_name
            local username = msg.from.username
            if username then
    	        username = msg.from.username
            else
    	        username = 'GroupButlerEsp'
            end
	        local link = 'https://telegram.me/'..username
            if google then
                api.sendReply(msg, '<a href="'..link..'">'..name..'</a> aqui estan los resultados de Google que pediste 🔎 \n\n'..google, 'html')
            else
                api.sendReply(msg, 'No se han encontrado resultados', 'string')
            end
        else
            api.sendReply(msg, '🚫 No tienes permisos para hacer eso', 'string')
        end
end

function plugin.onChannelPost(msg, blocks)

--        if roles.is_admin_cached(msg) or roles.is_superadmin(msg.from.id) then
            local google = google(msg, blocks)
--            local name = msg.from.first_name
      --      local username = msg.from.username
  --          if username then
    --	        username = msg.from.username
    --        else
    	--        username = 'GroupButlerEsp'
          --  end
	        --local link = 'https://telegram.me/'..username
            if google then
                api.sendReply(msg, 'aqui estan los resultados de Google que pediste 🔎 \n\n'..google, 'html')
            else
                api.sendReply(msg, 'No se han encontrado resultados', 'string')
            end
--        else
   --         api.sendReply(msg, '🚫 No tienes permisos para hacer eso', 'string')
    end
    
function plugin.onInlineQuery(msg, blocks)
    local google = google(msg, blocks)
    api.answerInlineQuery(inline_query_id, google)
end

plugin.triggers = {
    onTextMessage = {
        config.cmd..'google$',
        config.cmd..'google .*$'
    },
    onChannelPost = {
        config.cmd..'google$',
        config.cmd..'google .*$'
    },    
    onInlineQuery = {
        config.cmd..'google$',
        config.cmd..'google .*$'
    },    
}

return plugin