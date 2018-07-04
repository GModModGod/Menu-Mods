
if MenuMods_Initialized then return end

local LuaDirs = {}

local function UpdateLuaDirs()
	LuaDirs = {}
	
	local _, dirs = file.Find("lua/*", "GAME")
	
	for k, v in pairs(dirs) do
		local currDir = "" .. v
		
		currDir = string.gsub(currDir, "^lua%/([^%/]*).*", "%1")
		
		LuaDirs[currDir] = true
	end
end

UpdateLuaDirs()

menumods = {}

local currDir = "autorun/menu"

function menumods.GetFullLuaFileName(filename)
	local newFileName = "" .. filename
	local prevDir = "" .. currDir
	
	local start, endPos = string.find(newFileName, "^[^%/]*")
	
	if endPos then
		if (endPos >= #newFileName) then
			newFileName = prevDir .. "/" .. newFileName
		else
			local folderDir = string.sub(newFileName, start, endPos)
			local currStr = "" .. newFileName
			local currFolderDir = ""
			local start, endPos = string.find(currStr, "^[^%/]*")
			
			while (start and endPos and (endPos < #currStr)) do
				if (#currFolderDir > 0) then
					currFolderDir = currFolderDir .. "/" .. string.sub(currStr, start, endPos)
				else
					currFolderDir = string.sub(currStr, start, endPos)
				end
				
				currStr = string.sub(currStr, (endPos + 2), #currStr)
				
				start, endPos = string.find(currStr, "^[^%/]*")
			end
			
			if (not LuaDirs[folderDir]) then
				newFileName = prevDir .. "/" .. newFileName
				prevDir = prevDir .. "/" .. currFolderDir
			else
				prevDir = currFolderDir
			end
		end
	end
	
	return newFileName, prevDir
end

function menumods.include(filename)
	local start, endPos = string.find(filename, "%.lua$")
	
	if (not start) then
		print("[ERROR] Attempted to include a non-Lua file.")
		
		return
	end
	
	local newFileName, newDir = menumods.GetFullLuaFileName(filename)
	
	local fullFileName = "lua/" .. newFileName
	
	if file.Exists(fullFileName, "GAME") then
		local fileString = file.Read(fullFileName, "GAME")
		
		fileString = "local include = menumods.include; " .. fileString
		
		local exec = CompileString(fileString, newFileName, true)
		local function handleError(err)
			print("[ERROR] " .. err)
		end
		
		local result = {false}
		
		if isfunction(exec) then
			local prevDir = "" .. currDir
			
			currDir = newDir
			
			result = {xpcall(exec, handleError)}
			
			currDir = prevDir
		end
		
		table.remove(result, 1)
		
		return unpack(result)
	end
end

local ConVarTable = {}
local PrevConVarValues = {}

local CreateConVar_Old = CreateConVar
local CreateConVar_New = CreateConVar_Old

CreateConVar = function(name, default, flags, ...)
	local shouldSave = false
	
	if isnumber(flags) then
		shouldSave = (bit.band(flags, FCVAR_ARCHIVE) > 0)
	elseif istable(flags) then
		for k, v in ipairs(flags) do
			if (not shouldSave) then
				shouldSave = (bit.band(v, FCVAR_ARCHIVE) > 0)
			else
				break
			end
		end
	end
	
	local newName = tostring(name)
	
	if shouldSave then
		ConVarTable[newName] = true
	end
	
	local result = CreateConVar_New(name, default, ...)
	
	local prevValue = PrevConVarValues[newName]
	
	if prevValue then
		RunConsoleCommand(newName, prevValue)
	end
	
	return result
end

local CreateClientConVar_Old = CreateClientConVar
local CreateClientConVar_New = CreateClientConVar_Old

CreateClientConVar = function(name, default, shouldSave, ...)
	if ((not shouldSave) and (not isbool(shouldSave))) then
		shouldSave = true
	end
	
	local newName = tostring(name)
	
	if shouldSave then
		ConVarTable[newName] = true
	end
	
	local result = CreateClientConVar_New(name, default, shouldSave, ...)
	
	local prevValue = PrevConVarValues[newName]
	
	if prevValue then
		RunConsoleCommand(newName, prevValue)
	end
	
	return result
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

local function LoadConVars()	
	if file.Exists("menumods/convars.txt", "DATA") then
		local JSON = file.Read("menumods/convars.txt", "DATA")
		
		local newConVarTab = util.JSONToTable(JSON)
		
		if newConVarTab then
			for k, v in pairs(newConVarTab) do
				local name = tostring(k)
				local value = tostring(v)
				
				if ConVarExists(name) then
					RunConsoleCommand(name, value)
				else
					PrevConVarValues[name] = value
				end
			end
		end
	end
end

hook.Add("CloseDermaMenus", "MenuMods_SaveConVars", SaveConVars)

CreateConVar("menumods_enabled", 1, FCVAR_ARCHIVE)

menumods.include("menumods_menu.lua")

local FileBlacklist = {
	["lua/vgui/spawnicon.lua"] = true
}

local files, dirs = file.Find("lua/vgui/*.lua", "MOD")

for k, v in pairs(files) do
	if (not dirs[k]) then
		dirs[k] = "lua/vgui"
	end
	
	local filename = (dirs[k] .. "/" .. v)
	
	if ((not FileBlacklist[filename]) and file.Exists(filename, "MOD")) then
		filename = string.gsub(filename, "^lua%/", "")
		
		menumods.include(filename)
	end
end

local ContentChanged = false

local FileTable = {
	["lua/autorun/menu/menumods_init.lua"] = true,
	["lua/autorun/menu/menumods_menu.lua"] = true
}
local HTMLFileTable = {}
local JSFileTable = {}

local function Mount()
	UpdateLuaDirs()
	
	LoadConVars()
	
	if (GetConVarNumber("menumods_enabled") == 0) then return end
	
	local files, dirs = file.Find("lua/autorun/menu/*.lua", "GAME")
	
	for k, v in pairs(files) do
		if (not dirs[k]) then
			dirs[k] = "lua/autorun/menu"
		end
		
		local filename = (dirs[k] .. "/" .. v)
		
		if ((not FileTable[filename]) and file.Exists(filename, "GAME")) then
			local newFileName = string.gsub(filename, "^lua%/", "")
			
			menumods.include(newFileName)
			
			FileTable[filename] = true
		end
	end
	
	local files, dirs = file.Find("lua/htmldocs/*.lua", "GAME")
	
	for k, v in ipairs(files) do
		if (not dirs[k]) then
			dirs[k] = "lua/htmldocs"
		end
		
		local filename = (dirs[k] .. "/" .. v)
		
		if (not HTMLFileTable[filename]) then
			local startPos, endPos = string.find(v, "%.lua$")
			
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
					local fullPath = string.gsub((dirs[k] .. "/" .. v), "^lua/", "")
					
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
			local startPos, endPos = string.find(v, "%.lua$")
			
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
					local fullPath = string.gsub((dirs[k] .. "/" .. v), "^lua/")
					
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

local function GameContentChanged()
	ContentChanged = true
end

local function Think()
	if (GetConVarNumber("menumods_enabled") == 0) then return end
	
	if ContentChanged then
		Mount()
		ContentChanged = false
	end
end

hook.Add("GameContentChanged", "MenuMods_GameContentChanged", GameContentChanged)
hook.Add("Think", "MenuMods_GameContentChanged", Think)

Mount()

MenuMods_Initialized = true
