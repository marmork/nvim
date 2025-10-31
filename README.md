# 🧠 Neovim Configuration – Writing & Coding Setup

This repository contains my personal **Neovim configuration** for both **writing** and **software development**.  
It is built on **Neovim ≥ 0.10**, uses **lazy.nvim** as a plugin manager, and follows a modular structure for maintainability.

---

## ⚙️ Features

✅ Two dedicated work modes:

- **Writing Mode** (`<leader>ws`) → switches to `~/Documents/Writing`
- **Coding Mode** (`<leader>wc`) → switches to `~/repos`

✅ Key tools included:

- Modern UI (Gruvbox theme, nvim-tree, Telescope)
- Built-in LSP, linting, and formatting (via `none-ls.nvim`)
- Automatic formatting on save

---

## 🧩 Folder Structure

```
~/.config/nvim/
├── init.lua → Entry point (loads Lazy and your modules)
├── lua/
|    ├──config/
│         ├── keymaps.lua → Centralized keybindings
|         ├── settings.lua → Neovim options (tabs, numbers, etc.)
│         ├── workspaces.lua → Writing/Coding mode switching logic
|    ├──plugins/ → One file per plugin definition
|         ├── editor.lua
|         ├── git.lua
|         ├── linting.lua
|         ├── lsp.lua
|         ├── theme.lua
|         ├── zettelkasten.lua
│    └── utils/ → (optional) custom helpers or shared functions
└── lazy-lock.json → Version lock for all plugins (auto-generated)
```

---

## 🧰 Prerequisites (Debian/Ubuntu)

Install the base tools and dependencies:

```bash
sudo apt update
sudo apt install -y \
  curl git luarocks neovim \
  nodejs npm \
  python3 python3-pip python-is-python3 \
  pipx \
  shfmt shellcheck \
  ripgrep fd-find unzip

# Set up pipx
pipx ensurepath

# Python-based tools
pipx install black
pipx install pynvim
pipx install sqlfluff
pipx install typst

# Node-based tools
sudo npm install -g prettier eslint_d
sudo npm install -g tree-sitter-cli
```

## 🚀 Installation

First, the basics must be installed with `sudo apt install build-essential cmake`. Then, the [official installation instructions](https://github.com/neovim/neovim/blob/master/BUILD.md) can be followed.

### [Neovim update](#neovim-update)

To prevent the difference between Neovim and your individual configuration from becoming too large, you should update your Neovim installation every few weeks (at least every two months). This works as follows:

```bash
cd ~/repos/neovim
git checkout stable
git pull origin stable
rm -rf build/ .deps/ CMakeCache.txt CMakeFiles/ [optional]
sudo make install
```

Start Neovim and perform a `:Lazy update` to syncronize your plugins.

### Individual configuration

Clone this repository into your Neovim configuration directory and start Neovim (it will automatically install all plugins via lazy.nvim):

```bash
git clone https://marmork@bitbucket.org/marmork/nvim.git ~/.config/nvim
```

## 🧭 Usage

🖋️ Writing & Coding Modes

- Switch to writing mode: <leader>ws → changes directory to ~/Documents/Writing
- Switch to coding mode: <leader>wc → changes directory to ~/repos
- Toggle file tree: <leader>n

### 💡 Helpful Commands

- Open Lazy plugin manager: `:Lazy`
- Update plugins: `:Lazy update`
- Synchronize plugin list: `:Lazy sync`
- Format current file: `:lua vim.lsp.buf.format()`
- Check plugin health: `:checkhealth`

## 🔄 Updating Your Setup

1. Perform a Neovim update as described [here](#neovim-update).
2. If it is not already up to date, your individual configuration can also be updated:

```bash
cd ~/.config/nvim
git pull
```

1. Finally, start Neovim and perform a `:Lazy update`.

### Plugin updates

If you install new plugins or make changes to `~/.config/nvim/lua/plugins`, restart Neovim and perform a `:Lazy sync`.

## 🔧 Tips

1. Add new plugins under `lua/plugins/ `as separate files.
2. Centralize global mappings in `lua/keymaps.lua`.
3. If you create helpers (e.g., auto commands or formatters), put them in `lua/utils/`.
4. Use Git branches for larger config changes, e.g. `git checkout -b refactor/lsp-setup`

## 🧑‍💻 Developer Notes

To debug or reset your Neovim environment:

```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
nvim
```

This will rebuild the Lazy environment from scratch.

### 🚨 Troubleshooting (Corrupt Plugins/Submodules)

If you encounter persistent errors related to plugin updates or corrupted Git submodules (e.g., with LuaSnip), a hard reset of the affected plugin folder is required:

1. Close Neovim.
2. Delete the corrupted plugin folder in the terminal:

```bash
cd ~/.local/share/nvim/lazy
rm -rf LuaSnip
```

3. Start Neovim.
4. Run `:Lazy sync` and press `I` to clone the plugin cleanly again.

## 👤 Author

Marcel
