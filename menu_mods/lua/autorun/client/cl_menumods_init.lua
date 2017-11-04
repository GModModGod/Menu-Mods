
local function Initialize()
	if (pnlMainMenu and pnlMainMenu:IsValid() and pnlMainMenu.HTML) then
		pnlMainMenu.HTML.ShouldRefresh = true
	end
end

hook.Add("MenuMods_Initialize", Initialize)
