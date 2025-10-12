-- Utility functions and paths for Zettelkasten + Zotero integration

local M = {}

------------------------------------------------------------
-- 📁 Paths & templates
------------------------------------------------------------
M.paths = {
  home          = vim.fn.expand('~/Dokumente/Schreiben'),
  zettelkasten  = vim.fn.expand('~/Dokumente/Schreiben/Zettelkasten'),
  exzerpte      = vim.fn.expand('~/Dokumente/Schreiben/Exzerpte'),
  templates     = vim.fn.expand('~/.config/nvim/templates'),
}

M.paths.zettel_template  = M.paths.templates .. '/zettel_template.md'
M.paths.exzerpt_template = M.paths.templates .. '/exzerpt_template.md'
M.paths.bib              = M.paths.home .. '/Bibliothek.bib'

------------------------------------------------------------
-- ⚙️ Setup
------------------------------------------------------------
function M.setup_telekasten()
  local ok, telekasten = pcall(require, "telekasten")
  if not ok then return end

  telekasten.setup({
    home = M.paths.home,
    bib_path = M.paths.bib,
    date_format = "%Y%m%d%H%M",
    template_new_note = M.paths.zettel_template,
    template_new_excerpt = M.paths.exzerpt_template,
  })
end

function M.setup_zotero()
  local ok, telescope = pcall(require, "telescope")
  if not ok then return end
  pcall(function() telescope.load_extension("zotero") end)
end

------------------------------------------------------------
-- 🧠 Zettelkasten
------------------------------------------------------------
function M.create_new_zettel_with_slug()
  local title = vim.fn.input("Enter title for your new Zettel: ")
  if title == "" then return end

  local date_prefix = os.date("%Y%m%d%H%M")
  local date_str = os.date("%Y-%m-%d")
  local slug = title:gsub("[^%w]+", "-")
  local filename = string.format("%s-%s.md", date_prefix, slug)
  local filepath = M.paths.zettelkasten .. "/" .. filename

  local ok, tmpl = pcall(vim.fn.readfile, M.paths.zettel_template)
  local content = ok and table.concat(tmpl, "\n") or ("# " .. title .. "\n\n" .. date_str .. "\n\n")

  content = content:gsub("{{title}}", title):gsub("{{date}}", date_str)

  vim.fn.mkdir(M.paths.zettelkasten, "p")
  vim.fn.writefile(vim.split(content, "\n"), filepath)
  vim.cmd.edit(filepath)
end

------------------------------------------------------------
-- 📚 Zotero
------------------------------------------------------------
function M.open_zotero_insert_cite()
  local ok, telescope = pcall(require, "telescope")
  if not ok or not telescope.extensions.zotero then
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
        vim.api.nvim_put({ "@" .. entry.value.citekey }, "c", false, true)
      end

      map("i", "<CR>", insert_citekey)
      map("n", "<CR>", insert_citekey)
      return true
    end,
  })
end

function M.open_zotero_create_excerpt()
  local ok, telescope = pcall(require, "telescope")
  if not ok or not telescope.extensions.zotero then
    vim.notify("telescope-zotero not available", vim.log.levels.WARN)
    return
  end

  telescope.extensions.zotero.zotero({
    bib = M.paths.bib,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function create_excerpt()
        local entry = action_state.get_selected_entry()
        if not entry or not entry.value or not entry.value.citekey then
          vim.notify("No valid entry selected!", vim.log.levels.WARN)
          return
        end
        actions.close(prompt_bufnr)

        local citekey = entry.value.citekey
        local title = entry.value.title or ""
        local authors = entry.value.author or ""
        local year = entry.value.year or ""
        local subtitle = entry.value.subtitle or ""
        local filepath = M.paths.exzerpte .. "/" .. citekey .. ".md"

        if vim.loop.fs_stat(filepath) then
          vim.notify("Excerpt exists — opening file.", vim.log.levels.INFO)
          vim.cmd.edit(filepath)
          return
        end

        local ok_t, tmpl = pcall(vim.fn.readfile, M.paths.exzerpt_template)
        local content = ok_t and table.concat(tmpl, "\n")
          or ("# " .. title .. "\n\nAuthor: " .. authors .. "\n\nCiteKey: " .. citekey .. "\n")

        local date = os.date("%Y-%m-%d")
        content = content
          :gsub("{{author}}", authors)
          :gsub("{{title}}", title)
          :gsub("{{subtitle}}", subtitle)
          :gsub("{{year}}", year)
          :gsub("{{citekey}}", citekey)
          :gsub("{{date}}", date)

        vim.fn.mkdir(M.paths.exzerpte, "p")
        vim.fn.writefile(vim.split(content, "\n"), filepath)
        vim.cmd.edit(filepath)
      end

      map("i", "<CR>", create_excerpt)
      map("n", "<CR>", create_excerpt)
      return true
    end,
  })
end

------------------------------------------------------------
return M
