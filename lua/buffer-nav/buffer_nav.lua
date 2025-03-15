local M = {}

local function get_buffers()
	local buffers = {}

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			table.insert(buffers, { id = buf, name = name ~= "" and name or "[No Name]" })
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
	local window = create_window()

	print("Buff asss nav")
end

return M
