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
- Built-in LSP, linting, and formatting
- Automatic formatting on save

---

## 🧩 Folder Structure

```
~/.config/nvim/
├── init.lua → Entry point (loads Lazy and your modules)
├── lua/
|    ├──config/
|         ├── format_setup.lua → Set formatting according to file type
│         ├── keymaps.lua → Centralized keybindings
|         ├── lint_setup.lua → Configure linter
|         ├── local_paths.lua → Define paths
|         ├── settings.lua → Neovim options (tabs, numbers, etc.)
|         ├── tool_installer → Mason: Define Linters/Formatters to install
│         ├── workspaces.lua → Writing/Coding mode switching logic
|    ├──plugins/ → One file per plugin definition
|         ├── dispatch.lua
|         ├── editor.lua
|         ├── git.lua
|         ├── linting.lua
|         ├── lsp.lua
|         ├── theme.lua
|         ├── zettelkasten.lua
│    └── utils/ → custom helpers or shared functions
|         ├── editor.lua
|         ├── pandoc.lua
|         ├── zettelkasten.lua
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
  ripgrep fd-find unzip

# Set up pipx
pipx ensurepath

# Manually installed tools (Mason does not manage these, e.g., for LaTeX/Typst)
pipx install pynvim
pipx install typst

# Node-based tools
sudo npm install -g tree-sitter-cli
```

## 🚀 Installation

If you previously had another Neovim configuration or are experiencing plugin issues, it is best to start with a clean slate by removing old data and cache folders:

```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.local/state/nvim
```

### 1. Base installation

1. First, the basics must be installed with `sudo apt install build-essential cmake`.
2. Clone this repository into your Neovim configuration directory: `git clone https://github.com/marmork/nvim.git ~/.config/nvim`.
3. Then, the [official installation instructions](https://github.com/neovim/neovim/blob/master/BUILD.md) can be followed.

### 2. First-time setup (required)

Since paths (like your Documents or Research folders) differ between machines, you must create a local configuration file. This file is ignored by Git to keep your setup portable.

- Navigate to the config directory: `cd ~/.config/nvim/lua/config/`
- Copy the example configuration: `cp local_paths-example.lua local_paths.lua`
- Edit local_paths.lua and fill in your specific system paths!

### 3. Initialize plugins

Start Neovim: `nvim`. Lazy.nvim will start automatically and begin downloading all required plugins.

- Wait for the process to finish (a UI will show the progress).
- Once finished, you can close the UI by pressing q.
- Restart Neovim once to ensure all plugins and LSPs are correctly loaded.

### 4. [Neovim update](#neovim-update)

To prevent the difference between Neovim and your individual configuration from becoming too large, you should update your Neovim installation every few weeks (at least every two months). This works as follows: Run `chmod +x update_nvim.sh` once and update with `./update_nvim.sh`. Then start Neovim and perform a `:Lazy update` to syncronize your plugins.

## 🧭 Usage

🖋️ Writing & Coding Modes

- Switch to writing mode: <leader>ws → changes directory to ~/Documents/Writing
- Switch to coding mode: <leader>wc → changes directory to ~/repos
- Toggle file tree: <leader>n

### 🛠️ Writing & Build Commands

This setup uses vim-dispatch to run compilation commands asynchronously in the background, preventing Neovim from freezing.

Details:

- LaTeX (.tex): Uses a chained lualatex (x3) and biber workflow (defined in lua/utils/pandoc.lua) to correctly resolve citations. After successful compilation, all temporary build files (.aux, .log, .bbl, etc.) are automatically removed.
- Markdown (.md): Uses a single pandoc command with the --citeproc and --pdf-engine=lualatex flags. The bibliography source must be specified in the YAML frontmatter of the Markdown file (e.g., bibliography: /path/to/my/library.bib).

### 💡 Helpful Commands

- Open Lazy plugin manager: `:Lazy`
- Update plugins: `:Lazy update`
- Synchronize plugin list: `:Lazy sync`
- Format current file: `:ConformFormat`
- Check plugin health: `:checkhealth`
- Open Mason (Tool Manager): `:Mason`

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
rm -rf ~/.local/state/nvim
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
