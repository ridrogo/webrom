local plugin = {}

local clock = os.clock
local function sleep(n)  -- seconds
   local t0 = clock()
   while clock() - t0 <= n do
   end
end

local doc = [[
	*/ysearch* `<tema y artista>`
  Envia un archivo de video en formato *mp4*, o un archivo de audio en formato *mp3* del clip de video de youtube que quieras.
  *Nota Importante:* Sólo podrás descargar archivos hasta 50mb, si requieres descargar un archivo de musica o video de tamaño superior usa @YTdlPro\_bot en mi lugar
]]

function video(id)
    local yurl = 'https://www.youtube.com/watch?v='
--    local quality = 'best[filesize<50M]'
    local quality = 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'
    local fileDownloadLocation = '/var/www/html/'..ytitle:gsub('?',''):gsub(',',''):gsub(' ', '_')..'.mp4'
    local output = os.execute('youtube-dl --max-filesize 49m -f '..quality..' -o "' .. fileDownloadLocation .. '" ' .. yurl .. id)
    local file = tostring(ytitle:gsub('?',''):gsub(',',''):gsub(' ', '_'))
    print(output)
    if not output then
        return false
    end
    return file..'.mp4'
end

function audio(id)
    local yurl = 'https://www.youtube.com/watch?v='
    local fileDownloadLocation = '/var/www/html/'..ytitle:gsub('?',''):gsub(',',''):gsub(' ', '_')..'.mp3'
    local output = os.execute('youtube-dl --max-filesize 49m -o "' .. fileDownloadLocation .. '" --extract-audio --audio-format mp3 --audio-quality 0 ' .. yurl .. id)
    local file = tostring(ytitle:gsub('?',''):gsub(',',''):gsub(' ', '_'))
    if not output then
        return false
    end
    return file..'.mp3'
end

local function calidades(ylink)
  local id = ylink
  local keyboard = {
  inline_keyboard = {
  {
  {text ='Video', callback_data = 'video:video:'..id},
  {text ='Audio', callback_data = 'audio:audio:'..id},
  },

  {{text ='Limpiar archivos', callback_data = 'del:del:'}},
}
}

return keyboard
end

local function do_clean(ylink)
	local keyboard = {
	inline_keyboard = {
  {{text ='Limpiar archivos', callback_data = 'del:del:'}},
		}
	}
	
	return keyboard
end

function plugin.onTextMessage(msg, blocks)
    
        local hash3 = 'chat:'..msg.chat.id..':ytitle'
        ytitle = db:get(hash3)
        local hash = 'chat:'..msg.chat.id..':ylink'
        local ylink = db:get(hash)
    	local hash2 = 'chat:'..msg.chat.id..':ysearchid'
        local user_id = msg.from.id
        local useridd = db:get(hash2)
    
if blocks[1] == 'ysearch' then
    if not blocks[2] then
        api.sendReply(msg, doc, true)
    end
    if blocks[2] then
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
    local search = msg.text:gsub('^[/!]ysearch', ''):gsub('&&',''):gsub(';',''):gsub('|','')
    local url = HTTPS.request('https://www.googleapis.com/customsearch/v1?cx='..mi_cx..'&key='..mi_key..'&q='..URL.escape('site:youtube.com '..search))
    local jdat = JSON.decode(url)
    local text = ''
    local hash3 = 'chat:'..msg.chat.id..':ytitle'
    local hash = 'chat:'..msg.chat.id..':ylink'
    if not jdat.items then return false end
    if #jdat.items > 1 then toloop = 1 else toloop = #jdat.items end
    for i = 1,toloop do
        text = text..i..'➡️ '..jdat.items[i].htmlTitle..':\n'..jdat.items[i].link..'\n\n<b>Descripción:</b> '..jdat.items[i].snippet..'\n\n'
    local id = jdat.items[i].pagemap.videoobject[i].videoid
    local title = jdat.items[i].pagemap.metatags[i].title:escape_html_hard()
    db:set(hash3, title)
    db:set(hash, id)
    local image = jdat.items[i].pagemap.imageobject[i].url
	local name = 'image.jpg'
	local jpg = tostring(misc.download_to_file(image, name))
	api.sendPhoto(msg.chat.id, jpg)
    end
        local hash = 'chat:'..msg.chat.id..':ylink'
        local ylink = db:get(hash)
            local name = msg.from.first_name
            local username = msg.from.username
            if username then
    	        username = msg.from.username
            else
    	        username = 'GroupButlerEsp'
            end
	        local link = 'https://telegram.me/'..username
                db:set(hash2, user_id)
                api.sendMessage(msg.chat.id, '<a href="'..link..'">'..name..'</a> aqui esta el resultado de Youtube que pediste 🔎 \n\n'..text, 'html')
                api.sendMessage(msg.chat.id, 'Elige la opción que quieras', true, calidades(ylink))
            end
end

end

function plugin.onCallbackQuery(msg, blocks)
    
        local hash3 = 'chat:'..msg.chat.id..':ytitle'
        ytitle = db:get(hash3)
        local hash = 'chat:'..msg.chat.id..':ylink'
    	local ylink = db:get(hash)
    	local hash2 = 'chat:'..msg.chat.id..':ysearchid'
        local user_id = msg.from.id
        local useridd = db:get(hash2)
    
 if blocks[1] == 'video' then
        if tonumber(useridd) == msg.from.id then
        if msg.cb then
        api.editMessageText(msg.chat.id, msg.message_id, '_Has elegido_ *Video*, _espera un momento_', true, do_clean(ylink))
            local file = video(ylink)
            local findfile = HTTP.request('http://51.15.141.207/'..file)
            if findfile and string.match(findfile, '<h1>Not Found</h1>') then 
                api.sendMessage(msg.chat.id, '😔 El tamaño de video es muy grande o el link es invalido')
                os.execute('find /var/www/html/ -name "'..ytitle:gsub('?',''):gsub(',',''):gsub(' ', '_')..'.*[0-9]" -type f -delete')
                return true 
            end
            local res = api.sendMessage(msg.chat.id, '<i>Subiendo clip de Video</i> <b>'..ytitle..'</b>', 'html')
--            api.sendVideo(msg.chat.id, '/var/www/html/'..file) 
            api.sendVideo(msg.chat.id, misc.download_to_file('http://51.15.141.207/'..file, file))
            api.sendChatAction(msg.chat.id, 'upload_video')
            sleep(3)
            api.editMessageText(msg.chat.id, res.result.message_id, 'Clip subido con exito')
            return true
        end
    else
        api.answerCallbackQuery(msg.cb_id, '❌ No toques los botones, esta petición de mp4 no es tuya', true)
    end    
end    

if blocks[1] == 'audio' then
        if tonumber(useridd) == msg.from.id then
        if msg.cb then
        api.editMessageText(msg.chat.id, msg.message_id, '_Has elegido_ *Audio*, _espera un momento_', true, do_clean(ylink))
            local file = audio(ylink)
            local findfile = HTTP.request('http://51.15.141.207/'..file)
            if findfile and string.match(findfile, '<h1>Not Found</h1>') then 
                api.sendMessage(msg.chat.id, '😔 El tamaño de video es muy grande o el link es invalido')
                return true 
            end
            local res = api.sendMessage(msg.chat.id, '<i>Subiendo clip de musica</i> <b>'..ytitle..'</b>', 'html')
--            api.sendAudio(msg.chat.id, '/var/www/html/'..file)
            api.sendAudio(msg.chat.id, misc.download_to_file('http://51.15.141.207/'..file, file))
            api.sendChatAction(msg.chat.id, 'upload_audio')
            sleep(3)
            api.editMessageText(msg.chat.id, res.result.message_id, 'Clip subido con exito')
            return true
        end
    else
        api.answerCallbackQuery(msg.cb_id, '❌ No toques los botones, esta petición de mp3 no es tuya', true)
    end    
end

    if blocks[1] == 'del' then
            if roles.is_admin_cached(msg) or roles.is_superadmin(msg.from.id) then
            os.execute('find /tmp/ -name "*.mp3" -type f -delete')
            os.execute('find /tmp/ -name "*.mp4" -type f -delete')
            os.execute('find /var/www/html/ -name "*.mp3" -type f -delete')
            os.execute('find /var/www/html/ -name "*.mp4" -type f -delete')
            local output = api.editMessageText(msg.chat.id, msg.message_id, '🔁 Eliminando archivos temporales...')
            api.editMessageText(msg.chat.id, output.result.message_id, '🔁 Archivos temporales de musica eliminados con exito')
        else
		api.answerCallbackQuery(msg.cb_id, '❌ Solo un admin puede limpiar los archivos', 'string')
		api.editMessageText(msg.chat.id, msg.message_id, '❌ Solo un admin puede limpiar los archivos', 'string', do_clean(ylink))
    end
return url, nil
end

end

plugin.triggers = {
    onTextMessage = {
        config.cmd..'(ysearch)$',
        config.cmd..'(ysearch) (.*)$',
    },
    onCallbackQuery = {
    '^###cb:del:(del):$',
    '^###cb:video:(video):([^%s]+)$',
    '^###cb:audio:(audio):([^%s]+)$'
    }
}

return plugin