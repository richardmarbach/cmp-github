local Job = require("plenary.job")

local source = {}

source.new = function()
	local self = setmetatable({}, { __index = source })

	self.cache = {
		fetched = false,
		items = {},
	}
	return self
end

---Return this source is available in current context or not. (Optional)
---@return boolean
function source:is_available()
	return vim.bo.filetype == "gitcommit"
end

---Return the debug name of this source. (Optional)
---@return string
function source:get_debug_name()
	return "github"
end

---Return keyword pattern for triggering completion. (Optional)
---If this is ommited, nvim-cmp will use default keyword pattern. See |cmp-config.completion.keyword_pattern|
---@return string
function source:get_keyword_pattern()
	return "?{Issue: }[?]"
end

---Invoke completion. (Required)
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
	if self.cache.fetched then
		callback(self.cache.items)
	else
		Job
			:new({
				command = "gh",
				args = {
					"issue",
					"list",
					"-a",
					"@me",
					"--json",
					"number,title,body,url",
				},
				on_exit = function(j, return_value)
					local issues = vim.json.decode(j:result()[1])

					local items = {}
					for _, issue in ipairs(issues) do
						local description = string.sub(issue.body, 0, 500)
						description = string.gsub(description, "\r", "")
						if string.len(issue.body) > 500 then
							description = description .. "..."
						end

						local detail = string.format("[#%d] %s", issue.number, issue.title)

						table.insert(items, {
							label = detail,
							detail = detail,
							documentation = { kind = "markdown", value = description },
							insertText = issue.url,
						})
					end
					self.cache.fetched = true
					self.cache.items = items

					callback(items)
				end,
			})
			:start()
	end
end

return source.new()
