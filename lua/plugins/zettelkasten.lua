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
        filename_template = '{{date}}-{{slug}}',
        template_new_note = '/home/marcel/.config/nvim/templates/zettel_template.md',
      })
    end,
    keys = {
      {'<leader>zb', '<cmd>Telekasten show_backlinks<CR>', desc = "Show Backlinks"},
      {'<leader>zf', '<cmd>Telekasten find_notes<CR>', desc = "Find Zettel"},
      {'<leader>zl', '<cmd>Telekasten insert_link<CR>', desc = "Insert Link"},
      {'<leader>zn', '<cmd>Telekasten new_note<CR>', desc = "New Zettel"},
      {'<leader>zo', '<cmd>Telekasten follow_link<CR>', desc = "Open Link under cursor"},
      {'<leader>zt', '<cmd>Telekasten today<CR>', desc = "Daily Zettel"},
    }
  },

  {
    'jmbuhr/telescope-zotero.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'kkharji/sqlite.lua' },
    config = function()
      -- Lade die Extension, ohne Fehler, falls sie schon geladen ist
      local ok_ext, tz = pcall(require, 'telescope')
      if ok_ext then
        pcall(function() tz.load_extension('zotero') end)
      end

      -- Keymap, um den Picker zu öffnen
      vim.keymap.set('n', '<leader>zc', function()
        require('telescope').extensions.zotero.zotero({
          bib = "/home/marcel/Dokumente/Schreiben/Bibliothek.bib",
          attach_mappings = function(prompt_bufnr, map)

            -- Eigentliche Funktion zum Einfügen
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            local function insert_citekey(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              if not entry or not entry.value or not entry.value.citekey then
                vim.notify("Kein gültiger CiteKey gefunden!", vim.log.levels.WARN)
                return
              end

              local cite = entry.value.citekey

              -- Picker schließen
              actions.close(prompt_bufnr)

              -- Einfügen an Cursor
              local row, col = unpack(vim.api.nvim_win_get_cursor(0))
              local inserted = "@" .. cite
              vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { inserted })
              vim.api.nvim_win_set_cursor(0, { row, col + #inserted })
            end

            -- Mappe Enter im Picker
            map('i', '<CR>', insert_citekey)
            map('n', '<CR>', insert_citekey)

            return true
          end,
        })
      end, { desc = "Zotero: insert cite key only" })
    end,
  },

  -- Nvim-tree for file explorer
  {
    'nvim-tree/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    config = function()
      require('nvim-tree').setup()
    end
  },

  -- Gitsigns for git integration
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  },

  -- Neogit for Git
  {
    'git@github.com:NeogitOrg/neogit.git',
    cmd = 'Neogit',
    dependencies = 'plenary.nvim',
    config = true
  },
}

