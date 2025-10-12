return {
  {
    "nvim-telekasten/telekasten.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local ok, ztk = pcall(require, "utils.zettelkasten")
      if ok and ztk.setup_telekasten then
        ztk.setup_telekasten()
      end
    end,
  },
  {
    "jmbuhr/telescope-zotero.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
    config = function()
      local ok, ztk = pcall(require, "utils.zettelkasten")
      if ok and ztk.setup_zotero then
        ztk.setup_zotero()
      end
    end,
  },
}
