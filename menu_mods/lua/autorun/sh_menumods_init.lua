
if SERVER then
	AddCSLuaFile()
end

include("includes/modules/luahtml.lua")

local files, dirs = file.Find("lua/htmldocs/*.lua", "GAME")

for k, v in ipairs(files) do
	local startPos, endPos = string.find(v, "%.lua$", 1, false)
	
	if (not dirs[k]) then
		dirs[k] = "lua/htmldocs"
	end
	
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
			
			include(fullPath)
			
			if (not LUA_HTML.Base) then
				LUA_HTML.Base = "base_html"
			end
			
			luahtml.Register(LUA_HTML, name)
		end
	end
end

LUA_HTML = {}

for k, v in pairs(luahtml.GetClasses()) do
	if istable(v.BaseClass) then
		for i, j in pairs(v.BaseClass) do
			if (v[i] == nil) then
				v[i] = j
			end
		end
	end
end
