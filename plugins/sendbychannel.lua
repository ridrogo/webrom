local plugin = {}

function plugin.onTextMessage(msg, blocks)
    
if msg.text:match('/enviar (%d+)') then
local gbannedid = msg.text:match('(%d+)')
print(gbannedid)
local user = api.resolveUsernameTG(gbannedid, msg.chat.id)
local grep = io.popen("grep "..gbannedid.." ./data/gbans.lua")
local list = grep:read("*a")
if list == "" then
    api.sendMessage(msg.chat.id, "No encontrado en base de datos")
    return false
else
                        fotos = db:smembers("test:"..gbannedid)
                        for k,v in pairs(fotos) do
                                print(v)
                                api.sendPhotoId(msg.chat.id, v)
                            end
                        api.sendMessage(msg.chat.id, "Pruebas de \n"..user.." \n*Enviada correctamente*", "string")
                        return false
                    end
                end
end

function plugin.onChannelPost(msg, blocks)

--        if roles.is_admin_cached(msg) or roles.is_superadmin(msg.from.id) then
if msg.text:match('/agregar (%d+)') and msg.reply then
local gbannedid = msg.text:match('(%d+)')   
local user = api.resolveUsernameTG(gbannedid, msg.chat.id)
if gbannedid then
    if msg.reply.photo then
        db:sadd("test:"..gbannedid, msg.reply.photo[1].file_id)
        print(msg.reply.photo[1].file_id)
        end
        api.sendMessage(msg.chat.id, "Foto Seteada Correctamente a\n "..user.." \n*Global Baneado*", "string")
        end
    end
end

plugin.triggers = {
    onTextMessage = {
        config.cmd..'enviar .*$',
        config.cmd..'enviar$',
    },
    onChannelPost = {
        config.cmd..'agregar .*$',      
        config.cmd..'agregar$',
    }
}

return plugin