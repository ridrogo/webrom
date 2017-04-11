local plugin = {}

local doc = [[
	*/tts* `<idioma> <mensaje>`
  Envia un archivo de audio en formato *mp3*, del mensaje escrito por ti, idiomas soportados: en, es, it, fr, ar, entre otros.
]]

function plugin.onTextMessage(msg, blocks)

local hash = 'chat:'..msg.chat.id..':tts'
local texto = blocks[3] or misc.input_from_msg(msg)
local tts = db:get(hash)
local lang = blocks[2] or 'es'
print(tts)
if blocks[1] == 'tts' then
if not msg.reply and not texto then
    api.sendReply(msg, doc, true)
    return
end
local texto = blocks[3] or misc.input_from_msg(msg)
db:set(hash, texto)
api.sendVoice(msg.chat.id, misc.download_to_file('http://tts.baidu.com/text2audio?lan='.. lang ..'&ie=UTF-8&text=' .. URL.escape(texto:lower()), os.time() .. '.mp3'))
sleep(5)
api.sendKeyboard(msg.chat.id, 'Texto del mensaje', {inline_keyboard = {{{text = 'Mensaje', callback_data = 'ttsbuttom:ttss:'}}}}, true)
end

end

function plugin.onCallbackQuery(msg, blocks)

local hash = 'chat:'..msg.chat.id..':tts'
local tts = db:get(hash)

if blocks[1] == 'ttss' then
    print(tts)
    message = ''..tts
    api.answerCallbackQuery(msg.cb_id, message, true)
    return
end

end 

plugin.triggers = {
    onTextMessage = {
        config.cmd..'tts$',
        config.cmd..'(tts) (%a%a) ([^%s].*)$',
        config.cmd..'(tts) ([^%s].*)$',
    },
    onCallbackQuery = {
'^###cb:ttsbuttom:(ttss):$',
    }
}

return plugin