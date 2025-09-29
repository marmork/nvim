-- lua/plugins/zettelkasten.lua
return {
  -- Nvim-telekasten for Zettelkasten management
  {
    'git@github.com:nvim-telekasten/telekasten.nvim.git',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      -- Local variables for home and template paths to avoid timing issues
      local home_path = '/home/marcel/Dokumente/Schreiben'
      local zettelkasten_path = home_path .. '/Zettelkasten'
      local excerpts_path = home_path .. '/Exzerpte'
      local bib_path = home_path .. '/Bibliothek.bib'
      local zettel_template_path = '/home/marcel/.config/nvim/templates/zettel_template.md'
      local excerpt_template_path = '/home/marcel/.config/nvim/templates/exzerpt_template.md'

      require('telekasten').setup({
        home = home_path,
        bib_path = bib_path,
        date_format = '%Y%m%d%H%M',
        template_new_note = zettel_template_path,
        template_new_excerpt = excerpt_template_path,
      })

      -- Custom function to create a new Zettel with a slug and rendered template
      local function create_new_zettel_with_slug()
        -- Prompt the user for a title
        local title = vim.fn.input('Enter title for your new Zettel: ')
        if title == '' then return end

        local date_filename = os.date('%Y%m%d%H%M')
        local date_template = os.date('%Y-%m-%d')
        local slug = string.gsub(title, '[^%a%d]+', '-')
        local filename = string.format("%s-%s.md", date_filename, slug)
        local filepath = zettelkasten_path .. '/' .. filename

        -- Get the content from the template file
        local template_content = vim.fn.readfile(zettel_template_path)

        -- Join the lines back into a single string for replacement
        local content = table.concat(template_content, '\n')

        -- Manually replace the placeholders
        content = string.gsub(content, '{{title}}', title)
        content = string.gsub(content, '{{date}}', date_template)

        -- Write the modified content to the new file
        vim.fn.writefile(vim.split(content, '\n'), filepath)

        -- Open the new file buffer
        vim.cmd('edit ' .. filepath)
      end

      -- The standard Telekasten keys are defined here, with custom functions
      vim.keymap.set('n', '<leader>zn', create_new_zettel_with_slug, { desc = "New Zettel with slug" })
      vim.keymap.set('n', '<leader>zb', '<cmd>Telekasten show_backlinks<CR>', { desc = "Show Backlinks" })
      vim.keymap.set('n', '<leader>zf', '<cmd>Telekasten find_notes<CR>', { desc = "Find Zettel" })
      vim.keymap.set('n', '<leader>zl', '<cmd>Telekasten insert_link<CR>', { desc = "Insert Link" })
      vim.keymap.set('n', '<leader>zo', '<cmd>Telekasten follow_link<CR>', { desc = "Open Link under cursor" })
      vim.keymap.set('n', '<leader>zs', '<cmd>Telekasten show_tags<CR>', { desc = "Show Tags" })
      vim.keymap.set('n', '<leader>zt', '<cmd>Telekasten today<CR>', { desc = "Daily Zettel" })
    end,
  },

  --- Telescope extension including Zotero picker and Excerpt creation
  {
    'jmbuhr/telescope-zotero.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'kkharji/sqlite.lua' },
    config = function()
      -- Local variables for home and template paths to avoid timing issues
      local home_path = '/home/marcel/Dokumente/Schreiben'
      local excerpts_path = home_path .. '/Exzerpte'
      local bib_path = home_path .. '/Bibliothek.bib'
      local excerpt_template_path = '/home/marcel/.config/nvim/templates/exzerpt_template.md'

      -- Load telescope extension
      local ok_ext, tz = pcall(require, 'telescope')
      if ok_ext then
        pcall(function() tz.load_extension('zotero') end)
      end

      -- Keymap to open the Zotero picker for general citation
      vim.keymap.set('n', '<leader>zc', function()
        require('telescope').extensions.zotero.zotero({
          bib = bib_path,
          attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            local function insert_citekey(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              if not entry or not entry.value or not entry.value.citekey then
                vim.notify("Kein gültiger CiteKey gefunden!", vim.log.levels.WARN)
                return
              end
              actions.close(prompt_bufnr)
              local cite = entry.value.citekey
              local inserted = "@" .. cite
              
              -- Insert the text at the current cursor position.
              -- 'c' for character-wise insertion, false for not linewise, true for after cursor
              vim.api.nvim_put({inserted}, 'c', false, true)
            end

            map('i', '<CR>', insert_citekey)
            map('n', '<CR>', insert_citekey)
            return true
          end,
        })
      end, { desc = "Zotero: insert cite key only" })

      -- Keymap to create a new Excerpt from Zotero
      vim.keymap.set('n', '<leader>ze', function()
        require('telescope').extensions.zotero.zotero({
          bib = bib_path,
          attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')
            
            -- Function to create the Excerpt file from Zotero entry
            local function create_excerpt_from_zotero(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              if not entry or not entry.value or not entry.value.citekey then
                vim.notify("No valid entry selected from Zotero!", vim.log.levels.WARN)
                return
              end

              actions.close(prompt_bufnr)

              -- Get Zotero metadata
              local citekey = entry.value.citekey
              local zotero_title = entry.value.title or ""
              local authors_raw = entry.value.author or {}
              
              -- === NEUE, SICHERERE LOGIK ===
              -- 1. Dateinamen nur aus dem Citekey erstellen, um Duplikate zu verhindern
              local filename = string.format("%s.md", citekey)
              local filepath = excerpts_path .. '/' .. filename

              -- 2. Überprüfen, ob Datei bereits existiert
              local stat = vim.loop.fs_stat(filepath)
              if stat ~= nil then
                  vim.notify("Exzerpt existiert bereits, öffne die Datei.", vim.log.levels.INFO)
                  vim.cmd('edit ' .. filepath)
                  return
              end
              -- === ENDE NEUE LOGIK ===

              local authors = ""
              
              -- Check if authors_raw is a string
              if type(authors_raw) == 'string' then
                  authors = authors_raw
              -- Check if authors_raw is a non-empty table
              elseif type(authors_raw) == 'table' and #authors_raw > 0 then
                  local formatted_authors = {}
                  for _, author in ipairs(authors_raw) do
                      -- Check for 'name' (e.g., corporate) or 'given'/'family'
                      if author.name then
                          table.insert(formatted_authors, author.name)
                      else
                          table.insert(formatted_authors, (author.given or "") .. " " .. (author.family or ""))
                      end
                  end
                  authors = table.concat(formatted_authors, ", ")
              end

              -- === WORKAROUND ===
              -- If authors field is still empty after all checks, try to get it from the citekey
              if authors == "" and citekey then
                  -- Simple heuristic: get the part of the string before the first number
                  authors = string.match(citekey, "^%a+") or ""
              end
              -- === END WORKAROUND ===

              local year = entry.value.year or ""
              local subtitle = entry.value.subtitle or ""

              -- Ask for custom title, defaulting to Zotero title
              local custom_title = vim.fn.input('Enter title for excerpt (leave empty to use Zotero title): ')
              local final_title = (custom_title and custom_title ~= '') and custom_title or zotero_title
              
              -- Get template content and replace placeholders
              local template_content = vim.fn.readfile(excerpt_template_path)
              local content = table.concat(template_content, '\n')
              
              local date_template = os.date('%Y-%m-%d')

              content = string.gsub(content, '{{author}}', authors)
              content = string.gsub(content, '{{title}}', zotero_title)
              content = string.gsub(content, '{{subtitle}}', subtitle)
              content = string.gsub(content, '{{year}}', year)
              content = string.gsub(content, '{{citekey}}', citekey)
              content = string.gsub(content, '{{date}}', date_template)

              -- Write content to new file
              vim.fn.writefile(vim.split(content, '\n'), filepath)
              
              -- Open the new file buffer
              vim.cmd('edit ' .. filepath)

              -- Find the line number containing the Citation Key
              local line_nr = vim.fn.search("Citation Key: " .. citekey)
              
              if line_nr and line_nr > 0 then
                -- Find the column number where the Citation Key ends
                local line_content = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
                local _, end_col = string.find(line_content, citekey)
                if end_col then
                  -- Set the cursor behind the Citation Key
                  vim.api.nvim_win_set_cursor(0, { line_nr, end_col + 1})
                end
              end
            end

            -- Map the enter key to our new function
            map('i', '<CR>', create_excerpt_from_zotero)
            map('n', '<CR>', create_excerpt_from_zotero)

            return true
          end,
        })
      end, { desc = "Zotero: Create new Excerpt" })
    end,
  },
}
