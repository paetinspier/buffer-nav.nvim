local M = {}

local function get_buffers()
	local buffers = {}

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local buffer_name = vim.api.nvim_buf_get_name(buf)
			local title = buffer_name
			local parts = {}
			for segment in string.gmatch(buffer_name, "[^/]+") do
				parts[#parts + 1] = segment
			end
			local n = #parts
			if n >= 2 then
				local second_last = parts[n - 1]
				local last = parts[n]

				-- 3. append them however you like
				title = second_last .. "/" .. last
			end
			if buffer_name ~= "" then
				table.insert(
					buffers,
					{ id = buf, title = title, name = buffer_name ~= "" and buffer_name or "[No Name]" }
				)
			end
		end
	end
	return buffers
end

local floating_win = nil
local floating_buf = nil
local main_win = nil

local function create_window()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.4)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
		title = "   Buffer Nav   ",
		title_pos = "left",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	floating_win = win
	floating_buf = buf

	return buf, win
end

function M.OpenNav()
	local buffers = get_buffers()
	local buf, win = create_window()

	main_win = vim.api.nvim_get_current_win()

	local lines = {}
	for i, buffer in ipairs(buffers) do
		-- table.insert(lines, string.format("%d: %s", buffer.id, buffer.name))
		table.insert(lines, string.format("%d: %s", buffer.id, buffer.title))
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Make buffer modifiable and remove default keymaps
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")

	-- Set keymaps for the buffer
	vim.keymap.set("n", "<CR>", function()
		M.open_selected_buffer()
	end, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set("n", "x", function()
		M.delete_selected_buffer()
	end, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set("n", "q", function()
		M.close_window()
	end, { buffer = buf, noremap = true, silent = true }) -- Add quit shortcut
end

function M.open_selected_buffer()
	if not floating_buf then
		return
	end
	local cursor_pos = vim.api.nvim_win_get_cursor(floating_win) -- Get cursor row
	local line = vim.api.nvim_buf_get_lines(floating_buf, cursor_pos[1] - 1, cursor_pos[1], false)[1]
	local buf_id = tonumber(line:match("^(%d+):"))
	if buf_id then
		M.close_window()
		if main_win and vim.api.nvim_win_is_valid(main_win) then
			vim.api.nvim_set_current_win(main_win)
		end
		vim.api.nvim_set_current_buf(buf_id)
	end
end

function M.delete_selected_buffer()
	if not floating_buf then
		return
	end
	local cursor_pos = vim.api.nvim_win_get_cursor(floating_win)
	local line = vim.api.nvim_buf_get_lines(floating_buf, cursor_pos[1] - 1, cursor_pos[1], false)[1]
	local buf_id = tonumber(line:match("^(%d+):"))
	if buf_id then
		vim.api.nvim_buf_delete(buf_id, { force = true })
		M.close_window()
		M.OpenNav()
	end
end

function M.close_window()
	if floating_win and vim.api.nvim_win_is_valid(floating_win) then
		vim.api.nvim_win_close(floating_win, true)
		floating_win = nil
		floating_buf = nil
	end
end

function M.refresh_nav_window()
	if not floating_win then
		return
	end

	local buffers = get_buffers()
	local lines = {}
	for _, buffer in ipairs(buffers) do
		table.insert(lines, string.format("%d: %s", buffer.id, buffer.name))
	end

	vim.api.nvim_buf_set_lines(floating_buf, 0, -1, false, lines)
end

return M
