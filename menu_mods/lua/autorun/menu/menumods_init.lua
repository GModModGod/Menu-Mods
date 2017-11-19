
local ConVarTable = {}

local CreateConVar_Old = CreateConVar
local CreateConVar_New = CreateConVar_Old

CreateConVar = function(name, default, ...)
	ConVarTable[tostring(name)] = true
	
	return CreateConVar_New(name, default, ...)
end

local CreateClientConVar_Old = CreateClientConVar
local CreateClientConVar_New = CreateClientConVar_Old

CreateClientConVar = function(name, default, ...)
	ConVarTable[tostring(name)] = true
	
	return CreateClientConVar_New(name, default, ...)
end

local function SaveConVars()
	local conVarTab = {}
	
	for k, v in pairs(ConVarTable) do
		if ConVarExists(k) then
			conVarTab[k] = GetConVar(k):GetString()
		end
	end
	
	if (not file.IsDir("menumods", "DATA")) then
		file.CreateDir("menumods")
	end
	
	local JSON = util.TableToJSON(conVarTab, true)
	
	if JSON then
		file.Write("menumods/convars.txt", JSON)
	end
end

hook.Add("CloseDermaMenus", "MenuMods_SaveConVars", SaveConVars)

local FileBlacklist = {
	["lua/vgui/spawnicon.lua"] = true
}

local files, dirs = file.Find("lua/vgui/*.lua", "MOD")

for k, v in pairs(files) do
	if (not dirs[k]) then
		dirs[k] = "lua/vgui"
	end
	
	local filename = (dirs[k] .. "/" .. v)
	
	if (not FileBlacklist[filename]) then
		if file.Exists(filename, "MOD") then
			local exec = CompileString(file.Read(filename, "MOD"), string.TrimLeft(filename, "lua/"), true)
			local function handleError(err)
				print("[ERROR] " .. err)
			end
			
			xpcall(exec, handleError)
		end
	end
end

if (not MenuMods_Initialized) then
	local exec = CompileString(file.Read("lua/autorun/menu/menumods_menu.lua", "GAME"), "autorun/menu/menumods_menu.lua", true)

	exec()
end

local FileTable = {}

local function Mount()
	local files, dirs = file.Find("lua/autorun/menu/*.lua", "GAME")

	for k, v in pairs(files) do
		if (not dirs[k]) then
			dirs[k] = "lua/autorun/menu"
		end
		
		local filename = (dirs[k] .. "/" .. v)
		
		if (not FileTable[filename]) then
			if file.Exists(filename, "GAME") then
				if ((filename != "lua/autorun/menu/menumods_init.lua") and (filename != "lua/autorun/menu/menumods_menu.lua")) then
					local exec = CompileString(file.Read(filename, "GAME"), string.TrimLeft(filename, "lua/"), true)
					local function handleError(err)
						print("[ERROR] " .. err)
					end
					
					xpcall(exec, handleError)
					
					FileTable[filename] = true
				end
			end
		end
	end
	
	if MenuMods_Initialized then
		menumods.hook.Run("Initialize")
	end
end

Mount()

hook.Add("GameContentChanged", "MenuMods_GameContentChanged", Mount)

if file.Exists("menumods/convars.txt", "DATA") then
	local JSON = file.Read("menumods/convars.txt", "DATA")
	
	local conVarTab = util.JSONToTable(JSON)
	
	if conVarTab then
		for k, v in pairs(conVarTab) do
			local name = tostring(k)
			local value = tostring(v)
			
			if ConVarExists(name) then
				RunConsoleCommand(name, value)
			end
		end
	end
end

MenuMods_Initialized = true
