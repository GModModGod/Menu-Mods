
if MenuMods_Initialized then return end

local exec = CompileString(file.Read("lua/autorun/menu/menumods_menu.lua", "GAME"), "autorun/menu/menumods_menu.lua", true)

exec()

local files, dirs = file.Find("lua/autorun/menu/*.lua", "GAME")

for k, v in pairs(files) do
	if (not dirs[k]) then
		dirs[k] = "lua/autorun/menu"
	end
	
	local filename = (dirs[k] .. "/" .. v)
	
	if file.Exists(filename, "GAME") then
		if ((filename != "lua/autorun/menu/menumods_init.lua") and (filename != "lua/autorun/menu/menumods_menu.lua")) then
			local exec = CompileString(file.Read(filename, "GAME"), string.TrimLeft(filename, "lua/"), true)
			local function handleError(err)
				print("[ERROR] " .. err)
			end
			
			xpcall(exec, handleError)
		end
	end
end

MenuMods_Initialized = true
