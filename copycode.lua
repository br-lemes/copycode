
require("iuplua")

gui = { }
gui.clipboard = iup.clipboard{}

gui.dialog = iup.dialog{
	title      = "Copy Code",
	font       = "Helvetica, Bold 12",
	rastersize = "300x300",
	iup.vbox{
		margin = "10x10",
		gap    = "10",
		iup.text{
			name      = "entrada",
			expand    = "YES",
			multiline = "YES",
		},
		iup.hbox{
			iup.button{
				name   = "limpar",
				title  = "&Limpar",
				expand = "HORIZONTAL",
			},
			iup.button{
				name   = "copiar",
				title  = "&Copiar",
				expand = "HORIZONTAL",
			},
		},
	},
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

--[[
    javascript:
	var v = " " + document.getElementById("objetos").value + " ";
	var s = "";
	var code;
	/* Código no formato CSV do SRO */
	var r = /\b[A-Za-z]{2} \d{8}\-\d [A-Za-z]{2}\b/g;
	while (code = r.exec(v))
		s = s + code[0].replace(/ /g, "").replace("-", "") + ";";
	/* Código formato normal */
	var r = /\b[A-Za-z]{2}\d{9}[A-Za-z]{2}\b/g;
	while (code = r.exec(v))
		s = s + code[0] + ";";
	/* Código de telegrama faltando o BR final */
	var r = /\b[Mm][A-Za-z]\d{9}\b/g;
	while (code = r.exec(v))
		s = s + code[0] + "BR;";
	document.getElementById("objetos").value = s;
	document.getElementById("frmPesquisa").submit();
	void(0);
]]

function gui.copiar:action()
	local v = string.format(" %s ", gui.entrada.value):gsub("%s", "  ")
	local s = ""
	-- Código no formato CSV do SRO
	for code in v:gmatch("%W(%a%a  %d%d%d%d%d%d%d%d%-%d  %a%a)%W") do
		s = string.format("%s%s\n", s, code:gsub("  ", ""):gsub("%-", ""))
	end
	-- Código formato normal
	for code in v:gmatch("%W(%a%a%d%d%d%d%d%d%d%d%d%a%a)%W") do
		s = string.format("%s%s\n", s, code)
	end
	-- Código de telegrama faltando o BR final
	for code in v:gmatch("%W(M%a%d%d%d%d%d%d%d%d%d)%W") do
		s = string.format("%s%sBR\n", s, code)
	end
	gui.entrada.value = s
	gui.clipboard.text = nil
	gui.clipboard.text = s
end

function gui.limpar:action()
	gui.entrada.value = ""
	iup.SetFocus(gui.entrada)
end

gui.dialog:show()
iup.MainLoop()
