
local tickRateDefault = 30

if MENU_DLL then
	CreateConVar("menumods_net_enabled", 1, FCVAR_ARCHIVE)
	CreateConVar("menumods_net_tickRate", tostring(tickRateDefault), FCVAR_ARCHIVE)
end

local menumods_CanCreateEntities = false

local menumods_TypeIDs = {
	["no value"] = TYPE_NONE,
	["nil"] = TYPE_NIL,
	["bool"] = TYPE_BOOL,
	["number"] = TYPE_NUMBER,
	["string"] = TYPE_STRING,
	["table"] = TYPE_TABLE,
	["function"] = TYPE_FUNCTION,
	["thread"] = TYPE_THREAD,
	["Angle"] = TYPE_ANGLE,
	["Vector"] = TYPE_VECTOR,
	["Entity"] = TYPE_ENTITY,
	["Panel"] = TYPE_PANEL,
}

local function TypeID(val)
	local valType = type(val)
	local newType = menumods_TypeIDs[valType]
	
	if isnumber(newType) then
		return newType
	else
		return menumods_TypeIDs["no value"]
	end
end

local menumods_ValidTypes = {
	[TYPE_NONE] = true,
	[TYPE_NIL] = true,
	[TYPE_BOOL] = true,
	[TYPE_NUMBER] = true,
	[TYPE_STRING] = true,
	[TYPE_TABLE] = true,
	[TYPE_ANGLE] = true,
	[TYPE_VECTOR] = true,
	[TYPE_ENTITY] = true,
	[TYPE_PANEL] = true
}

local menumods_TypeToIndexTab = {
	[TYPE_NONE] = 1,
	[TYPE_NIL] = 2,
	[TYPE_BOOL] = 3,
	[TYPE_NUMBER] = 4,
	[TYPE_STRING] = 5,
	[TYPE_TABLE] = 6,
	[TYPE_ANGLE] = 7,
	[TYPE_VECTOR] = 8,
	[TYPE_ENTITY] = 9,
	[TYPE_PANEL] = 10
}

local menumods_IndexToTypeTab = {}

for k, v in pairs(menumods_TypeToIndexTab) do
	menumods_IndexToTypeTab[v] = k
end

local menumods_ReferenceableTypes = {
	[TYPE_TABLE] = true,
	[TYPE_ENTITY] = true,
	[TYPE_PANEL] = true,
	[TYPE_ANGLE] = true,
	[TYPE_VECTOR] = true
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
	[1] = function(str, val)
		return str
	end,
	[2] = function(str, val)
		return str
	end,
	[3] = function(str, val)
		local newVal
		
		if val then
			newVal = 1
		else
			newVal = 0
		end
		
		str = menumods.string.AppendValues(str, newVal)
		
		return str
	end,
	[4] = function(str, val)
		str = menumods.string.AppendValues(str, val)
		
		return str
	end,
	[5] = function(str, val)
		str = menumods.string.AppendValues(str, menumods.string.LevelPush(tostring(val), 1, false))
		
		return str
	end,
	[7] = function(str, val)
		str = menumods.string.AppendValues(str, val.p, val.y, val.r)
		
		return str
	end,
	[8] = function(str, val)
		str = menumods.string.AppendValues(str, val.x, val.y, val.z)
		
		return str
	end
}

menumods.string.WriteAngle = menumods_WriteTypeFuncs[7]
menumods.string.WriteBool = menumods_WriteTypeFuncs[3]
menumods.string.WriteNumber = menumods_WriteTypeFuncs[4]
menumods.string.WriteString = menumods_WriteTypeFuncs[5]
menumods.string.WriteVector = menumods_WriteTypeFuncs[8]

local menumods_ReadTypeFuncs = {
	[1] = function(str)
		return nil, str
	end,
	[2] = function(str)
		return nil, str
	end,
	[3] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		local newVal = tonumber(vals[1])
		
		if isnumber(newVal) then
			newVal = (newVal > 0)
		else
			newVal = nil
		end
		
		return newVal, str
	end,
	[4] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		return tonumber(vals[1]), str
	end,
	[5] = function(str)
		local vals, str = menumods.string.ReadValues(str, 1)
		
		return menumods.string.LevelPop(vals[1], 1), str
	end,
	[7] = function(str)
		local vals, str = menumods.string.ReadValues(str, 3)
		
		return Angle(tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3])), str
	end,
	[8] = function(str)
		local vals, str = menumods.string.ReadValues(str, 3)
		
		return Vector(tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3])), str
	end
}

menumods.string.ReadAngle = menumods_ReadTypeFuncs[7]
menumods.string.ReadBool = menumods_ReadTypeFuncs[3]
menumods.string.ReadNumber = menumods_ReadTypeFuncs[4]
menumods.string.ReadString = menumods_ReadTypeFuncs[5]
menumods.string.ReadVector = menumods_ReadTypeFuncs[8]

function menumods.TypeIDToIndex(value)
	if menumods_TypeToIndexTab[value] then
		return (menumods_TypeToIndexTab[value] + 0)
	end
	
	return nil
end

function menumods.IndexToTypeID(value)
	if menumods_IndexToTypeTab[value] then
		return (menumods_IndexToTypeTab[value] + 0)
	end
	
	return nil
end

function menumods.IsValidType(value)
	if (not (value == value)) then
		return false
	end
	
	local valType = TypeID(value)
	
	if menumods_ValidTypes[valType] then
		return true
	end
	
	return false
end

function menumods.IsValidTypeID(value)
	if menumods_ValidTypes[value] then
		return true
	end
	
	return false
end

function menumods.IsReferenceableType(value)
	if (not (value == value)) then
		return false
	end
	
	local valType = TypeID(value)
	
	if menumods_ReferenceableTypes[valType] then
		return true
	end
	
	return false
end

function menumods.IsReferenceableTypeID(value)
	if menumods_ReferenceableTypes[value] then
		return true
	end
	
	return false
end

function menumods.string.WriteType(str, value, ...)
	if (not (value == value)) then
		str = menumods.string.AppendValues(str, 1)
		
		return str
	end
	
	if (not menumods.IsValidType(value)) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write an invalid type.")
		
		return
	end
	
	local valType = TypeID(value)
	
	local newValType = menumods.TypeIDToIndex(valType)
	
	str = menumods.string.AppendValues(str, newValType)
	
	str = menumods_WriteTypeFuncs[newValType](str, value, ...)
	
	return str
end

function menumods.string.ReadType(str, ...)
	local preValType, newStr = menumods.string.ReadValues(str, 1)
	str = newStr
	local valType = tonumber(preValType[1])
	local newValType
	local abort = false
	
	if isnumber(valType) then
		newValType = menumods.IndexToTypeID(valType)
	end
	
	if (not isnumber(newValType)) then
		abort = true
	end
	
	if abort then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to read an invalid type.")
		
		return
	end
	
	local newVal
	newVal, str = menumods_ReadTypeFuncs[valType](str, ...)
	
	return newVal, str
end

function menumods.GetWriteFunction(value)
	local newValType = menumods.TypeIDToIndex(value)
	
	if (not isnumber(newValType)) then
		return nil
	end
	
	return menumods_WriteTypeFuncs[newValType]
end

function menumods.GetReadFunction(value)
	local newValType = menumods.TypeIDToIndex(value)
	
	if (not isnumber(newValType)) then
		return nil
	end
	
	return menumods_ReadTypeFuncs[newValType]
end

function menumods.GetWriteFunctionFromType(value)
	return menumods_WriteTypeFuncs[value]
end

function menumods.GetReadFunctionFromType(value)
	return menumods_ReadTypeFuncs[value]
end

function menumods.GetTableValue(tab, ...)
	local address = {...}
	local currTab = tab
	
	for k, v in ipairs(address) do
		if istable(currTab) then
			currTab = currTab[v]
		else
			currTab = nil
			
			break
		end
	end
	
	return currTab
end

function menumods.SetTableValue(tab, val, ...)
	local address = {...}
	local addressCount = #address
	local currTab = tab
	
	for k, v in ipairs(address) do
		if (k < addressCount) then
			if (not istable(currTab[v])) then
				currTab[v] = {}
			end
			
			currTab = currTab[v]
		else
			currTab[v] = val
			
			break
		end
	end
end

menumods.string.WriteTable = function(str, tab, valueReferences, tree)
	if (not istable(tab)) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to write a non-table value as a table.")
		
		return
	end
	
	if (not istable(valueReferences)) then
		valueReferences = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	valueReferences[tab] = tree
	
	local newTab = {}
	local tabCount = 0
	
	for k, v in pairs(tab) do
		if (menumods.IsValidType(k) and menumods.IsValidType(v)) then
			newTab[k] = v
			tabCount = tabCount + 1
		end
	end
	
	str = menumods.string.WriteNumber(str, tabCount)
	
	local keyNumber = 1
	
	for k, v in pairs(newTab) do
		local kIsTable = istable(k)
		local vIsTable = istable(v)
		
		local kIsReference
		local vIsReference
		
		if ((k == nil) or (not valueReferences[k])) then
			kIsReference = false
		else
			kIsReference = true
		end
		
		if ((v == nil) or (not valueReferences[v])) then
			vIsReference = false
		else
			vIsReference = true
		end
		
		str = menumods.string.WriteBool(str, kIsReference)
		
		if (not kIsReference) then
			str = menumods.string.WriteBool(str, kIsTable)
			
			if (not kIsTable) then
				local isReferenceable = menumods.IsReferenceableType(k)
				
				if isReferenceable then
					local newReference = {}
					
					for k, v in ipairs(tree) do
						newReference[k] = v
					end
					
					table.insert(newReference, (#newReference + 1), keyNumber)
					table.insert(newReference, (#newReference + 1), false)
					
					valueReferences[k] = newReference
				end
				
				str = menumods.string.WriteBool(str, isReferenceable)
				str = menumods.string.WriteType(str, k, valueReferences, tree)
			else
				table.insert(tree, (#tree + 1), keyNumber)
				table.insert(tree, (#tree + 1), false)
				
				str = menumods.string.WriteTable(str, k, valueReferences, tree)
				
				table.remove(tree, #tree)
				table.remove(tree, #tree)
			end
		else
			local kReference = valueReferences[k]
			local treeCount = math.floor(#kReference / 2)
			
			str = menumods.string.WriteNumber(str, treeCount)
			
			for i = 1, treeCount do
				str = menumods.string.WriteNumber(str, kReference[2 * i - 1])
				str = menumods.string.WriteBool(str, kReference[2 * i])
			end
		end
		
		str = menumods.string.WriteBool(str, vIsReference)
		
		if (not vIsReference) then
			str = menumods.string.WriteBool(str, vIsTable)
			
			if (not vIsTable) then
				local isReferenceable = menumods.IsReferenceableType(v)
				
				if isReferenceable then
					local newReference = {}
					
					for k, v in ipairs(tree) do
						newReference[k] = v
					end
					
					table.insert(newReference, (#newReference + 1), keyNumber)
					table.insert(newReference, (#newReference + 1), true)
					
					valueReferences[v] = newReference
				end
				
				str = menumods.string.WriteBool(str, isReferenceable)
				str = menumods.string.WriteType(str, v, valueReferences, tree)
			else
				table.insert(tree, (#tree + 1), keyNumber)
				table.insert(tree, (#tree + 1), true)
				
				str = menumods.string.WriteTable(str, v, valueReferences, tree)
				
				table.remove(tree, #tree)
				table.remove(tree, #tree)
			end
		else
			local vReference = valueReferences[v]
			local treeCount = math.floor(#vReference / 2)
			
			str = menumods.string.WriteNumber(str, treeCount)
			
			for i = 1, treeCount do
				str = menumods.string.WriteNumber(str, vReference[2 * i - 1])
				str = menumods.string.WriteBool(str, vReference[2 * i])
			end
		end
		
		keyNumber = keyNumber + 1
	end
	
	return str
end

menumods.string.ReadTable = function(str, newTab, root, valueReferences, tree)
	if (not istable(newTab)) then
		newTab = {}
	end
	
	if (not istable(valueReferences)) then
		valueReferences = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	if (#tree > 0) then
		menumods.SetTableValue(valueReferences, newTab, unpack(tree))
	else
		root = newTab
	end
	
	local tabCount
	tabCount, str = menumods.string.ReadNumber(str)
	
	for keyNumber = 1, tabCount do
		local kIsReference
		local k
		local vIsReference
		local v
		
		kIsReference, str = menumods.string.ReadBool(str)
		
		if (not kIsReference) then
			local kIsTable
			kIsTable, str = menumods.string.ReadBool(str)
			
			table.insert(tree, (#tree + 1), keyNumber)
			table.insert(tree, (#tree + 1), false)
			
			if (not kIsTable) then
				local isReferenceable
				isReferenceable, str = menumods.string.ReadBool(str)
				
				k, str = menumods.string.ReadType(str, root, valueReferences, tree)
				
				if isReferenceable then
					menumods.SetTableValue(valueReferences, k, unpack(tree))
				end
			else
				k, str = menumods.string.ReadTable(str, nil, root, valueReferences, tree)
			end
			
			table.remove(tree, #tree)
			table.remove(tree, #tree)
		else
			local treeCount
			treeCount, str = menumods.string.ReadNumber(str)
			
			if (treeCount > 0) then
				local currTree = {}
				
				for i = 1, treeCount do
					local currIndex
					local keyOrValue
					
					currIndex, str = menumods.string.ReadNumber(str)
					keyOrValue, str = menumods.string.ReadBool(str)
					
					table.insert(currTree, (#currTree + 1), currIndex)
					table.insert(currTree, (#currTree + 1), keyOrValue)
				end
				
				k = menumods.GetTableValue(valueReferences, unpack(currTree))
			else
				k = root
			end
		end
		
		vIsReference, str = menumods.string.ReadBool(str)
		
		if (not vIsReference) then
			local vIsTable
			vIsTable, str = menumods.string.ReadBool(str)
			
			table.insert(tree, (#tree + 1), keyNumber)
			table.insert(tree, (#tree + 1), true)
			
			if (not vIsTable) then
				local isReferenceable
				isReferenceable, str = menumods.string.ReadBool(str)
				
				v, str = menumods.string.ReadType(str, root, valueReferences, tree)
				
				if isReferenceable then
					menumods.SetTableValue(valueReferences, v, unpack(tree))
				end
			else
				v, str = menumods.string.ReadTable(str, nil, root, valueReferences, tree)
			end
			
			table.remove(tree, #tree)
			table.remove(tree, #tree)
		else
			local treeCount
			treeCount, str = menumods.string.ReadNumber(str)
			
			if (treeCount > 0) then
				local currTree = {}
				
				for i = 1, treeCount do
					local currIndex
					local keyOrValue
					
					currIndex, str = menumods.string.ReadNumber(str)
					keyOrValue, str = menumods.string.ReadBool(str)
					
					table.insert(currTree, (#currTree + 1), currIndex)
					table.insert(currTree, (#currTree + 1), keyOrValue)
				end
				
				v = menumods.GetTableValue(valueReferences, unpack(currTree))
			else
				v = root
			end
		end
		
		newTab[k] = v
	end
	
	return newTab, str
end

menumods_WriteTypeFuncs[6] = menumods.string.WriteTable
menumods_ReadTypeFuncs[6] = menumods.string.ReadTable

local function WriteEntity(index, str, ent, valueReferences, tree)
	if (not istable(valueReferences)) then
		valueReferences = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	local entClass
	
	if ent:IsValid() then
		if isfunction(ent.GetClass) then
			entClass = ent:GetClass()
		elseif isstring(ent.ClassName) then
			entClass = ent.ClassName
		else
			str = menumods.string.WriteBool(str, false)
			
			return str
		end
		
		str = menumods.string.WriteBool(str, true)
	else
		str = menumods.string.WriteBool(str, false)
		
		return str
	end
	
	local newReference = {}
	
	for k, v in pairs(tree) do
		newReference[k] = v
	end
	
	table.insert(newReference, (#newReference + 1), 1)
	table.insert(newReference, (#newReference + 1), false)
	
	valueReferences[ent] = newReference
	
	table.insert(tree, (#tree + 1), 1)
	table.insert(tree, (#tree + 1), true)
	
	str = menumods.string.WriteString(str, entClass)
	
	local entType = menumods.IndexToTypeID(index)
	
	if (entType == TYPE_ENTITY) then
		str = menumods.string.WriteVector(str, ent:GetPos())
		str = menumods.string.WriteAngle(str, ent:GetAngles())
		str = menumods.string.WriteTable(str, {ent:GetTable(), ent:GetSaveTable()}, valueReferences, tree)
	elseif (entType == TYPE_PANEL) then
		local entPos = {ent:GetPos()}
		
		str = menumods.string.WriteNumber(str, entPos[1])
		str = menumods.string.WriteNumber(str, entPos[2])
		str = menumods.string.WriteTable(str, ent:GetTable(), valueReferences, tree)
	end
	
	table.remove(tree, #tree)
	table.remove(tree, #tree)
	
	return str
end

local function ReadEntity(index, str, root, valueReferences, tree)
	if (not istable(valueReferences)) then
		valueReferences = {}
	end
	
	if (not istable(tree)) then
		tree = {}
	end
	
	local entIsValid
	entIsValid, str = menumods.string.ReadBool(str)
	
	if (not entIsValid) then
		return NULL, str
	end
	
	local entClass
	entClass, str = menumods.string.ReadString(str)
	
	local entType = menumods.IndexToTypeID(index)
	local ent
	
	local oldTree = {}
	
	for k, v in pairs(tree) do
		oldTree[k] = v
	end
	
	table.insert(oldTree, (#oldTree + 1), 1)
	table.insert(oldTree, (#oldTree + 1), false)
	
	table.insert(tree, (#tree + 1), 1)
	table.insert(tree, (#tree + 1), true)
	
	if (entType == TYPE_ENTITY) then
		if (not menumods_CanCreateEntities) then
			menumods.SetTableValue(valueReferences, NULL, unpack(oldTree))
			
			_, str = menumods.string.ReadVector(str)
			_, str = menumods.string.ReadAngle(str)
			_, str = menumods.string.ReadTable(str, nil, root, valueReferences, tree)
			
			table.remove(tree, #tree)
			table.remove(tree, #tree)
			
			return NULL, str
		end
		
		local entPos
		local entAngles
		local entTable
		
		entPos, str = menumods.string.ReadVector(str)
		entAngles, str = menumods.string.ReadAngle(str)
		
		ent = ents.Create(entClass)
		
		ent:SetPos(entPos)
		ent:SetAngles(entAngles)
		
		ent:Spawn()
		
		menumods.SetTableValue(valueReferences, ent, unpack(oldTree))
		
		entTable, str = menumods.string.ReadTable(str, nil, root, valueReferences, tree)
			
		if (not ent:IsValid()) then
			table.remove(tree, #tree)
			table.remove(tree, #tree)
			
			return ent, str
		end
		
		local luaTable = entTable[1]
		local saveTable = entTable[2]
		
		local newLuaTable = ent:GetTable()
		
		for k, v in pairs(luaTable) do
			newLuaTable[k] = v
		end
		
		ent:SetTable(newLuaTable)
		
		for k, v in pairs(saveTable) do
			ent:SetSaveValue(k, v)
		end
		
		ent:Activate()
	elseif (entType == TYPE_PANEL) then
		local entPosX
		local entPosY
		local entTable
		
		entPosX, str = menumods.string.ReadNumber(str)
		entPosY, str = menumods.string.ReadNumber(str)
		
		ent = vgui.Create(entClass)
		
		menumods.SetTableValue(valueReferences, ent, unpack(oldTree))
		
		entTable, str = menumods.string.ReadTable(str, nil, root, valueReferences, tree)
			
		if (not ent:IsValid()) then
			table.remove(tree, #tree)
			table.remove(tree, #tree)
			
			return ent, str
		end
		
		ent:SetPos(entPosX, entPosY)
		
		local newLuaTable = ent:GetTable()
		
		for k, v in pairs(entTable) do
			newLuaTable[k] = v
		end
	end
	
	table.remove(tree, #tree)
	table.remove(tree, #tree)
	
	return ent, str
end

function menumods.string.WriteEntity(...)
	return WriteEntity(9, ...)
end

function menumods.string.ReadEntity(...)
	return ReadEntity(9, ...)
end

menumods_WriteTypeFuncs[9] = menumods.string.WriteEntity
menumods_ReadTypeFuncs[9] = menumods.string.ReadEntity

function menumods.string.WritePanel(...)
	return WriteEntity(10, ...)
end

function menumods.string.ReadPanel(...)
	return ReadEntity(10, ...)
end

menumods_WriteTypeFuncs[10] = menumods.string.WritePanel
menumods_ReadTypeFuncs[10] = menumods.string.ReadPanel

local function InitPostEntity()
	if SERVER then
		menumods_CanCreateEntities = true
	end
end

hook.Add("InitPostEntity", "menumods_InitPostEntity", InitPostEntity)

include("includes/modules/netdata.lua")

menumods.net = {}

local CurrMsg_Send
local CurrMsg_Receive

local NetReceiveFuncs = {}
local NetDir_Receive
local NetDir_Send

local NetEnabled = false
local ShouldSendMsg = false

local MenuDir = "menumods_net_menu"
local ClientDir = "menumods_net_client"

if MENU_DLL then
	NetDir_Receive = MenuDir
	NetDir_Send = ClientDir
else
	NetDir_Receive = ClientDir
	NetDir_Send = MenuDir
end

function menumods.net.Start(identifier)
	if (not isstring(identifier)) then return end
	
	local newMsg = netdata.Create("base_netdata")
	
	newMsg:WriteString(identifier)
	
	CurrMsg_Send = {identifier, newMsg}
end

local IsInGame = IsInGame

if (not isfunction(IsInGame)) then
	IsInGame = function()
		return true
	end
end

local function SendMsg()
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
			local start, endPos = string.find(v, "net_msg__%d+%.txt$")
			
			if start then
				local fullMatch = string.sub(v, start, endPos)
				local start, endPos = string.find(fullMatch, "%d+%.txt$")
				
				if start then
					local newMatch = string.sub(fullMatch, start, endPos)
					
					newMatch = string.gsub(newMatch, "%.txt$", "")
					
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

function menumods.net.Send()
	if ((not NetEnabled) or (not ShouldSendMsg) or (not IsInGame())) then
		if istable(CurrMsg_Send) then
			if CurrMsg_Send[2]:IsValid() then
				CurrMsg_Send[2]:Remove()
			end
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	SendMsg()
end

function menumods.net.Receive(identifier, func)
	if (not isstring(identifier)) then return end
	if (not isfunction(func)) then return end
	if isfunction(NetReceiveFuncs[identifier]) then return end
	
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

function menumods.net.WriteEntity(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WriteEntity(val)
end

function menumods.net.WritePanel(val)
	if ((not istable(CurrMsg_Send)) or (not isstring(CurrMsg_Send[1])) or (not CurrMsg_Send[2]:IsValid())) then
		if CurrMsg_Send[2]:IsValid() then
			CurrMsg_Send[2]:Remove()
		end
		
		CurrMsg_Send = nil
		
		return
	end
	
	local message = CurrMsg_Send[2]
	
	message:WritePanel(val)
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

function menumods.net.ReadEntity()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadEntity()
end

function menumods.net.ReadPanel()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadPanel()
end

function menumods.net.ReadVector()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadVector()
end

function menumods.net.ReadType()
	if ((not CurrMsg_Receive) or (not CurrMsg_Receive:IsValid())) then return end
	
	return CurrMsg_Receive:ReadType()
end

local SendNotifyDir = (NetDir_Send .. "/shouldsend.txt")
local ReceiveNotifyDir = (NetDir_Receive .. "/shouldsend.txt")

local Warning = false

local CurrTickRate = tickRateDefault
local LastUpdate = SysTime()

local function ReceiveTickRate()
	local newEnabled = menumods.net.ReadBool()
	local newTickRate = menumods.net.ReadNumber()
	
	NetEnabled = newEnabled
	CurrTickRate = newTickRate
	
	if ((not MENU_DLL) and IsInGame() and ShouldSendMsg) then
		menumods.net.Start("menumods_net_update")
		menumods.net.WriteBool(newEnabled)
		menumods.net.WriteNumber(newTickRate)
		
		if ShouldSendMsg then
			SendMsg()
		else
			if istable(CurrMsg_Send) then
				if CurrMsg_Send[2]:IsValid() then
					CurrMsg_Send[2]:Remove()
				end
			end
			
			CurrMsg_Send = nil
		end
	end
end

menumods.net.Receive("menumods_net_update", ReceiveTickRate)

local function Think()
	local currTime = SysTime()
	
	if (CurrTickRate > 0) then
		local deltaTime = currTime - LastUpdate
		
		if (deltaTime < (1 / CurrTickRate)) then return end
	end
	
	LastUpdate = currTime
	
	if (MENU_DLL and IsInGame() and ShouldSendMsg) then
		local newEnabled = (GetConVarNumber("menumods_net_enabled") != 0)
		local newTickRate = GetConVarNumber("menumods_net_tickRate")
		
		if ((NetEnabled != newEnabled) or (CurrTickRate != newTickRate)) then
			menumods.net.Start("menumods_net_update")
			menumods.net.WriteBool(newEnabled)
			menumods.net.WriteNumber(newTickRate)
			
			if ShouldSendMsg then
				SendMsg()
			else
				if istable(CurrMsg_Send) then
					if CurrMsg_Send[2]:IsValid() then
						CurrMsg_Send[2]:Remove()
					end
				end
				
				CurrMsg_Send = nil
			end
		end
	end
	
	if (not file.Exists(SendNotifyDir, "DATA")) then
		local filenameTab = string.Explode("/", SendNotifyDir, false)
		local dirCount = #filenameTab
		local currFolder
		
		for k, v in ipairs(filenameTab) do
			if (k < dirCount) then
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
			else
				break
			end
		end
		
		if MENU_DLL then
			file.Write(SendNotifyDir, "This file indicates to the client state that it may send data to the menu state.")
		else
			file.Write(SendNotifyDir, "This file indicates to the menu state that it may send data to the client state.")
		end
	end
	
	if file.Exists(ReceiveNotifyDir, "DATA") then
		ShouldSendMsg = true
		Warning = false
	elseif Warning then
		ShouldSendMsg = false
	else
		Warning = true
	end
	
	if (ShouldSendMsg and (not Warning)) then
		file.Delete(ReceiveNotifyDir)
	end
	
	if ((not ShouldSendMsg) or (not IsInGame())) then
		local files = file.Find((NetDir_Receive .. "/*.txt"), "DATA")
		
		for k, v in ipairs(files) do
			local filename = (NetDir_Receive .. "/" .. v)
			
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

function menumods.net.IsConnected()
	if ShouldSendMsg then
		return true
	end
	
	return false
end

hook.Add("Think", "MenuMods_Net", Think)
