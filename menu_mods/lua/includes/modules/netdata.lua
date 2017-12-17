
netdata = {}

local NullNetData = {}

function NullNetData:IsValid()
	return false
end

NULL_NET = {}

function NULL_NET:IsValid()
	return false
end

local AllNetDatas = AllNetDatas or {}
local AllNetDatasCount = AllNetDatasCount or 0
local AllValidNetDatasCount = AllValidNetDatasCount or 0

local NetDatas = NetDatas or {}

NetDatas.base_netdata = {}

NetDatas.base_netdata.BaseClass = {}
NetDatas.base_netdata.ClassName = "base_netdata"
NetDatas.base_netdata.Data = ""
NetDatas.base_netdata.UniqueID = -1
NetDatas.base_netdata.Removing = false

function NetDatas.base_netdata:Index()
	return self.UniqueID
end

function NetDatas.base_netdata:Initialize()
	
end

function NetDatas.base_netdata:OnRemove()

end

function NetDatas.base_netdata:Remove()
	AllValidNetDatasCount = AllValidNetDatasCount - 1
	
	if (AllValidNetDatasCount < 0) then
		AllValidNetDatasCount = 0
	end
	
	self.Removing = true
	AllNetDatas[self.UniqueID] = nil
	self:OnRemove()
	
	AllNetDatasCount = AllNetDatasCount - 1
	
	if (AllNetDatasCount < 0) then
		AllNetDatasCount = 0
	end
end

function NetDatas.base_netdata:IsValid()
	return (not self.Removing) and (AllNetDatas[self.UniqueID] == self)
end

function NetDatas.base_netdata:GetClass()
	return self.ClassName
end

function NetDatas.base_netdata:OnWriteToFile(filename)
	
end

function NetDatas.base_netdata:OnReadFromFile(filename, dir)
	
end

function NetDatas.base_netdata:GetData()
	return self.Data
end

function NetDatas.base_netdata:SetData(data)
	if (not isstring(data)) then return end
	
	self.Data = data
end

function NetDatas.base_netdata:WriteDataToFile(filename)
	local filenameTab = string.Explode("/", filename, false)
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
	
	self:OnWriteToFile(filename)
	
	local compressedData = util.Compress(self.Data)
	
	if (not compressedData) then
		compressedData = ""
	end
	
	file.Write(filename, compressedData)
end

function NetDatas.base_netdata:ReadDataFromFile(filename, dir)
	if (not file.Exists(filename, dir)) then return end
	
	local compressedData = file.Read(filename, dir)
	
	local data = util.Decompress(compressedData)
	
	if (not data) then
		data = ""
	end
	
	self.Data = data
	
	self:OnReadFromFile(filename, dir)
end

function NetDatas.base_netdata:WriteAngle(val)
	if (not isangle(val)) then return end
	
	self.Data = menumods.string.WriteAngle(self.Data, val)
end

function NetDatas.base_netdata:WriteBool(val)
	if (not isbool(val)) then return end
	
	self.Data = menumods.string.WriteBool(self.Data, val)
end

function NetDatas.base_netdata:WriteNumber(val)
	if (not isnumber(val)) then return end
	
	self.Data = menumods.string.WriteNumber(self.Data, val)
end

function NetDatas.base_netdata:WriteString(val)
	if (not isstring(val)) then return end
	
	self.Data = menumods.string.WriteString(self.Data, val)
end

function NetDatas.base_netdata:WriteTable(val)
	if (not istable(val)) then return end
	
	self.Data = menumods.string.WriteTable(self.Data, val)
end

function NetDatas.base_netdata:WriteVector(val)
	if (not isvector(val)) then return end
	
	self.Data = menumods.string.WriteVector(self.Data, val)
end

function NetDatas.base_netdata:WriteType(val)
	if (not menumods.IsValidType(val)) then return end
	
	self.Data = menumods.string.WriteType(self.Data, val)
end

function NetDatas.base_netdata:ReadAngle()
	local newVal, newData = menumods.string.ReadAngle(self.Data)
	
	self.Data = newData
	
	return newVal
end

function NetDatas.base_netdata:ReadBool()
	local newVal, newData = menumods.string.ReadBool(self.Data)
	
	self.Data = newData
	
	return newVal
end

function NetDatas.base_netdata:ReadNumber()
	local newVal, newData = menumods.string.ReadNumber(self.Data)
	
	self.Data = newData
	
	return newVal
end

function NetDatas.base_netdata:ReadString()
	local newVal, newData = menumods.string.ReadString(self.Data)
	
	self.Data = newData
	
	return newVal
end

function NetDatas.base_netdata:ReadTable(newTab)
	local newVal, newData = menumods.string.ReadTable(self.Data, newTab)
	
	self.Data = newData
	
	return newVal
end

function NetDatas.base_netdata:ReadVector()
	local newVal, newData = menumods.string.ReadVector(self.Data)
	
	self.Data = newData
	
	return newVal
end

function NetDatas.base_netdata:ReadType()
	local newVal, newData = menumods.string.ReadType(self.Data)
	
	self.Data = newData
	
	return newVal
end

baseclass.Set("base_netdata", NetDatas.base_netdata)

function netdata.Register(tab, name)
	local newName = string.lower(name)
	
	tab.ClassName = name
	
	baseclass.Set(newName, tab)
	
	tab.BaseClass = baseclass.Get(tab.Base)
	
	NetDatas[name] = tab
end

local function FindUniqueID(savDat)
	local currID = 1
	local foundID = false
	
	while (not foundID) do
		if (not AllNetDatas[currID]) then
			foundID = true
		else
			currID = currID + 1
		end
	end
	
	AllNetDatas[currID] = savDat
	savDat.UniqueID = currID
end

function netdata.Create(class)
	if (not NetDatas[class]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to create a new NetData object from a non-existent class.")
		
		return
	end
	
	local newObject = table.Copy(NetDatas[class])
	
	AllNetDatasCount = AllNetDatasCount + 1
	
	FindUniqueID(newObject)
	
	AllValidNetDatasCount = AllValidNetDatasCount + 1
	
	newObject:Initialize()
	
	return newObject
end

function netdata.GetClasses()
	return NetDatas
end

function netdata.GetClassTable(class)
	return NetDatas[class]
end

function netdata.GetClassTableCopy(class)
	if (not NetDatas[class]) then
		return nil
	end
	
	return table.Copy(NetDatas[class])
end

function netdata.GetByIndex(index)
	if (not AllNetDatas[index]) then return NullNetData end
	
	return AllNetDatas[index]
end

function netdata.GetAll()
	local tab = {}
	
	for k, v in pairs(AllNetDatas) do
		table.insert(tab, v)
	end
	
	return tab
end

function netdata.GetCount(includeRemoved)
	if includeRemoved then
		return (AllNetDatasCount + 0)
	end
	
	return (AllValidNetDatasCount + 0)
end

local function string_CompareToSearch(str, search, caseSensitive)
	local newStr
	local searchTab
	
	if caseSensitive then
		newStr = ("" .. str)
		searchTab = string.Explode("*", search, false)
	else
		newStr = string.lower(str)
		searchTab = string.Explode("*", string.lower(search), false)
	end
	
	local currPos = 1
	local doesMatch = true
	
	for k, v in ipairs(searchTab) do
		if (v != "") then
			if (k > 1) then
				local start, endpos = string.find(str, v, currPos, true)
				
				if start then
					currPos = endpos
				else
					doesMatch = false
					
					break
				end
			else
				local start, endpos = string.find(str, v, currPos, true)
				
				if start then
					currPos = endpos
					
					if (start != 1) then
						doesMatch = false
						
						break
					end
				else
					doesMatch = false
					
					break
				end
			end
		end
	end
	
	return doesMatch
end

function netdata.FindByClass(class)
	local tab = {}
	
	for k, v in pairs(AllNetDatas) do
		if string_CompareToSearch(v.ClassName, class, false) then
			table.insert(tab, v)
		end
	end
	
	return tab
end
