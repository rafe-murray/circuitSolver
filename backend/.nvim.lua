local function clangdCmd()
	local filePath = debug.getinfo(1, "S").source:sub(2)
	local is_windows = vim.uv.os_uname().sysname:find("Windows") ~= nil
	if is_windows then
		filePath = filePath:gsub("/", "\\")
	end

	-- Extract the directory portion
	local sep = is_windows and "\\" or "/"
	local pwd = filePath:match("(.*" .. sep .. ")")
	local workspaceRoot = pwd:match("(.*)" .. sep .. "backend" .. sep)
	return {
		"devcontainer",
		"exec",
		"--workspace-folder=" .. pwd,
		"clangd",
		"--path-mappings=" .. workspaceRoot .. "=/workspaces/circuitSolver," .. pwd .. "container-include=/usr/include",
	}
end

---@type vim.lsp.Config
vim.lsp.config("clangd", {
	cmd = clangdCmd(),
})
