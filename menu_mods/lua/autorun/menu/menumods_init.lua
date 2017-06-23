
if (not MenuMods_Initialized) then
	local exec = CompileString(file.Read("lua/autorun/menu/menumods_menu.lua", "GAME"), "autorun/menu/menumods_menu.lua", true)

	exec()
end

local FileTable = {}

local function Mount()
	local files, dirs = file.Find("lua/autorun/menu/*.lua", "GAME")

	for k, v in pairs(files) do
		if (not dirs[k]) then
			dirs[k] = "lua/autorun/menu"
		end
		
		local filename = (dirs[k] .. "/" .. v)
		
		if (not FileTable[filename]) then
			if file.Exists(filename, "GAME") then
				if ((filename != "lua/autorun/menu/menumods_init.lua") and (filename != "lua/autorun/menu/menumods_menu.lua")) then
					local exec = CompileString(file.Read(filename, "GAME"), string.TrimLeft(filename, "lua/"), true)
					local function handleError(err)
						print("[ERROR] " .. err)
					end
					
					xpcall(exec, handleError)
					
					FileTable[filename] = true
				end
			end
		end
	end
end

Mount()

hook.Add("GameContentChanged", "MenuMods_GameContentChanged", Mount)

MenuMods_Initialized = true
