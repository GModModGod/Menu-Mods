
CreateConVar("menuMods_debugMode", 0, FCVAR_ARCHIVE)
CreateConVar("menumods_enableLogging", 0, FCVAR_ARCHIVE)

menumods = {}
menumods.hook = {}
menumods.string = {}

function menumods.include(filename)
	local exec = CompileString(file.Read(("lua/" .. filename), "GAME"), filename, true)
	
	exec()
end

local MenuMods_ElementTables = {}
local MenuMods_Elements = {}
local MenuMods_Hooks = {}
local MenuMods_IDs = {}

function menumods.CreateLog(content, extension)
	if (not file.IsDir("menu_mods_data", "DATA")) then
		file.CreateDir("menu_mods_data")
	end
	if (not file.IsDir("menu_mods_data/logs", "DATA")) then
		file.CreateDir("menu_mods_data/logs")
	end
	
	local currID = 0
	local filename
	
	local found = false
	
	while (not found) do
		currID = currID + 1
		
		filename = ("menu_mods_data/logs/log_" .. currID .. extension)
		
		if (not file.Exists(filename, "DATA")) then
			found = true
		end
	end
	
	if filename then
		file.Write(filename, content)
	end
end

local escChars = {
	"\a",
	"\b",
	"\f",
	"\n",
	"\r",
	"\t",
	"\v",
	"\\",
	"\"",
	"\'"
}

function menumods.string.LevelPush(str, numLevels, noOuterQuotes)
	local numLevels_new = numLevels
	
	if (not numLevels_new) then
		numLevels_new = 1
	end
	
	local newString = ("" .. str)
	
	for i = 1, numLevels_new do
		for k, v in pairs(escChars) do
			newString = string.Replace(newString, v, ("\\" .. v))
		end
		
		if (not noOuterQuotes) then
			newString = ("\"" .. newString .. "\"")
		end
	end
	
	return newString
end

function menumods.string.LevelPop(str, numLevels)
	local numLevels_new = numLevels
	
	if (not numLevels_new) then
		numLevels_new = 1
	end
	
	local newString = ("" .. str)
	
	for i = 1, numLevels_new do
		for k, v in pairs(escChars) do
			newString = string.gsub(newString, ("[^\\]" .. string.PatternSafe(v)), "")
			newString = string.Replace(newString, ("\\" .. v), v)
		end
	end
	
	return newString
end

function menumods.FindID(identifier)
	local found = false
	local currID = 0
	
	while (not found) do
		currID = currID + 1
		
		if (not MenuMods_IDs[currID]) then
			found = true
		end
	end
	
	MenuMods_IDs[currID] = identifier
	
	return currID
end

function menumods.RemoveID(id)
	MenuMods_IDs[id] = nil
end

function menumods.hook.Add(eventName, identifier, func)
	if (not isfunction(func)) then return end
	
	if (not MenuMods_Hooks[eventName]) then
		MenuMods_Hooks[eventName] = {}
	end
	
	if MenuMods_Hooks[eventName][identifier] then return end
	
	MenuMods_Hooks[eventName][identifier] = func
end

function menumods.hook.Remove(eventName, identifier)
	if (not MenuMods_Hooks[eventName]) then return end
	
	MenuMods_Hooks[eventName][identifier] = nil
	
	if (#MenuMods_Hooks[eventName] <= 0) then
		MenuMods_Hooks[eventName] = nil
	end
end

function menumods.hook.Run(eventName, ...)
	if (not MenuMods_Hooks[eventName]) then return true end
	
	local args_old = {...}
	local args = args_old
	
	local currOutput = true
	
	for k, v in pairs(MenuMods_Hooks[eventName]) do
		local result = v(unpack(args))
		
		if (result != nil) then
			if (not result) then
				currOutput = false
			end
		end
	end
	
	return currOutput
end

function menumods.hook.GetTable()
	local currTable = {}
	
	for k, v in pairs(MenuMods_Hooks) do
		local currIndex = k
		local currEvent = v
		
		currTable[currIndex] = {}
		
		for i, j in pairs(currEvent) do
			currTable[currIndex][i] = j
		end
	end
	
	return currTable
end

function menumods.AddElement(identifier, data)
	if MenuMods_ElementTables["" .. identifier] then return end
	if (not istable(data)) then return end
	
	data.identifier = ("" .. identifier)
	
	local newData_Old = data
	local newData = newData_Old
	
	MenuMods_ElementTables["" .. identifier] = newData
	
	table.insert(MenuMods_Elements, (#MenuMods_Elements + 1), ("" .. identifier))
end

function menumods.AddOption(identifier, data, onClick)
	if MenuMods_ElementTables["" .. identifier] then return end
	if (not istable(data)) then return end
	
	data.identifier = ("" .. identifier)
	
	local newData_Old = data
	local newData = newData_Old
	
	newData.tag = "A"
	
	newData.onClick = onClick
	
	table.insert(newData.attributes, (#newData.attributes + 1), {"href", "#/"})
	
	MenuMods_ElementTables["" .. identifier] = newData
	
	table.insert(MenuMods_Elements, (#MenuMods_Elements + 1), ("" .. identifier))
end

function menumods.AddLuaOption(identifier, data, callback)
	if MenuMods_ElementTables["" .. identifier] then return end
	if (not istable(data)) then return end
	
	data.identifier = ("" .. identifier)
	
	local newData_Old = data
	local newData = newData_Old
	
	newData.tag = "A"
	newData.callback = callback
	
	newData.onClick = "lua.Run(\"menumods.ExecuteElementCallback(\\\"" .. menumods.string.LevelPush(identifier, 2, true) .. "\\\")\")"
	
	table.insert(newData.attributes, (#newData.attributes + 1), {"href", "#/"})
	
	MenuMods_ElementTables["" .. identifier] = newData
	
	table.insert(MenuMods_Elements, (#MenuMods_Elements + 1), ("" .. identifier))
end

function menumods.ExecuteElementCallback(identifier)
	if MenuMods_ElementTables["" .. identifier] then return end
	
	return MenuMods_ElementTables["" .. identifier].callback()
end

function menumods.RemoveElementFromPage(identifier)
	if (not pnlMainMenu) then return end
	if (not pnlMainMenu.HTML) then return end
	if (not MenuMods_ElementTables["" .. identifier]) then return end
	
	local elementTable = MenuMods_ElementTables["" .. identifier]
	
	if (not elementTable.id) then return end
	
	pnlMainMenu.HTML:RemoveElement(elementTable.id)
	
	MenuMods_ElementTables["" .. identifier].disabled = true
end

function menumods.RemoveElement(identifier)
	menumods.RemoveElementFromPage(identifier)
	
	MenuMods_ElementTables["" .. identifier] = nil
end

function menumods.RemoveHTMLElement(searchType, ...)
	if (not pnlMainMenu) then return end
	if (not pnlMainMenu.HTML) then return end
	if (not isstring(searchType)) then return end
	
	if (searchType == "classname") then
		pnlMainMenu.HTML:RemoveElementByClassName(...)
	elseif (searchType == "id") then
		pnlMainMenu.HTML:RemoveElementByID(...)
	elseif (searchType == "menumodsid") then
		pnlMainMenu.HTML:RemoveElement(...)
	elseif (searchType == "name") then
		pnlMainMenu.HTML:RemoveElementByName(...)
	elseif (searchType == "tagname") then
		pnlMainMenu.HTML:RemoveElementByTagName(...)
	end
end

function menumods.ReAddExistingElement(identifier)
	if (not MenuMods_ElementTables["" .. identifier]) then return end
	
	MenuMods_ElementTables["" .. identifier].disabled = false
end

function menumods.ElementExists(identifier)
	if MenuMods_ElementTables["" .. identifier] then
		return true
	else
		return false
	end
end

function menumods.GetElement(identifier)
	return MenuMods_ElementTables["" .. identifier]
end

function menumods.GetElementNameByID(id)
	if (not MenuMods_IDs[id]) then return end
	
	return ("" .. MenuMods_IDs[id])
end

function menumods.GetActiveElementTable()
	local currTable = {}
	
	for k, v in pairs(MenuMods_Elements) do
		if MenuMods_ElementTables[v] then
			table.insert(currTable, (#currTable + 1), MenuMods_ElementTables[v])
		end
	end
	
	return currTable
end

function menumods.GetElementTable()
	local currTable = {}
	
	for k, v in pairs(MenuMods_ElementTables) do
		table.insert(currTable, (#currTable + 1), v)
	end
	
	return currTable
end

function menumods.RunJavaScript(str)
	if (not pnlMainMenu) then return end
	if (not pnlMainMenu.HTML) then return end
	
	pnlMainMenu.HTML:Call(str)
end

if (not pnlMainMenu) then return end

local function MenuMods_Init(self)
	self.HTML.IsRefreshing = true
	
	function self.HTML:CreateElement(identifier, currURL, urls, tag, class, parentClass, searchType, parentNum, onClick, content, ...)
		local proceed = false
		
		if urls then
			if istable(urls) then
				for k, v in pairs(urls) do
					if (currURL == v) then
						proceed = true
						break
					end
				end
			elseif isstring(urls) then
				proceed = (currURL == urls)
			end
		else
			proceed = true
		end
		
		if proceed then
			local attributes = {...}
			local exec
			
			if (searchType == nil) then
				exec = "var elements = document.getElementsByClassName(" .. menumods.string.LevelPush(parentClass, 1) .. ");\n"
			elseif (searchType == "classname") then
				exec = "var elements = document.getElementsByClassName(" .. menumods.string.LevelPush(parentClass, 1) .. ");\n"
			elseif (searchType == "id") then
				exec = "var elements = [document.getElementById(" .. menumods.string.LevelPush(parentClass, 1) .. ")];\n"
			elseif (searchType == "menumodsid") then
				exec = "var elements = [document.getElementById(" .. menumods.string.LevelPush(("menumods_" .. parentClass), 1) .. ")];\n"
			elseif (searchType == "name") then
				exec = "var elements = document.getElementsByName(" .. menumods.string.LevelPush(parentClass, 1) .. ");\n"
			elseif (searchType == "tagname") then
				exec = "var elements = document.getElementsByTagName(" .. menumods.string.LevelPush(parentClass, 1) .. ");\n"
			else
				exec = "var elements = document.getElementsByClassName(" .. menumods.string.LevelPush(parentClass, 1) .. ");\n"
			end
			
			exec = exec .. "if (elements.length >= " .. parentNum .. ") {\nvar element = elements[" .. (parentNum - 1) .. "];\nif ((element != undefined) && (element != null)) {\nvar object = document.createElement(\"" .. tag .. "\");\nelement.appendChild(object);\n"
			
			local ID = menumods.FindID(identifier)
			
			if MenuMods_ElementTables[identifier] then
				MenuMods_ElementTables[identifier].id = ID
			end
			
			exec = exec .. "object.setAttribute(\"id\", \"menumods_" .. ID .. "\");\n"
			
			exec = exec .. "object.setAttribute(\"class\", " .. menumods.string.LevelPush(class, 1) .. ");\n"
			
			for k, v in pairs(attributes) do
				if isnumber(k) then
					if (isstring(v[1]) and isstring(v[2])) then
						if (v[1] != "id") and (v[1] != "class") then
							exec = exec .. "object.setAttribute(" .. menumods.string.LevelPush(v[1], 1) .. ", " .. menumods.string.LevelPush(v[2], 1) .. ");\n"
						end
					end
				end
			end
			
			if onClick then
				exec = exec .. "object.addEventListener(\"click\", function(){\n" .. onClick .. ";\n});\n"
			end
			
			exec = exec .. "object.innerHTML = " .. menumods.string.LevelPush(content, 1) .. ";\n} else {\nlua.Run(\"pnlMainMenu.HTML.MenuModsElements[\\\"" .. menumods.string.LevelPush(identifier, 2, true) .. "\\\"] = nil\");\n};\n} else {\nlua.Run(\"pnlMainMenu.HTML.MenuModsElements[\\\"" .. menumods.string.LevelPush(identifier, 2, true) .. "\\\"] = nil\");\n}\n"
			
			self:Call(exec)
			
			if (GetConVarNumber("menumods_enableLogging") != 0) then
				menumods.CreateLog(exec, ".txt")
			end
			
			if (GetConVarNumber("menuMods_debugMode") != 0) then
				print("Menu Mods: Created element of class " .. menumods.string.LevelPush(class, 1) .. " parented to element of class " .. menumods.string.LevelPush(parentClass, 1) .. ".")
			end
			
			menumods.hook.Run("ElementCreated", currURL, urls, tag, class, parentClass, parentNum, content, ...)
			
			return ID
		end
	end
	
	function self.HTML:ModifyElement(currURL, urls, class, searchType, num, onClick, content, ...)
		local proceed = false
		
		if urls then
			if istable(urls) then
				for k, v in pairs(urls) do
					if (currURL == v) then
						proceed = true
						break
					end
				end
			elseif isstring(urls) then
				proceed = (currURL == urls)
			end
		else
			proceed = true
		end
		
		if proceed then
			local attributes = {...}
			local exec
			
			if (searchType == nil) then
				exec = "var elements = document.getElementsByClassName(" .. menumods.string.LevelPush(class, 1) .. ");\n"
			elseif (searchType == "classname") then
				exec = "var elements = document.getElementsByClassName(" .. menumods.string.LevelPush(class, 1) .. ");\n"
			elseif (searchType == "id") then
				exec = "var elements = [document.getElementById(" .. menumods.string.LevelPush(class, 1) .. ")];\n"
			elseif (searchType == "menumodsid") then
				exec = "var elements = [document.getElementById(" .. menumods.string.LevelPush(("menumods_" .. class), 1) .. ")];\n"
			elseif (searchType == "name") then
				exec = "var elements = document.getElementsByName(" .. menumods.string.LevelPush(class, 1) .. ");\n"
			elseif (searchType == "tagname") then
				exec = "var elements = document.getElementsByTagName(" .. menumods.string.LevelPush(class, 1) .. ");\n"
			else
				exec = "var elements = document.getElementsByClassName(" .. menumods.string.LevelPush(class, 1) .. ");\n"
			end
			
			exec = exec .. "if (objects.length >= " .. num .. ") {\nvar object = objects[" .. (num - 1) .. "];\nif ((object != undefined) && (object != null)) {\n"
			
			for k, v in pairs(attributes) do
				if isnumber(k) then
					if (isstring(v[1]) and isstring(v[2])) then
						if (v[1] != "id") and (v[1] != "class") then
							exec = exec .. "object.setAttribute(" .. menumods.string.LevelPush(v[1], 1) .. ", " .. menumods.string.LevelPush(v[2], 1) .. ");\n"
						end
					end
				end
			end
			
			if onClick then
				exec = exec .. "object.addEventListener(\"click\", function(){\n" .. onClick .. ";\n});\n"
			end
			
			if content then
				exec = exec .. "object.innerHTML = " .. menumods.string.LevelPush(content, 1) .. ";\n"
			end
			
			exec = exec .. "};\n}\n"
			
			self:Call(exec)
			
			if (GetConVarNumber("menumods_enableLogging") != 0) then
				menumods.CreateLog(exec, ".txt")
			end
			
			if (GetConVarNumber("menuMods_debugMode") != 0) then
				print("Menu Mods: Modified element of class " .. menumods.string.LevelPush(class, 1) .. ".")
			end
			
			menumods.hook.Run("ElementModified", currURL, urls, class, num, content, ...)
		end
	end
	
	function self.HTML:RemoveElement(id)
		local exec = "var object = document.getElementById(\"menumods_" .. id .. "\");\nif (object != null) {\nif (object.parentNode != undefined) {\nobject.parentNode.removeChild(object);\n};\n};\n"
		
		self:Call(exec)
		
		if (GetConVarNumber("menumods_enableLogging") != 0) then
			menumods.CreateLog(exec, ".txt")
		end
		
		menumods.hook.Run("ElementRemoved", "menumods_id", id)
		
		menumods.RemoveID(id)
		
		if (GetConVarNumber("menuMods_debugMode") != 0) then
			print("Menu Mods: Removed element of Menu Mods ID " .. menumods.string.LevelPush(id, 1) .. ".")
		end
	end
	
	function self.HTML:RemoveElementByID(id)
		local exec = "var object = document.getElementById(" .. menumods.string.LevelPush(id, 1) .. ");\nif (object != null) {\nif ((object.parentNode != undefined) && (object.parentNode != null) && (object.id.indexOf(\"menumods_\") != 0)) {\nobject.parentNode.removeChild(object);\n};\n};\n"
		
		self:Call(exec)
		
		if (GetConVarNumber("menumods_enableLogging") != 0) then
			menumods.CreateLog(exec, ".txt")
		end
		
		menumods.hook.Run("ElementRemoved", "id", id)
		
		if (GetConVarNumber("menuMods_debugMode") != 0) then
			print("Menu Mods: Removed element of ID " .. menumods.string.LevelPush(id, 1) .. ".")
		end
	end
	
	function self.HTML:RemoveElementByClassName(className, num)
		local exec = "var objects = document.getElementsByClassName(" .. menumods.string.LevelPush(className, 1) .. ");\nvar object = objects[" .. (num - 1) .. "];\nif (object != undefined) {\nif ((object.parentNode != undefined) && (object.parentNode != null) && (object.id.indexOf(\"menumods_\") != 0)) {\nobject.parentNode.removeChild(object);\n};\n};\n"
		
		self:Call(exec)
		
		if (GetConVarNumber("menumods_enableLogging") != 0) then
			menumods.CreateLog(exec, ".txt")
		end
		
		menumods.hook.Run("ElementRemoved", "classname", className, num)
		
		if (GetConVarNumber("menuMods_debugMode") != 0) then
			print("Menu Mods: Removed element of class name " .. menumods.string.LevelPush(className, 1) .. ", occurrence " .. num .. ".")
		end
	end
	
	function self.HTML:RemoveElementByName(name, num)
		local exec = "var objects = document.getElementsByName(" .. menumods.string.LevelPush(name, 1) .. ");\nvar object = objects[" .. (num - 1) .. "];\nif (object != undefined) {\nif ((object.parentNode != undefined) && (object.parentNode != null) && (object.id.indexOf(\"menumods_\") != 0)) {\nobject.parentNode.removeChild(object);\n};\n};\n"
		
		self:Call(exec)
		
		if (GetConVarNumber("menumods_enableLogging") != 0) then
			menumods.CreateLog(exec, ".txt")
		end
		
		menumods.hook.Run("ElementRemoved", "name", className, num)
		
		if (GetConVarNumber("menuMods_debugMode") != 0) then
			print("Menu Mods: Removed element of name " .. menumods.string.LevelPush(name, 1) .. ", occurrence " .. num .. ".")
		end
	end
	
	function self.HTML:RemoveElementByTagName(tagName, num)
		local exec = "var objects = document.getElementsByTagName(" .. menumods.string.LevelPush(tagName, 1) .. ");\nvar object = objects[" .. (num - 1) .. "];\nif (object != undefined) {\nif ((object.parentNode != undefined) && (object.parentNode != null) && (object.id.indexOf(\"menumods_\") != 0)) {\nobject.parentNode.removeChild(object);\n};\n};\n"
		
		self:Call(exec)
		
		if (GetConVarNumber("menumods_enableLogging") != 0) then
			menumods.CreateLog(exec, ".txt")
		end
		
		menumods.hook.Run("ElementRemoved", "tagname", className, num)
		
		if (GetConVarNumber("menuMods_debugMode") != 0) then
			print("Menu Mods: Removed element of class name " .. menumods.string.LevelPush(tagName, 1) .. ", occurrence " .. num .. ".")
		end
	end
	
	function self.HTML:OnDocumentReady(url)
		self.IsRefreshing = true
	end
	
	function self:UpdateHTML()
		if self.HTML then
			if (not MenuMods_UpdatingURL) then
				menumods.hook.Run("PageThink")
				
				MenuMods_UpdatingURL = true
				
				self.HTML:Call("lua.Run(\"pnlMainMenu.HTML.MenuMods_URL = \\\"\" + document.URL + \"\\\"; MenuMods_UpdatingURL = false\")")
			end
			
			if (not self.HTML.MenuModsElements) then
				self.HTML.MenuModsElements = {}
			end
			
			if self.HTML.MenuMods_URL then
				if ((self.HTML.MenuMods_URL != self.HTML.MenuMods_PrevURL) or self.HTML.IsRefreshing) then
					menumods.hook.Run("PrePageChange", self.HTML.MenuMods_PrevURL, self.HTML.MenuMods_URL)
					
					MenuMods_IDs = {}
				end
				
				local j = 1
				local tableLength = #MenuMods_Elements
				
				for i = 1, tableLength do
					local k = MenuMods_Elements[j]
					local v = MenuMods_ElementTables[k]
					
					if v then
						if (not v.disabled) then
							local show = true
							
							if (v.show != nil) then
								if isfunction(v.show) then
									if (not v.show()) then
										show = false
									end
								elseif (not v.show) then
									show = false
								end
							end
							
							if show then
								if ((not self.HTML.MenuModsElements[k]) or (self.HTML.MenuMods_URL != self.HTML.MenuMods_PrevURL) or self.HTML.IsRefreshing) then
									local function handleError( err )
										print("[ERROR] Menu Mods: Identifier \"" .. k .. "\": " .. err)
									end
									
									local exec
									
									if (not v.modifyExisting) then
										exec = function()
											self.HTML:CreateElement(k, self.HTML.MenuMods_URL, v.urls, v.tag, v.class, v.parentClass, v.searchType, v.parentNum, v.onClick, v.content, unpack(v.attributes))
										end
									else
										exec = function()
											self.HTML:ModifyElement(self.HTML.MenuMods_URL, v.urls, v.class, v.searchType, v.num, v.onClick, v.content, unpack(v.attributes))
										end
									end
									
									xpcall(exec, handleError)
									
									v = MenuMods_ElementTables[k]
									
									self.HTML.MenuModsElements[k] = true
								end
							elseif (v.id and (not v.modifyExisting)) then
								self.HTML:RemoveElement(v.id)
								
								self.HTML.MenuModsElements[k] = nil
							end
						elseif (v.id and (not v.modifyExisting)) then
							self.HTML:RemoveElement(v.id)
							
							self.HTML.MenuModsElements[k] = nil
						end
						
						j = j + 1
					else
						table.remove(MenuMods_Elements, j)
					end
				end
				
				self.HTML.IsRefreshing = false
				
				if ((self.HTML.MenuMods_URL != self.HTML.MenuMods_PrevURL) or self.HTML.IsRefreshing) then
					menumods.hook.Run("PostPageChange", self.HTML.MenuMods_PrevURL, self.HTML.MenuMods_URL)
				end
				
				self.HTML.MenuMods_PrevURL = self.HTML.MenuMods_URL
			end
		end
	end
	
	if self.HTML then
		menumods.hook.Run("Initialize")
		
		self.MenuMods_HasInitialized = true
		
		print("Menu Mods has been initialized.")
	end
end

local PanelInit_Old = pnlMainMenu.Init
local PanelInit = PanelInit_Old

MenuMods_UpdatingURL = false

pnlMainMenu.Init = function(self)
	if PanelInit then
		PanelInit(self)
	end
	
	if (not self.MenuMods_HasInitialized) then
		MenuMods_Init(self)
	end
	
	if self.UpdateHTML then
		self:UpdateHTML()
	end
end

local PanelThink_Old = pnlMainMenu.Think
local PanelThink = PanelThink_Old

pnlMainMenu.Think = function(self)
	if PanelThink then
		PanelThink(self)
	end
	
	if (not self.MenuMods_HasInitialized) then
		MenuMods_Init(self)
	end
	
	if self.UpdateHTML then
		self:UpdateHTML()
	end
	
	menumods.hook.Run("Think")
end
