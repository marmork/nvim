-- lua/plugins/zettelkasten.lua
return {
  -- Nvim-telekasten for Zettelkasten management
  {
    'git@github.com:nvim-telekasten/telekasten.nvim.git',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telekasten').setup({
        home = '/home/marcel/Dokumente/Schreiben/zettelkasten',
        bib_path = '/home/marcel/Dokumente/Schreiben/Bibliothek.bib',
        date_format = '%Y%m%d%H%M',
        template_new_note = '/home/marcel/.config/nvim/templates/zettel_template.md',
      })

      -- Custom function to create a new Zettel with a slug and rendered template
      local function create_new_zettel_with_slug()
        -- Prompt the user for a title
        local title = vim.fn.input('Enter title for your new Zettel: ')
        if title == '' then return end

        local date = os.date('%Y-%m-%d')
        local slug = string.gsub(title, '[^%a%d]+', '-')
        local filename = string.format("%s-%s.md", date, slug)
        local filepath = vim.fn.expand('~/Dokumente/Schreiben/zettelkasten/' .. filename)

        -- Get the content from the template file
        local template_path = '/home/marcel/.config/nvim/templates/zettel_template.md'
        local template_content = vim.fn.readfile(template_path)

        -- Join the lines back into a single string for replacement
        local content = table.concat(template_content, '\n')

        -- Manually replace the placeholders
        content = string.gsub(content, '{{title}}', title)
        content = string.gsub(content, '{{date}}', date)

        -- Write the modified content to the new file
        vim.fn.writefile(vim.split(content, '\n'), filepath)

        -- Open the new file buffer
        vim.cmd('edit ' .. filepath)
      end

      -- The standard Telekasten keys are defined here, but with a custom function for new_note
      vim.keymap.set('n', '<leader>zn', create_new_zettel_with_slug, { desc = "New Zettel with slug" })
      vim.keymap.set('n', '<leader>zb', '<cmd>Telekasten show_backlinks<CR>', { desc = "Show Backlinks" })
      vim.keymap.set('n', '<leader>zf', '<cmd>Telekasten find_notes<CR>', { desc = "Find Zettel" })
      vim.keymap.set('n', '<leader>zl', '<cmd>Telekasten insert_link<CR>', { desc = "Insert Link" })
      vim.keymap.set('n', '<leader>zo', '<cmd>Telekasten follow_link<CR>', { desc = "Open Link under cursor" })
      vim.keymap.set('n', '<leader>zt', '<cmd>Telekasten today<CR>', { desc = "Daily Zettel" })
    end,
  },

  --- Telescope extension including Zotero picker
  {
    'jmbuhr/telescope-zotero.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'kkharji/sqlite.lua' },
    config = function()
      -- Load telescope extension
      local ok_ext, tz = pcall(require, 'telescope')
      if ok_ext then
        pcall(function() tz.load_extension('zotero') end)
      end

      -- Keymap to open the Zotero picker
      vim.keymap.set('n', '<leader>zc', function()
        require('telescope').extensions.zotero.zotero({
          bib = "/home/marcel/Dokumente/Schreiben/Bibliothek.bib",
          attach_mappings = function(prompt_bufnr, map)

            -- Core function to insert the citekey
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            local function insert_citekey(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              if not entry or not entry.value or not entry.value.citekey then
                vim.notify("Kein gültiger CiteKey gefunden!", vim.log.levels.WARN)
                return
              end

              local cite = entry.value.citekey

              -- Close the picker
              actions.close(prompt_bufnr)

              -- Insert at the cursor position
              local row, col = unpack(vim.api.nvim_win_get_cursor(0))
              local inserted = "@" .. cite
              vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { inserted })
              vim.api.nvim_win_set_cursor(0, { row, col + #inserted })
            end

            -- Map the enter key in the picker
            map('i', '<CR>', insert_citekey)
            map('n', '<CR>', insert_citekey)

            return true
          end,
        })
      end, { desc = "Zotero: insert cite key only" })
    end,
  },
}