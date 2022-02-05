local Job = require("plenary.job")

local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })

  self.cache = {
    fetched = false,
    items = {},
  }
  self.prefix_regex = [[\cissue:\?\s\?$]]
  return self
end

---@return boolean
function source:is_available()
  return vim.bo.filetype == "gitcommit"
end

---Return the debug name of this source. (Optional)
---@return string
function source:get_debug_name()
  return "github"
end

---@return string
function source:get_keyword_pattern()
  return [[#\?\(\d*\)]]
end

function source:get_trigger_characters()
  return { "#" }
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  local line = params.context.cursor_before_line
  if not vim.regex(self.prefix_regex):match_str(line) then
    callback(nil)
    return
  end

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
              sortText = string.format("%06d", issue.number),
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
