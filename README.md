# 🧠 Neovim Configuration – Writing & Coding Setup

This repository contains my personal **Neovim configuration** for both **writing** and **software development**.  
It is built on **Neovim ≥ 0.10**, uses **lazy.nvim** as a plugin manager, and follows a clean modular structure for maintainability.

---

## ⚙️ Features

✅ Two dedicated work modes:
- **Writing Mode** (`<leader>ws`) → switches to `~/Documents/Writing`
- **Coding Mode** (`<leader>wc`) → switches to `~/repos`

✅ Key tools included:
- Modern UI (Catppuccin theme, nvim-tree, Telescope)
- Built-in LSP, linting, and formatting (via `none-ls.nvim`)
- Automatic formatting on save
- Lightweight modular structure for readability and control

---

## 🧩 Folder Structure

~/.config/nvim/
├── init.lua → Entry point (loads Lazy and your modules)
├── lua/
│ ├── settings.lua → Neovim options (tabs, numbers, etc.)
│ ├── keymaps.lua → Centralized keybindings
│ ├── workspaces.lua → Writing/Coding mode switching logic
│ ├── plugins/ → One file per plugin definition
│ └── utils/ → (optional) custom helpers or shared functions
└── lazy-lock.json → Version lock for all plugins (auto-generated)  

---

## 🧰 Prerequisites (Debian/Ubuntu)

Install the base tools and dependencies:

```bash
sudo apt update
sudo apt install -y \
  neovim git curl \
  nodejs npm \
  python3 python3-pip python-is-python3 \
  pipx \
  shfmt shellcheck \
  ripgrep fd-find unzip

# Set up pipx
pipx ensurepath

# Python-based tools
pipx install black
pipx install sqlfluff
pipx install typst

# Node-based tools
sudo npm install -g prettier eslint_d
```

## 🚀 Installation

Clone this repository into your Neovim configuration directory and start Neovim (it will automatically install all plugins via lazy.nvim)::  
```bash
git clone https://github.com/<your-username>/nvim-config.git ~/.config/nvim
nvim
```

## 🧭 Usage
🖋️ Writing & Coding Modes

- Switch to writing mode: <leader>ws → changes directory to ~/Documents/Writing  
- Switch to coding mode: <leader>wc → changes directory to ~/repos  
- Toggle file tree: <leader>n  

### 💡 Helpful Commands
- Open Lazy plugin manager:	`:Lazy`  
- Format current file: `:lua vim.lsp.buf.format()`  
- Check plugin health:	`:checkhealth`  
- Update plugins: `:Lazy update`  

## 🔄 Updating Your Setup

To keep everything up to date:  
```bash
cd ~/.config/nvim
git pull
nvim
:Lazy update
```

If you install new plugins or make changes to lua/plugins/:  
```bash
nvim
:Lazy sync
```

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

## 👤 Author

Marcel