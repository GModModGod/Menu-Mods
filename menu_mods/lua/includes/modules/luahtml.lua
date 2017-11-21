
local NullLuaHTML = {}

function NullLuaHTML:IsValid()
	return false
end

NULL_HTML = {}

function NULL_HTML:IsValid()
	return false
end

local AllHTMLDocs = AllHTMLDocs or {}
local AllHTMLDocsCount = AllHTMLDocsCount or 0
local AllValidHTMLDocsCount = AllValidHTMLDocsCount or 0

local HTMLDocs = HTMLDocs or {}

HTMLDocs.base_html = {}

HTMLDocs.base_html.BaseClass = {}
HTMLDocs.base_html.ClassName = "base_html"
HTMLDocs.base_html.Head = ""
HTMLDocs.base_html.Body = ""
HTMLDocs.base_html.UniqueID = -1
HTMLDocs.base_html.Removing = false

function HTMLDocs.base_html:Index()
	return self.UniqueID
end

function HTMLDocs.base_html:Initialize()
	
end

function HTMLDocs.base_html:OnRemove()

end

function HTMLDocs.base_html:Remove()
	AllValidHTMLDocsCount = AllValidHTMLDocsCount - 1
	
	if (AllValidHTMLDocsCount < 0) then
		AllValidHTMLDocsCount = 0
	end
	
	self.Removing = true
	AllHTMLDocs[self.UniqueID] = nil
	self:OnRemove()
	
	AllHTMLDocsCount = AllHTMLDocsCount - 1
	
	if (AllHTMLDocsCount < 0) then
		AllHTMLDocsCount = 0
	end
end

function HTMLDocs.base_html:IsValid()
	return (not self.Removing) and (AllHTMLDocs[self.UniqueID] == self)
end

function HTMLDocs.base_html:GetClass()
	return self.ClassName
end

function HTMLDocs.base_html:GetHead()
	return self.Head
end

function HTMLDocs.base_html:SetHead(head)
	if (not isstring(head)) then return end
	
	self.Head = head
end

function HTMLDocs.base_html:GetBody()
	return self.Body
end

function HTMLDocs.base_html:SetBody(body)
	if (not isstring(body)) then return end
	
	self.Body = body
end

function HTMLDocs.base_html:OpenInPanel(HTML)
	if (self.CurrentPanel and self.CurrentPanel:IsValid()) then
		local newDoc = luahtml.Create(self.ClassName)
		
		newDoc:SetHead(self.Head)
		newDoc:SetBody(self.Body)
		
		newDoc:OpenInPanel(HTML)
		
		return
	end
	
	self.CurrentPanel = HTML
	
	if (not self:IsValid()) then return end
	
	HTML:SetAllowLua(true)
	
	HTML:OpenURL("asset://garrysmod/html/blank.html")
	
	local exec = "document.head.innerHTML = document.head.innerHTML + \"" .. menumods.string.LevelPush(self.Head, 1, true) .. "\";\ndocument.body.innerHTML = document.body.innerHTML + \"" .. menumods.string.LevelPush(self.Body, 1, true) .. "\";\nvar allElements = document.getElementsByTagName(\"*\");\nvar currIndex;\nfor (currIndex in allElements) {\nvar currElement = allElements[currIndex];\nif (currElement.hasAttribute != undefined) {\nif (currElement.hasAttribute(\"lua-href\")) {\ncurrElement.setAttribute(\"href\", \"#/\");\ncurrElement.addEventListener(\"click\", function(){\nlua.Run(\"local document = luahtml.GetByIndex(" .. self.UniqueID .. ")\\nif document:IsValid() then\\ndocument:OpenNewInCurrentPanel(menumods.string.LevelPush(\\\"\" + this.getAttribute(\"lua-href\") + \"\\\", 1, true))\\nend\");\n});\n}\nif ((currElement.tagName === \"SCRIPT\") && (currElement.hasAttribute(\"lua-src\"))) {\nlua.Run(\"local document = luahtml.GetByIndex(" .. self.UniqueID .. ")\\nif document:IsValid() then\\ndocument:RunScript(menumods.string.LevelPush(\\\"\" + currElement.getAttribute(\"lua-src\") + \"\\\", 1, true))\\nend\");\n}\n}\n}\n"
	
	HTML:Call(exec)
end

function HTMLDocs.base_html:OpenNewInCurrentPanel(class, doNotRemove)
	if (not self.CurrentPanel) then return end
	if (not self.CurrentPanel:IsValid()) then return end
	
	local newPanel = self.CurrentPanel
	
	if (not doNotRemove) then
		self:Remove()
	end
	
	local newDoc = luahtml.Create(class)
	
	newDoc:OpenInPanel(newPanel)
end

function HTMLDocs.base_html:RunScript(class, doNotRemove)
	if (not self.CurrentPanel) then return end
	if (not self.CurrentPanel:IsValid()) then return end
	
	local newPanel = self.CurrentPanel
	
	local script = luajs.Create(class)
	
	script:RunInPanel(newPanel)
	
	if (not doNotRemove) then
		script:Remove()
	end
end

function HTMLDocs.base_html:GetCurrentPanel()
	if (not self.CurrentPanel) then
		return NULL
	end
	
	return self.CurrentPanel
end

baseclass.Set("base_html", HTMLDocs.base_html)

luahtml = {}

function luahtml.Register(tab, name)
	local newName = string.lower(name)
	
	tab.ClassName = name
	
	baseclass.Set(newName, tab)
	
	tab.BaseClass = baseclass.Get(tab.Base)
	
	HTMLDocs[name] = tab
end

local function FindUniqueID(luahtml)
	local currID = 1
	local foundID = false
	
	while (not foundID) do
		if (not AllHTMLDocs[currID]) then
			foundID = true
		else
			currID = currID + 1
		end
	end
	
	AllHTMLDocs[currID] = luahtml
	luahtml.UniqueID = currID
end

function luahtml.Create(class)
	if (not HTMLDocs[class]) then
		local errInfo = debug.getinfo(0, "S")
		
		error("[ERROR] " .. errInfo.short_src .. ": Attempted to create a new HTML document object from a non-existent class.")
		
		return
	end
	
	local newObject = table.Copy(HTMLDocs[class])
	
	AllHTMLDocsCount = AllHTMLDocsCount + 1
	
	FindUniqueID(newObject)
	
	AllValidHTMLDocsCount = AllValidHTMLDocsCount + 1
	
	newObject:Initialize()
	
	return newObject
end

function luahtml.GetClasses()
	return HTMLDocs
end

function luahtml.GetClassTable(class)
	return HTMLDocs[class]
end

function luahtml.GetClassTableCopy(class)
	if (not HTMLDocs[class]) then
		return nil
	end
	
	return table.Copy(HTMLDocs[class])
end

function luahtml.GetByIndex(index)
	if (not AllHTMLDocs[index]) then return NullLuaHTML end
	
	return AllHTMLDocs[index]
end

function luahtml.GetAll()
	local tab = {}
	
	for k, v in pairs(AllHTMLDocs) do
		table.insert(tab, v)
	end
	
	return tab
end

function luahtml.GetCount(includeRemoved)
	if includeRemoved then
		return (AllHTMLDocsCount + 0)
	end
	
	return (AllValidHTMLDocsCount + 0)
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

function luahtml.FindByClass(class)
	local tab = {}
	
	for k, v in pairs(AllHTMLDocs) do
		if string_CompareToSearch(v.ClassName, class, false) then
			table.insert(tab, v)
		end
	end
	
	return tab
end
