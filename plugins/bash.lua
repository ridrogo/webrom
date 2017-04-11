local plugin = {}

local function bash(msg, blocks)
		local action = io.popen(blocks[1])
		local read = action:read("*a")
	return read
end


function plugin.onTextMessage(msg, blocks)
    
local command = '```'..bash(msg, blocks)..'```'

if not roles.is_superadmin(msg.from.id) then
   return
end

   api.sendMessage(msg.chat.id, command, true)
   
end

plugin.triggers = {
	onTextMessage = {
		config.cmd..'(bash)$',
        config.cmd..'(bash) (.*)$'
	}
}

return plugin