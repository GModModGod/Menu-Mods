
local function OnRestore(save)
	if (pnlMainMenu and pnlMainMenu:IsValid() and pnlMainMenu.HTML) then
		pnlMainMenu.HTML.ShouldRefresh = true
	end
end

saverestore.AddRestoreHook("MenuMods_OnRestore", OnRestore)
