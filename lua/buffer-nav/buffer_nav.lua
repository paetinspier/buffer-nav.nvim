local M = {}

local function get_buffers()
	local buffers = {}

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			if name ~= "" then
				table.insert(buffers, { id = buf, name = name ~= "" and name or "[No Name]" })
			end
		end
	end
	return buffers
end

local function create_window()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.4)
	local height = math.floor(vim.o.lines * 0.4)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	return buf, win
end

function M.OpenNav()
	local buffers = get_buffers()
	local buf, win = create_window()
	print("Buff asss nav")

	local lines = {}
	for i, buffer in ipairs(buffers) do
		table.insert(lines, string.format("%d: %s", buffer.id, buffer.name))
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
