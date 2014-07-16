
require("iuplua")

gui = { }
gui.clipboard = iup.clipboard{}

gui.dialog = iup.dialog{
	title      = "Copy Code",
	font       = "HELVETICA_BOLD_12",
	rastersize = "300x300",
	iup.vbox{
		margin = "10x10",
		gap    = "10",
		iup.text{
			name      = "entrada",
			expand    = "YES",
			multiline = "YES",
		},
		iup.button{
			name   = "copiar",
			title  = "&Copiar",
			expand = "HORIZONTAL",
		},
	}
}

function gui.iupnames(self, elem)
	if type(elem) == "userdata" then
		if elem.name ~= "" and elem.name ~= nil then
			self[elem.name] = elem
		end
	end
	local i = 1
	while elem[i] do
		self:iupnames(elem[i])
		i = i + 1
	end
end

gui:iupnames(gui.dialog)

function gui.question(message)
	local dlg = iup.messagedlg{
		title      = "Confirmar",
		value      = message,
		buttons    = "YESNO",
		dialogtype = "QUESTION"
	}
	dlg:popup()
	return dlg.buttonresponse == "1"
end

function gui.dialog:close_cb()
	if gui.question("Sair do Copy Code?") then
		self:hide()
	else
		return iup.IGNORE
	end
end

function gui.dialog:k_any(k)
	if k == iup.K_ESC then
		self:close_cb()
	elseif k == iup.K_CR or k == iup.K_C or k == iup.K_c then
		gui.copiar:action()
		return iup.IGNORE
	end
end

function gui.copiar:action()
	local v = string.format(" %s ", gui.entrada.value):gsub("%s", "  ")
	local s = ""
	for code in v:gmatch(" (%a%a%d%d%d%d%d%d%d%d%d%a%a) ") do
		s = string.format("%s%s\n", s, code)
	end
	for code in v:gmatch(" (M%a%d%d%d%d%d%d%d%d%d) ") do
		s = string.format("%s%sBR\n", s, code)
	end
	gui.entrada.value = s
	gui.clipboard.text = nil
	gui.clipboard.text = s
end

gui.dialog:show()
iup.MainLoop()
