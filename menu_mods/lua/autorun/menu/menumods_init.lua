
if (not MenuMods_Initialized) then
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
end

local exec = CompileString(file.Read("lua/autorun/menu/menumods_menu.lua", "GAME"), "autorun/menu/menumods_menu.lua", true)

exec()

if MenuMods_Initialized then return end

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

local FileTable = {}
local HTMLFileTable = {}
local JSFileTable = {}

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
					
					if isfunction(exec) then
						xpcall(exec, handleError)
					end
					
					FileTable[filename] = true
				end
			end
		end
	end
	
	local files, dirs = file.Find("lua/htmldocs/*.lua", "GAME")

	for k, v in ipairs(files) do
		if (not dirs[k]) then
			dirs[k] = "lua/htmldocs"
		end
		
		local filename = (dirs[k] .. "/" .. v)
		
		if (not HTMLFileTable[filename]) then
			local startPos, endPos = string.find(v, "%.lua$", 1, false)
			
			if startPos then
				local name = string.sub(v, 1, (startPos - 1))
				
				local shouldMount = true
				
				local dirTab = string.Explode("/", dirs[k], false)
				
				if ((#dirTab == 3) and (name == "init")) then
					name = string.lower(dirTab[#dirTab])
				elseif (#dirTab != 2) then
					shouldMount = false
				end
				
				if shouldMount then
					local fullPath = string.gsub((dirs[k] .. "/" .. v), "^lua/", "", 1)
					
					LUA_HTML = {}
					
					LUA_HTML.ClassName = name
					
					if SERVER then
						AddCSLuaFile(fullPath)
					end
					
					menumods.include(fullPath)
					
					if (not LUA_HTML.Base) then
						LUA_HTML.Base = "base_html"
					end
					
					luahtml.Register(LUA_HTML, name)
				end
			end
			
			HTMLFileTable[filename] = true
		end
	end

	LUA_HTML = nil

	for k, v in pairs(luahtml.GetClasses()) do
		if istable(v.BaseClass) then
			for i, j in pairs(v.BaseClass) do
				if (v[i] == nil) then
					v[i] = j
				end
			end
		end
	end

	local files, dirs = file.Find("lua/jsdocs/*.lua", "GAME")

	for k, v in ipairs(files) do
		if (not dirs[k]) then
			dirs[k] = "lua/jsdocs"
		end
		
		local filename = (dirs[k] .. "/" .. v)
		
		if (not JSFileTable[filename]) then
			local startPos, endPos = string.find(v, "%.lua$", 1, false)
			
			if startPos then
				local name = string.sub(v, 1, (startPos - 1))
				
				local shouldMount = true
				
				local dirTab = string.Explode("/", dirs[k], false)
				
				if ((#dirTab == 3) and (name == "init")) then
					name = string.lower(dirTab[#dirTab])
				elseif (#dirTab != 2) then
					shouldMount = false
				end
				
				if shouldMount then
					local fullPath = string.gsub((dirs[k] .. "/" .. v), "^lua/", "", 1)
					
					LUA_JS = {}
					
					LUA_JS.ClassName = name
					
					if SERVER then
						AddCSLuaFile(fullPath)
					end
					
					menumods.include(fullPath)
					
					if (not LUA_JS.Base) then
						LUA_JS.Base = "base_js"
					end
					
					luajs.Register(LUA_JS, name)
				end
			end
			
			JSFileTable[filename] = true
		end
	end

	LUA_JS = nil

	for k, v in pairs(luajs.GetClasses()) do
		if istable(v.BaseClass) then
			for i, j in pairs(v.BaseClass) do
				if (v[i] == nil) then
					v[i] = j
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
