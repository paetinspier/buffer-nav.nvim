local buffernav = require("buffer-nav.buffer_nav")

print(vim.inspect(buffernav))

---@class CmdSubcommand
---@field impl fun(args: strings[], opts: table)
---@field complete? fun(subcmd_arg_lead: string): string[] (optional)
---@type table<string, CmdSubcommand>
local subcommand_tbl = {
	OpenNav = {
		impl = function(args, opts)
			print("buff ass nav?")
			buffernav.OpenNav()
		end,
		-- this subcommand has no completions
	},
}

---@param opts table
local function my_cmd(opts)
	local fargs = opts.fargs
	local subcommand_key = fargs[1]
	-- Get the subcommand's arguments, if any
	local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
	local subcommand = subcommand_tbl[subcommand_key]
	if not subcommand then
		vim.notify("buffernav: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
		return
	end
	-- Invoke the subcommand
	subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command("buffernav", my_cmd, {
	nargs = "+",
	desc = "My awesome command with subcommand completions",
	complete = function(arg_lead, cmdline, _)
		-- Get the subcommand.
		local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*buffernav[!]*%s(%S+)%s(.*)$")
		if subcmd_key and subcmd_arg_lead and subcommand_tbl[subcmd_key] and subcommand_tbl[subcmd_key].complete then
			-- The subcommand has completions. Return them.
			return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
		end
		-- Check if cmdline is a subcommand
		if cmdline:match("^['<,'>]*buffernav[!]*%s+%w*$") then
			-- Filter subcommands that match
			local subcommand_keys = vim.tbl_keys(subcommand_tbl)
			return vim.iter(subcommand_keys)
				:filter(function(key)
					return key:find(arg_lead) ~= nil
				end)
				:totable()
		end
	end,
	bang = true, -- If you want to support ! modifiers
})

vim.keymap.set("n", "<Plug>(MyPluginAction)", function()
	print("Hello")
end, { noremap = true })
