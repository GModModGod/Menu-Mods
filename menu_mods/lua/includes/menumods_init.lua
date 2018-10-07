
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
menumods.hook = {}

function menumods.hook.GetTable()
	return {}
end

local CurrDir = "includes"

function menumods.GetFullLuaFileName(filename)
	local newFileName = "" .. filename
	local prevDir = "" .. CurrDir
	
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

local LogFilePrefix = ""
local LogFileID = ""
local LogFileExtension = ""

function menumods.NewLuaErrorLogFile(filename, extension)
	if (not isstring(filename)) then
		filename = LogFilePrefix
	end
	
	if ((not isstring(extension)) or (not string.find(extension, "^%."))) then
		extension = ".txt"
	end
	
	local currID = 1
	local newFileID
	
	local found = false
	
	while (not found) do
		newFileID = tostring(currID)
		
		local newFileName = (filename .. newFileID .. extension)
		
		if (not file.Exists(newFileName, "DATA")) then
			found = true
		end
		
		currID = currID + 1
	end
	
	if newFileID then
		LogFilePrefix = filename
		LogFileID = newFileID
		LogFileExtension = extension
		
		return true
	end
	
	return false
end

function menumods.ChangeLuaErrorLogFile(filename, extension, index)
	if (not isstring(filename)) then
		filename = LogFilePrefix
	end
	
	if ((not isstring(extension)) or (not string.find(extension, "^%."))) then
		extension = ".txt"
	end
	
	local newFileID
	
	if ((not isnumber(index)) and (not isstring(index))) then
		local currID = 1
		
		local found = false
		
		while (not found) do
			local currFileID = tostring(currID)
			local newFileName = (filename .. newFileID .. extension)
			
			if file.Exists(newFileName, "DATA") then
				newFileID = currFileID
			else
				found = true
			end
			
			currID = currID + 1
		end
		
		if (not newFileID) then
			newFileID = "1"
		end
	else
		newFileID = tostring(index)
	end
	
	LogFilePrefix = filename
	LogFileID = newFileID
	LogFileExtension = extension
end

function menumods.LogLuaError(content)
	local logFileName = LogFilePrefix .. LogFileID .. LogFileExtension
	local CurrDir = ""
	local dirTab = string.Explode("/", logFileName, false)
	local dirTabCount = #dirTab
	
	for k, v in ipairs(dirTab) do
		if (k < dirTabCount) then
			if (k > 1) then
				CurrDir = CurrDir .. "/" .. v
			else
				CurrDir = v
			end
			
			if (not file.IsDir(CurrDir, "DATA")) then
				file.CreateDir(CurrDir)
			end
		else
			break
		end
	end
	
	if file.Exists(logFileName, "DATA") then
		local newContent = "\n" .. content
		
		file.Append(logFileName, newContent)
	else
		file.Write(logFileName, content)
	end
end

menumods.NewLuaErrorLogFile("menumods/logs/lua_error_log_")

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

CreateConVar("menumods_enableLuaErrorLogging", 0, FCVAR_ARCHIVE)

local hookName = "MenuErrorHandler"

--[[
local States = {
	[false] = "Unknown",
	[1] = "Server",
	[2] = "Menu",
	[3] = "Client"
}
]]

local AllHooks = hook.GetTable()
local LuaErrorHooks = AllHooks["OnLuaError"]

local MenuErrorHandler

if istable(LuaErrorHooks) then
	local MenuErrorHandler_Old = LuaErrorHooks[hookName]
	
	if isfunction(MenuErrorHandler_Old) then
		MenuErrorHandler = MenuErrorHandler_Old
		
		hook.Remove("OnLuaError", hookName)
		
		LuaErrorHooks[hookName] = nil
	else
		MenuErrorHandler = function() end
	end
else
	MenuErrorHandler = function() end
end

local function SafeEquals(a, b)
	if (type(a) != type(b)) then
		return false
	end
	
	return (a == b)
end

local function HandleErrorFunctionError(err)
	local text = "[ERROR] " .. err
	
	print(text)
end

local function OnLuaError(text, realm, addonName, addonID, ...)
	if (not isnumber(realm)) then
		realm = 0
	end
	
	if (not isstring(addonName)) then
		addonName = "N/A"
	end
	
	if (not isstring(addonID)) then
		addonID = nil
	end
	
	MenuErrorHandler(text, realm, addonName, addonID, ...)
	
	local allHooks = menumods.hook.GetTable()
	local luaErrorHooks = allHooks["OnLuaError"]
	
	if istable(luaErrorHooks) then
		for k, v in pairs(luaErrorHooks) do
			if ((not SafeEquals(k, hookName)) and isfunction(v)) then
				xpcall(v, HandleErrorFunctionError, text, realm, addonName, addonID, ...)
			end
		end
	end

	if (GetConVarNumber("menumods_enableLuaErrorLogging") != 0) then
		local errorString = "Addon: " .. addonName .. "\nRealm: " .. tostring(realm) .. "\n" .. text .. "\n"
		
		menumods.LogLuaError(errorString)
	end
end

function menumods.GetTraceString(level, shouldStop)
	local shouldStop = shouldStop
	
	if (not isfunction(shouldStop)) then
		shouldStop = function()
			return false
		end
	end
	
	local level = level
	
	if (not isnumber(level)) then
		level = 1
	end
	
	local finished = false
	
	local str = ""
	
	while (not finished) do
		local info = debug.getinfo(level, "flnSu")
		
		if info then
			local result = shouldStop(info, level)
			
			if (not result) then
				local stringToAdd = string.format("\t%i. %s - %s:%i", level, info.name, info.short_src, info.currentline)
				
				if (str != "") then
					str = str .. "\n" .. stringToAdd
				else
					str = stringToAdd
				end
				
				level = level + 1
			else
				finished = true
			end
		else
			finished = true
		end
	end
	
	return str
end

local function TraceShouldStop()
	local newInfo = debug.getinfo(6, "f")
	
	if (not isfunction(newInfo.func)) then
		return false
	end
	
	return (newInfo.func == menumods.include)
end

function menumods.error(err, realm, addonName, addonID, ...)
	if (not isnumber(realm)) then
		realm = 0
	end
	
	print(err)
	
	OnLuaError(err, realm, addonName, addonID, ...)
end

local function HandleError(err, realm, addonName, addonID, ...)
	if (not isnumber(realm)) then
		realm = 0
	end
	
	local traceString = menumods.GetTraceString(2, TraceShouldStop)
	local text = "[ERROR] " .. err .. "\n" .. traceString
	
	print(text)
	
	OnLuaError(text, realm, addonName, addonID, ...)
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
		
		local result = {false}
		
		if isfunction(exec) then
			local prevDir = "" .. CurrDir
			
			CurrDir = newDir
			
			result = {xpcall(exec, HandleError)}
			
			CurrDir = prevDir
		end
		
		table.remove(result, 1)
		
		return unpack(result)
	end
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

hook.Add("OnLuaError", hookName, OnLuaError)

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

local FileTable = {}
local HTMLFileTable = {}
local JSFileTable = {}

local function Mount()
	UpdateLuaDirs()
	
	LoadConVars()
	
	if (GetConVarNumber("menumods_enabled") == 0) then return end
	
	local files, dirs = file.Find("lua/vgui_menu/*.lua", "GAME")
	
	for k, v in pairs(files) do
		if (not dirs[k]) then
			dirs[k] = "lua/vgui_menu"
		end
		
		local filename = (dirs[k] .. "/" .. v)
		
		if ((not FileTable[filename]) and file.Exists(filename, "GAME")) then
			local newFileName = string.gsub(filename, "^lua%/", "")
			
			menumods.include(newFileName)
			
			FileTable[filename] = true
		end
	end
	
	files, dirs = file.Find("lua/autorun/menu/*.lua", "GAME")
	
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
	
	files, dirs = file.Find("lua/htmldocs/*.lua", "GAME")
	
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
	
	files, dirs = file.Find("lua/jsdocs/*.lua", "GAME")
	
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
hook.Add("Think", "MenuMods_Mount", Think)

Mount()

MenuMods_Initialized = true
