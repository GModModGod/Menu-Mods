
local NullLuaJS = {}

function NullLuaJS:IsValid()
	return false
end

NULL_JS = {}

function NULL_JS:IsValid()
	return false
end

local AllJSDocs = AllJSDocs or {}
local AllJSDocsCount = AllJSDocsCount or 0
local AllValidJSDocsCount = AllValidJSDocsCount or 0

local JSDocs = JSDocs or {}

JSDocs.base_js = {}

JSDocs.base_js.BaseClass = {}
JSDocs.base_js.ClassName = "base_js"
JSDocs.base_js.Content = ""
JSDocs.base_js.UniqueID = -1
JSDocs.base_js.Removing = false

function JSDocs.base_js:Index()
	return self.UniqueID
end

function JSDocs.base_js:Initialize()
	
end

function JSDocs.base_js:OnRemove()

end

function JSDocs.base_js:Remove()
	AllValidJSDocsCount = AllValidJSDocsCount - 1
	
	if (AllValidJSDocsCount < 0) then
		AllValidJSDocsCount = 0
	end
	
	self.Removing = true
	AllJSDocs[self.UniqueID] = nil
	self:OnRemove()
	
	AllJSDocsCount = AllJSDocsCount - 1
	
	if (AllJSDocsCount < 0) then
		AllJSDocsCount = 0
	end
end

function JSDocs.base_js:IsValid()
	return (not self.Removing) and (AllJSDocs[self.UniqueID] == self)
end

function JSDocs.base_js:GetClass()
	return self.ClassName
end

function JSDocs.base_js:GetContent()
	return self.Content
end

function JSDocs.base_js:SetContent(content)
	if (not isstring(content)) then return end
	
	self.Content = content
end

function JSDocs.base_js:OnRunInPanel(HTML)
	
end

function JSDocs.base_js:RunInPanel(HTML)
	if (self.CurrentPanel and self.CurrentPanel:IsValid()) then
		local newDoc = luajs.Create(self.ClassName)
		
		newDoc:SetHead(self.Head)
		newDoc:SetBody(self.Body)
		
		newDoc:OpenInPanel(HTML)
		
		return
	end
	
	self.CurrentPanel = HTML
	
	if (not self:IsValid()) then return end
	
	HTML:Call(self.Content)
	
	self:OnRunInPanel(HTML)
end

function JSDocs.base_js:RunNewInCurrentPanel(class, doNotRemove)
	if (not self.CurrentPanel) then return end
	if (not self.CurrentPanel:IsValid()) then return end
	
	local newPanel = self.CurrentPanel
	
	if (not doNotRemove) then
		self:Remove()
	end
	
	local newDoc = luajs.Create(class)
	
	newDoc:RunInPanel(newPanel)
end

function JSDocs.base_js:GetCurrentPanel()
	if (not self.CurrentPanel) then
		return NULL
	end
	
	return self.CurrentPanel
end

baseclass.Set("base_js", JSDocs.base_js)

luajs = {}

function luajs.Register(tab, name)
	local newName = string.lower(name)
	
	tab.ClassName = name
	
	baseclass.Set(newName, tab)
	
	tab.BaseClass = baseclass.Get(tab.Base)
	
	JSDocs[name] = tab
end

local function FindUniqueID(luajs)
	local currID = 1
	local foundID = false
	
	while (not foundID) do
		if (not AllJSDocs[currID]) then
			foundID = true
		else
			currID = currID + 1
		end
	end
	
	AllJSDocs[currID] = luajs
	luajs.UniqueID = currID
end

function luajs.Create(class)
	if (not JSDocs[class]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to create a new JavaScript document object from a non-existent class.")
		
		return
	end
	
	local newObject = table.Copy(JSDocs[class])
	
	AllJSDocsCount = AllJSDocsCount + 1
	
	FindUniqueID(newObject)
	
	AllValidJSDocsCount = AllValidJSDocsCount + 1
	
	newObject:Initialize()
	
	return newObject
end

function luajs.GetClasses()
	return JSDocs
end

function luajs.GetClassTable(class)
	return JSDocs[class]
end

function luajs.GetClassTableCopy(class)
	if (not JSDocs[class]) then
		return nil
	end
	
	return table.Copy(JSDocs[class])
end

function luajs.GetByIndex(index)
	if (not AllJSDocs[index]) then return NullLuaJS end
	
	return AllJSDocs[index]
end

function luajs.GetAll()
	local tab = {}
	
	for k, v in pairs(AllJSDocs) do
		table.insert(tab, v)
	end
	
	return tab
end

function luajs.GetCount(includeRemoved)
	if includeRemoved then
		return (AllJSDocsCount + 0)
	end
	
	return (AllValidJSDocsCount + 0)
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

function luajs.FindByClass(class)
	local tab = {}
	
	for k, v in pairs(AllJSDocs) do
		if string_CompareToSearch(v.ClassName, class, false) then
			table.insert(tab, v)
		end
	end
	
	return tab
end
