
local HasInitialized = false

local function Think()
	if HasInitialized then return end
	if (not file.Exists("lua/includes/menumods_init.lua", "GAME")) then return end
	
	exec = CompileString(file.Read("lua/includes/menumods_init.lua", "GAME"), "includes/menumods_init.lua", true)

	exec()
	
	HasInitialized = true
end

hook.Add("Think", "MenuMods_Initialize", Think)
