
local menumods_ValidTypes_Old = {
	["angle"] = true,
	["boolean"] = true,
	["color"] = true,
	["nil"] = true,
	["no value"] = true,
	["number"] = true,
	["string"] = true,
	["vector"] = true
}

local menumods_ValidTypes = {
	["angle"] = true,
	["boolean"] = true,
	["color"] = true,
	["nil"] = true,
	["no value"] = true,
	["number"] = true,
	["string"] = true,
	["table"] = true,
	["vector"] = true
}

function menumods.string.AppendValues(str, ...)
	local vals = {...}
	
	for k, v in ipairs(vals) do
		str = str .. tostring(v) .. ";"
	end
	
	return str
end

function menumods.string.ReadValues(str, numVals)
	local vals = {}
	
	for i = 1, numVals do
		local currStr = ""
		local foundEnd = false
		
		while (not foundEnd) do
			local startPos, endPos = string.find(str, "^[^\"\';]*[\"\';]")
			
			if (not startPos) then
				startPos = 1
			end
			
			if (not endPos) then
				endPos = 0
			end
			
			currStr = currStr .. string.sub(str, startPos, endPos)
			
			str = string.sub(str, (endPos + 1))
			
			local endsWithSemi = ((currStr == "") or string.find(currStr, ";$"))
			local startsWithDQ = string.find(currStr, "^\"")
			local startsWithSQ = ((not startsWithDQ) and string.find(currStr, "^\'"))
			local sufficientLen = (#currStr > 1)
			local endsWithDQ = (sufficientLen and string.find(currStr, "\"$"))
			local endsWithSQ = (sufficientLen and (not endsWithDQ) and string.find(currStr, "\'$"))
			local endsWithSDQ = (sufficientLen and endsWithDQ and string.find(currStr, "\\\"$"))
			local endsWithSSQ = (sufficientLen and endsWithSQ and string.find(currStr, "\\\'$"))
			
			if ((str == "") or (endsWithSemi and (not startsWithDQ) and (not startsWithSQ)) or (endsWithDQ and (not endsWithSDQ) and startsWithDQ) or (endsWithSQ and (not endsWithSSQ) and startsWithSQ)) then
				if endsWithSemi then
					if (currStr != "") then
						currStr = string.sub(currStr, 1, (#currStr - 1))
					end
				else
					if (str != "") then
						str = string.sub(str, 2)
					end
				end
				
				foundEnd = true
			end
		end
		
		table.insert(vals, (#vals + 1), currStr)
	end
	
	return vals, str
end

local menumods_WriteTypeFuncs = {
	["angle"] = function(str, val)
		str = menumods.string.AppendValues(str, val.p, val.y, val.r)
		
		return str
	end,
	["boolean"] = function(str, val)
		str = menumods.string.AppendValues(str, val)
		
		return str
	end,
	["color"] = function(str, val)
		str = menumods.string.AppendValues(str, val.r, val.g, val.b, val.a)
		
		return str
	end,
	["nil"] = function(str, val)
		str = menumods.string.AppendValues(str, "nil")
		
		return str
	end,
	["no value"] = function(str, val)
		str = menumods.string.AppendValues(str, "no value")
		
		return str
	end,
	["number"] = function(str, val)
		str = menumods.string.AppendValues(str, val)
		
		return str
	end,
	["string"] = function(str, val)
		str = menumods.string.AppendValues(str, menumods.string.LevelPush(tostring(val), 1, false))
		
		return str
	end,
	["vector"] = function(str, val)
		str = menumods.string.AppendValues(str, val.x, val.y, val.z)
		
		return str
	end
}

menumods.string.WriteAngle = menumods_WriteTypeFuncs["angle"]
menumods.string.WriteBool = menumods_WriteTypeFuncs["boolean"]
menumods.string.WriteNumber = menumods_WriteTypeFuncs["number"]
menumods.string.WriteString = menumods_WriteTypeFuncs["string"]
menumods.string.WriteVector = menumods_WriteTypeFuncs["vector"]

local menumods_ReadTypeFuncs = {
	["angle"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 3)
		
		return Angle(tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3])), str
	end,
	["boolean"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		return tobool(vals[1]), str
	end,
	["color"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 4)
		
		return Color(tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3]), tonumber(vals[4])), str
	end,
	["nil"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		return nil, str
	end,
	["no value"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		return nil, str
	end,
	["number"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		return tonumber(vals[1]), str
	end,
	["string"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		return menumods.string.LevelPop(vals[1], 1), str
	end,
	["vector"] = function(str)
		local vals, str = menumods.string.ReadValues(str, 3)
		
		return Vector(tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3])), str
	end
}

menumods.string.ReadAngle = menumods_ReadTypeFuncs["angle"]
menumods.string.ReadBool = menumods_ReadTypeFuncs["boolean"]
menumods.string.ReadNumber = menumods_ReadTypeFuncs["number"]
menumods.string.ReadString = menumods_ReadTypeFuncs["string"]
menumods.string.ReadVector = menumods_ReadTypeFuncs["vector"]

local function menumods_IsValidType_Old(value)
	local valType = string.lower(type(value))
	
	if menumods_ValidTypes_Old[valType] then
		return true
	end
	
	return false
end

local function menumods_WriteType_Old(str, value)
	local valType = string.lower(type(value))
	
	if (not menumods_ValidTypes_Old[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write invalid type \"" .. valType .. "\".")
		
		return
	end
	
	str = menumods.string.AppendValues(str, menumods.string.LevelPush(valType, 1, false))
	
	str = menumods_WriteTypeFuncs[valType](str, value)
	
	return str
end

local function menumods_ReadType_Old(str)
	local preValType, newStr = menumods.string.ReadValues(str, 1)
	str = newStr
	local valType = menumods.string.LevelPop(preValType[1], 1)
	
	if (not menumods_ValidTypes_Old[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to read invalid type \"" .. valType .. "\".")
		
		return
	end
	
	local newVal, newStr = menumods_ReadTypeFuncs[valType](str)
	str = newStr
	
	return newVal, str
end

menumods.string.WriteTable = function(str, tab, excludedTabs, tree)
	if (not istable(tab)) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write a non-table value as table.")
		
		return
	end
	
	if (not istable(excludedTabs)) then
		excludedTabs = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	excludedTabs[tab] = tree
	
	local newTab = {}
	local subTabs = {}
	local exclusions = {}
	local tabCount = 0
	local subTabsCount = 0
	local exclusionsCount = 0
	
	for k, v in pairs(tab) do
		local vIsTable = istable(v)
		
		if (menumods_IsValidType_Old(k) and (menumods_IsValidType_Old(v) or vIsTable)) then
			local proceed = true
			
			if (vIsTable and excludedTabs[v]) then
				proceed = false
			end
			
			if proceed then
				if (not vIsTable) then
					newTab[k] = v
					tabCount = tabCount + 1
				else
					subTabs[k] = v
					subTabsCount = subTabsCount + 1
				end
			else
				exclusions[k] = excludedTabs[v]
				exclusionsCount = exclusionsCount + 1
			end
		end
	end
	
	str = menumods.string.AppendValues(str, tabCount)
	
	for k, v in pairs(newTab) do
		str = menumods_WriteType_Old(str, k)
		str = menumods_WriteType_Old(str, v)
	end
	
	str = menumods.string.AppendValues(str, subTabsCount)
	
	for k, v in pairs(subTabs) do
		str = menumods_WriteType_Old(str, k)
		
		table.insert(tree, (#tree + 1), k)
		
		str = menumods.string.WriteTable(str, v, excludedTabs, tree)
		
		table.remove(tree, #tree)
	end
	
	str = menumods.string.AppendValues(str, exclusionsCount)
	
	for k, v in pairs(exclusions) do
		str = menumods_WriteType_Old(str, k)
		
		str = menumods.string.AppendValues(str, #v)
		
		for i, j in ipairs(v) do
			str = menumods_WriteType_Old(str, j)
		end
	end
	
	return str
end

menumods.string.ReadTable = function(str, newTab, excludedTabs, tree)
	if (not istable(excludedTabs)) then
		excludedTabs = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	if (not istable(newTab)) then
		newTab = {}
	end
	
	local preTabCount, newStr = menumods.string.ReadValues(str, 1)
	str = newStr
	local tabCount = tonumber(preTabCount[1])
	
	for i = 1, tabCount do
		local k, newStr = menumods_ReadType_Old(str)
		str = newStr
		local v, newStr = menumods_ReadType_Old(str)
		str = newStr
		
		newTab[k] = v
	end
	
	local preSubTabsCount, newStr = menumods.string.ReadValues(str, 1)
	str = newStr
	local subTabsCount = tonumber(preSubTabsCount[1])
	
	for i = 1, subTabsCount do
		local k, newStr = menumods_ReadType_Old(str)
		str = newStr
		
		table.insert(tree, (#tree + 1), k)
		
		local newVal, newStr = menumods.string.ReadTable(str, newTab[k], excludedTabs, tree)
		str = newStr
		newTab[k] = newVal
		
		table.remove(tree, #tree)
	end
	
	local preExclusionsCount, newStr = menumods.string.ReadValues(str, 1)
	str = newStr
	local exclusionsCount = tonumber(preExclusionsCount[1])
	
	for i = 1, exclusionsCount do
		local k, newStr = menumods_ReadType_Old(str)
		str = newStr
		
		local preCount, newStr = menumods.string.ReadValues(str, 1)
		str = newStr
		local count = tonumber(preCount[1])
		
		local oldTree = {}
		
		for j = 1, count do
			local k_old, newStr = menumods_ReadType_Old(str)
			str = newStr
			
			table.insert(oldTree, (#oldTree + 1), k_old)
		end
		
		local newTree = {}
		
		for i, j in pairs(tree) do
			newTree[i] = j
		end
		
		table.insert(newTree, (#newTree + 1), k)
		
		table.insert(excludedTabs, (#excludedTabs + 1), {newTree, oldTree})
	end
	
	if (#tree <= 0) then
		for k, v in pairs(excludedTabs) do
			local newVal = newTab
			
			for i, j in ipairs(v[1]) do
				if (i < #v[1]) then
					newVal = newVal[j]
				else
					break
				end
			end
			
			local oldVal = newTab
			
			for i, j in ipairs(v[2]) do
				oldVal = oldVal[j]
			end
			
			newVal[ v[1][ #v[1] ] ] = oldVal
		end
	end
	
	return newTab, str
end

menumods_WriteTypeFuncs["table"] = menumods.string.WriteTable
menumods_ReadTypeFuncs["table"] = menumods.string.ReadTable

function menumods.IsValidType(value)
	local valType = string.lower(type(value))
	
	if menumods_ValidTypes[valType] then
		return true
	end
	
	return false
end

function menumods.string.WriteType(str, value)
	local valType = string.lower(type(value))
	
	if (not menumods_ValidTypes[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write an invalid type.")
		
		return
	end
	
	str = menumods.string.AppendValues(str, menumods.string.LevelPush(valType, 1, false))
	
	str = menumods_WriteTypeFuncs[valType](str, value)
	
	return str
end

function menumods.string.ReadType(str)
	local preValType, newStr = menumods.string.ReadValues(str, 1)
	str = newStr
	local valType = menumods.string.LevelPop(preValType[1], 1)
	
	if (not menumods_ValidTypes[valType]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to read an invalid type.")
		
		return
	end
	
	local newVal, newStr = menumods_ReadTypeFuncs[valType](str)
	str = newStr
	
	return newVal, str
end

if MENU_DLL then
	menumods.include("includes/modules/netdata.lua")
else
	include("includes/modules/netdata.lua")
end

menumods.net = {}

local CurrMsg_Send
local CurrMsg_Receive

local NetReceiveFuncs = {}
local NetDir_Receive
local NetDir_Send

local ShouldSendMsg = true

if MENU_DLL then
	NetDir_Receive = "menumods_net_menu"
	NetDir_Send = "menumods_net_client"
else
	NetDir_Receive = "menumods_net_client"
	NetDir_Send = "menumods_net_menu"
end

function menumods.net.Start(identifier)
	if (not isstring(identifier)) then return end
	
	local newMsg = netdata.Create("base_netdata")
	
	newMsg:WriteString(identifier)
	
	CurrMsg_Send = {identifier, newMsg}
end

function menumods.net.Send()
	if (MENU_DLL and ((not ShouldSendMsg) or (not IsInGame()))) then
		if istable(CurrMsg_Send) then
			if CurrMsg_Send[2]:IsValid() then
				CurrMsg_Send[2]:Remove()
			end
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local identifier = CurrMsg_Send[1]
	local message = CurrMsg_Send[2]
	
	local files, dirs = file.Find((NetDir_Send .. "/*.txt"), "DATA")
	local occupiedIDs = {}
	
	for k, v in ipairs(files) do
		if (not dirs[k]) then
			dirs[k] = NetDir_Send
		end
		
		if (dirs[k] == NetDir_Send) then
			local fullMatch = {string.match(v, ("net_msg__%d+%.txt$"), 1)}
			
			fullMatch = fullMatch[1]
			
			if fullMatch then
				local newMatch = {string.match(fullMatch, "%d+%.txt$", 1)}
				
				newMatch = newMatch[1]
				
				if newMatch then
					newMatch = string.TrimRight(newMatch, ".txt")
					
					local id = tonumber(newMatch)
					
					if id then
						occupiedIDs[id] = true
					end
				end
			end
		end
	end
	
	local fileID = 1
	local foundID = false
	
	while (not foundID) do
		if (not occupiedIDs[fileID]) then
			foundID = true
		else
			fileID = fileID + 1
		end
	end
	
	local filename = NetDir_Send .. "/net_msg__" .. tostring(fileID) .. ".txt"
	
	message:WriteDataToFile(filename)
	
	message:Remove()
	
	CurrMsg_Send = nil
end

function menumods.net.Receive(identifier, func)
	if (not isstring(identifier)) then return end
	if (not isfunction(func)) then return end
	
	NetReceiveFuncs[identifier] = func
end

menumods.net.IsValidType = menumods.IsValidType

function menumods.net.WriteAngle(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteAngle(val)
end

function menumods.net.WriteBool(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteBool(val)
end

function menumods.net.WriteNumber(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteNumber(val)
end

function menumods.net.WriteString(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteString(val)
end

function menumods.net.WriteTable(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteTable(val)
end

function menumods.net.WriteVector(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteVector(val)
end

function menumods.net.WriteType(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteType(val)
end

function menumods.net.ReadAngle()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadAngle()
end

function menumods.net.ReadBool()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadBool()
end

function menumods.net.ReadNumber()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadNumber()
end

function menumods.net.ReadString()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadString()
end

function menumods.net.ReadTable(newTab)
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadTable(newTab)
end

function menumods.net.ReadVector()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadVector()
end

function menumods.net.ReadType()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadType()
end

local warning = false

local function Think()
	local shouldSendDir
	
	if MENU_DLL then
		shouldSendDir = (NetDir_Receive .. "/shouldsend.dat")
	else
		shouldSendDir = (NetDir_Send .. "/shouldsend.dat")
	end
	
	if (not MENU_DLL) then
		local filenameTab = string.Explode("/", shouldSendDir, false)
		local currFolder
		
		for k, v in ipairs(filenameTab) do
			if (k < #filenameTab) then
				local dir
				
				if isstring(currFolder) then
					dir = currFolder .. "/" .. v
				else
					dir = v
				end
				
				if (not file.IsDir(dir, "DATA")) then
					file.CreateDir(dir)
				end
				
				currFolder = dir
			end
		end
		
		file.Write(shouldSendDir, "This file indicates to the menu state that it may send data to the client state.")
	elseif file.Exists(shouldSendDir, "DATA") then
		ShouldSendMsg = true
		warning = false
	elseif warning then
		ShouldSendMsg = false
	else
		warning = true
	end
	
	if (MENU_DLL and ShouldSendMsg and (not warning)) then
		file.Delete(shouldSendDir)
	end
	
	if (MENU_DLL and ((not ShouldSendMsg) or (not IsInGame()))) then
		local files = file.Find((NetDir_Send .. "/*.txt"), "DATA")
		
		for k, v in ipairs(files) do
			local filename = (NetDir_Send .. "/" .. v)
			
			if file.Exists(filename, "DATA") then
				file.Delete(filename)
			end
		end
		
		return
	end
	
	local files, dirs = file.Find((NetDir_Receive .. "/*.txt"), "DATA")
	
	for k, v in ipairs(files) do
		if (not dirs[k]) then
			dirs[k] = NetDir_Receive
		end
		
		if (dirs[k] == NetDir_Receive) then
			local startPos = string.find(v, "%d+%.txt$", 1, false)
			
			if startPos then
				CurrMsg_Receive = netdata.Create("base_netdata")
				
				local filename = (dirs[k] .. "/" .. v)
				
				CurrMsg_Receive:ReadDataFromFile(filename, "DATA")
				
				file.Delete(filename)
				
				local identifier = CurrMsg_Receive:ReadString()
				
				if isfunction(NetReceiveFuncs[identifier]) then
					NetReceiveFuncs[identifier]()
				end
				
				CurrMsg_Receive:Remove()
				
				CurrMsg_Receive = nil
			end
		end
	end
end

if MENU_DLL then
	function menumods.net.IsConnected()
		if ShouldSendMsg then
			return true
		end
		
		return false
	end
end

hook.Add("Think", "MenuMods_Net", Think)
