-- ~/.config/nvim/lua/utils/zettelkasten.lua
-- helper functions and paths for zettelkasten + zotero integration

local M = {}

-- preserve your original paths
M.paths = {}
M.paths.home      = vim.fn.expand('~/Dokumente/Schreiben')         -- preserves your path
M.paths.zettelkasten = M.paths.home .. '/Zettelkasten'
M.paths.exzerpte     = M.paths.home .. '/Exzerpte'
M.paths.templates    = vim.fn.expand('~/.config/nvim/templates')
M.paths.zettel_template   = M.paths.templates .. '/zettel_template.md'
M.paths.exzerpt_template  = M.paths.templates .. '/exzerpt_template.md'
M.paths.bib = M.paths.home .. '/Bibliothek.bib'

-- Setup telekasten plugin (keeps your original behaviour: home = writing folder)
function M.setup_telekasten()
  local ok, t = pcall(require, "telekasten")
  if not ok then return end

  t.setup({
    home = M.paths.home,
    bib_path = M.paths.bib,
    date_format = "%Y%m%d%H%M",
    template_new_note = M.paths.zettel_template,
    template_new_excerpt = M.paths.exzerpt_template,
  })
end

-- Load telescope zotero extension (if available)
function M.setup_zotero()
  local ok, telescope = pcall(require, "telescope")
  if not ok then return end
  pcall(function() telescope.load_extension("zotero") end)
end

-- Create a new zettel from template, slugified filename
function M.create_new_zettel_with_slug()
  local title = vim.fn.input("Enter title for your new Zettel: ")
  if title == "" then return end

  local date_filename = os.date("%Y%m%d%H%M")
  local date_template = os.date("%Y-%m-%d")
  local slug = string.gsub(title, "[^%a%d]+", "-")
  local filename = string.format("%s-%s.md", date_filename, slug)
  local filepath = M.paths.zettelkasten .. "/" .. filename

  local ok, tmpl = pcall(vim.fn.readfile, M.paths.zettel_template)
  local content = ""
  if ok and tmpl then
    content = table.concat(tmpl, "\n")
  else
    content = "# " .. title .. "\n\n" .. date_template .. "\n\n"
  end

  content = string.gsub(content, "{{title}}", title)
  content = string.gsub(content, "{{date}}", date_template)

  vim.fn.mkdir(M.paths.zettelkasten, "p")
  vim.fn.writefile(vim.split(content, "\n"), filepath)
  vim.cmd("edit " .. filepath)
end

-- Open Zotero picker and insert cite key at cursor
function M.open_zotero_insert_cite()
  local ok, telescope = pcall(require, "telescope")
  if not ok or not telescope.extensions or not telescope.extensions.zotero then
    vim.notify("telescope-zotero not available", vim.log.levels.WARN)
    return
  end

  telescope.extensions.zotero.zotero({
    bib = M.paths.bib,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function insert_citekey()
        local entry = action_state.get_selected_entry()
        if not entry or not entry.value or not entry.value.citekey then
          vim.notify("No valid CiteKey found", vim.log.levels.WARN)
          return
        end
        actions.close(prompt_bufnr)
        local cite = entry.value.citekey
        vim.api.nvim_put({ "@" .. cite }, "c", false, true)
      end

      map("i", "<CR>", insert_citekey)
      map("n", "<CR>", insert_citekey)
      return true
    end,
  })
end

-- Open Zotero picker and create an excerpt file from selected entry
function M.open_zotero_create_excerpt()
  local ok, telescope = pcall(require, "telescope")
  if not ok or not telescope.extensions or not telescope.extensions.zotero then
    vim.notify("telescope-zotero not available", vim.log.levels.WARN)
    return
  end

  telescope.extensions.zotero.zotero({
    bib = M.paths.bib,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function create_excerpt_from_zotero()
        local entry = action_state.get_selected_entry()
        if not entry or not entry.value or not entry.value.citekey then
          vim.notify("No valid entry selected from Zotero!", vim.log.levels.WARN)
          return
        end
        actions.close(prompt_bufnr)

        local citekey = entry.value.citekey
        local zotero_title = entry.value.title or ""
        local authors_raw = entry.value.author or {}
        local year = entry.value.year or ""
        local subtitle = entry.value.subtitle or ""

        local filename = string.format("%s.md", citekey)
        local filepath = M.paths.exzerpte .. "/" .. filename

        -- if file exists, open and bail
        if vim.loop.fs_stat(filepath) then
          vim.notify("Excerpt exists, opening file.", vim.log.levels.INFO)
          vim.cmd("edit " .. filepath)
          return
        end

        -- build authors string
        local authors = ""
        if type(authors_raw) == "string" then
          authors = authors_raw
        elseif type(authors_raw) == "table" and #authors_raw > 0 then
          local formatted = {}
          for _, a in ipairs(authors_raw) do
            if a.name then
              table.insert(formatted, a.name)
            else
              table.insert(formatted, (a.given or "") .. " " .. (a.family or ""))
            end
          end
          authors = table.concat(formatted, ", ")
        end
        if authors == "" and citekey then
          authors = string.match(citekey, "^%a+") or ""
        end

        local custom_title = vim.fn.input("Enter title for excerpt (leave empty to use Zotero title): ")
        local final_title = (custom_title and custom_title ~= "") and custom_title or zotero_title

        local ok_t, tmpl = pcall(vim.fn.readfile, M.paths.exzerpt_template)
        local content = ""
        if ok_t and tmpl then
          content = table.concat(tmpl, "\n")
        else
          content = ("# " .. final_title .. "\n\nAuthor: " .. authors .. "\n\nCiteKey: " .. citekey .. "\n")
        end

        local date_template = os.date("%Y-%m-%d")
        content = string.gsub(content, "{{author}}", authors)
        content = string.gsub(content, "{{title}}", final_title)
        content = string.gsub(content, "{{subtitle}}", subtitle)
        content = string.gsub(content, "{{year}}", year)
        content = string.gsub(content, "{{citekey}}", citekey)
        content = string.gsub(content, "{{date}}", date_template)

        vim.fn.mkdir(M.paths.exzerpte, "p")
        vim.fn.writefile(vim.split(content, "\n"), filepath)
        vim.cmd("edit " .. filepath)

        -- place cursor after citekey if present
        local line_nr = vim.fn.search("CiteKey: " .. citekey, "nw")
        if line_nr and line_nr > 0 then
          local line_content = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
          local s, e = string.find(line_content or "", citekey, 1, true)
          if e then
            vim.api.nvim_win_set_cursor(0, { line_nr, e })
          end
        end
      end

      map("i", "<CR>", create_excerpt_from_zotero)
      map("n", "<CR>", create_excerpt_from_zotero)
      return true
    end,
  })
end

return M
