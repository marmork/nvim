# Neovim Configuration – Writing & Coding Setup

This repository contains my personal **Neovim configuration** for both **writing** and **software development**.  
It is built on **Neovim ≥ 0.10**, uses **lazy.nvim** as a plugin manager, and follows a modular structure for maintainability.

---

## Features

Two dedicated work modes:
- **Writing Mode** (`<leader>ws`) → switches to `~/Documents/Writing`  
- **Coding Mode** (`<leader>wc`) → switches to `~/repos`  
- **Modern UI** (Gruvbox theme, nvim-tree, Telescope)  
- **Zettelkasten Integration** (Telekasten & Zotero)  
- **Built-in LSP, linting, and formatting** (Auto-format on save)  

---

## Folder Structure

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
│         ├── workspaces.lua → Writing/Coding mode switching logic
|    ├──plugins/ → One file per plugin definition
|         ├── ai.lua → CodeCompanion & Ollama config
|         ├── dispatch.lua
|         ├── editor.lua
|         ├── format.lua
|         ├── git.lua
|         ├── lint.lua
|         ├── theme.lua
|         ├── zettelkasten.lua
|    ├──snippets/zope → Various snippet definitions
|         ├── zope 
|               ├── package.json
|               ├── python.json
|               ├── sql.json
│    └── utils/ → custom helpers or shared functions
|         ├── pandoc.lua
|         ├── zettelkasten.lua
└── lazy-lock.json → Version lock for all plugins (auto-generated)
```

---

## Prerequisites (Debian/Ubuntu)

Install the base tools and dependencies:  

```bash
sudo apt update && sudo apt install -y \
  build-essential cmake curl git neovim nodejs npm pipx ripgrep fd-find unzip shfmt rocminfo

# Set up pipx
pipx ensurepath

# Manually installed tools
pipx install black pynvim ruff sqlfluff typst
```

Setup node in user home directory and install required packages:
```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
nano ~/.config/fish/config.fish
```

Add the following line to your Fish configuration:  

```
# Add local npm-global binaries to PATH
set -gx PATH $HOME/.npm-global/bin $PATH
```

Apply configuration changes with: `source ~/.config/fish/config.fish`.  
Install the following packages: `npm install -g eslint prettier tree-sitter-cli`.  

## Installation

### 1. Clean state

If you are experiencing plugin issues, remove old data: `rm -rf ~/.local/share/nvim ~/.cache/nvim ~/.local/state/nvim`.

### 2. Base installation

1. Clone this repository into your Neovim configuration directory: `git clone https://github.com/marmork/nvim.git ~/.config/nvim`.
2. Then, the [official installation instructions](https://github.com/neovim/neovim/blob/master/BUILD.md) can be followed.

### 3. First-time setup (required)

Since paths (like your Documents or Research folders) differ between machines, you must create a local configuration file. This file is ignored by Git to keep your setup portable.

- Navigate to the config directory: `cd ~/.config/nvim/lua/config/`  
- Copy the example configuration: `cp local_paths-example.lua local_paths.lua`  
- Edit local_paths.lua and fill in your specific system paths!  

### 4. Initialize plugins

Start Neovim: `nvim`. Lazy.nvim will start automatically and begin downloading all required plugins.  

- Wait for the process to finish (a UI will show the progress).  
- Once finished, you can close the UI by pressing q.  
- Restart Neovim once to ensure all plugins and LSPs are correctly loaded.  

### 5. [Neovim update](#neovim-update)

To prevent the difference between Neovim and your individual configuration from becoming too large, you should update your Neovim installation every few weeks (at least every two months). This works as follows: Run `chmod +x update_nvim.sh` once and update with `./update_nvim.sh`. Then start Neovim and perform a `:Lazy update` to syncronize your plugins.  

## AI & Local LLM Setup (Ollama)

This configuration uses **CodeCompanion.nvim** to talk to a local **Ollama** instance. This ensures your code stays private and works offline.  

### 1. Hardware-Accelerated Hosting (AMD Ryzen APU)

Optimized for **Ryzen 7 7730U** with Shared VRAM using the Vulkan-Bypass for stability.  

**Setup Steps:**  

1. Install Ollama: `curl -fsSL https://ollama.com/install.sh | sh`  
2. Set Permissions:  
   ```bash
   sudo usermod -a -G video,render ollama
   sudo usermod -a -G video,render $USER
   ```
3. Force Vulkan Mode (Systemd Override): `sudo systemctl edit ollama.service`  
4. Add the following block:  
   ```ini
   [Service]
   Environment="OLLAMA_VULKAN=1"
   ```
5. Restart service: `sudo systemctl daemon-reload && sudo systemctl restart ollama`  

### 2. Recommended Models

```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b
ollama pull qwen3.5:9b
ollama pull deepseek-r1:8b
```

### 3. Shell integration (Fish)

Add these to your ~/.config/fish/config.fish for quick access:  

```bash
# AI & LLM (Ollama)
alias qcoder='ollama run qwen2.5-coder:7b'
alias qbest='ollama run qwen2.5-coder:14b'
alias qwen='ollama run qwen3.5:9b'
alias r1='ollama run deepseek-r1:8b'

# Update installed models
function ollama-update --description 'Update all AI models to latest versions'
    set -l models qwen2.5-coder:7b qwen2.5-coder:14b qwen3.5:9b deepseek-r1:8b
    for model in $models
        echo "Checking for updates: $model..."
        ollama pull $model
    end
    echo "All models are up to date!"
end

# AI Quick Query Funktion
function ask --description 'Ask Ollama'
    set -l model_alias $argv[1]
    set -l final_model "qwen2.5-coder:7b" # Default to fastest coder

    switch $model_alias
        case 'c' 'qcoder'
            set final_model "qwen2.5-coder:7b"
            set -e argv[1]
        case 'b' 'best' 'qbest'
            set final_model "qwen2.5-coder:14b"
            set -e argv[1]
        case 'q' 'qwen'
            set final_model "qwen3.5:9b"
            set -e argv[1]
        case 'r1' 'deep' 'deepseek'
            set final_model "deepseek-r1:8b"
            set -e argv[1]
    end

    if test (count $argv) -gt 0
        echo "Using model: $final_model..."
        ollama run $final_model "$argv"
    else
        echo "Usage: ask [c|b|q|r1] 'Deine Frage'"
        echo "Beispiel: ask c 'Wie optimiere ich diesen Zope-Loop?'"
    end
end
```

## Usage

- Switch to writing mode: `<leader>ws` → changes directory to `~/Documents/Writing`
- Switch to coding mode: `<leader>wc` → changes directory to `~/repos`
- Toggle file tree: `<leader>n`

### Writing & Build Commands

This setup uses vim-dispatch to run compilation commands asynchronously in the background, preventing Neovim from freezing.  

Details:  

- LaTeX (.tex): Uses a chained lualatex (x3) and biber workflow (defined in lua/utils/pandoc.lua) to correctly resolve citations. After successful compilation, all temporary build files (.aux, .log, .bbl, etc.) are automatically removed.
- Markdown (.md): Uses a single pandoc command with the --citeproc and --pdf-engine=lualatex flags. The bibliography source must be specified in the YAML frontmatter of the Markdown file (e.g., bibliography: /path/to/my/library.bib).

### Helpful Commands

- Open Lazy plugin manager: `:Lazy`  
- Update plugins: `:Lazy update`  
- Synchronize plugin list: `:Lazy sync`  
- Format current file: `:ConformFormat`  
- Check plugin health: `:checkhealth`  
- Open Mason (Tool Manager): `:Mason`  

## Updating Your Setup

1. Perform a Neovim update as described [here](#neovim-update).  
2. If it is not already up to date, your individual configuration can also be updated:  

```bash
cd ~/.config/nvim
git pull
```

1. Finally, start Neovim and perform a `:Lazy update`.  

### Plugin updates

If you install new plugins or make changes to `~/.config/nvim/lua/plugins`, restart Neovim and perform a `:Lazy sync`.

## Tips

1. Add new plugins under `lua/plugins/ `as separate files.  
2. Centralize global mappings in `lua/keymaps.lua`.  
3. If you create helpers (e.g., auto commands or formatters), put them in `lua/utils/`.  
4. Use Git branches for larger config changes, e.g. `git checkout -b refactor/lsp-setup`.  

## Developer Notes

To debug or reset your Neovim environment:  

```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
rm -rf ~/.local/state/nvim
nvim
```

This will rebuild the Lazy environment from scratch.  

### Troubleshooting 

#### Corrupt Plugins/Submodules

If you encounter persistent errors related to plugin updates or corrupted Git submodules (e.g., with LuaSnip), a hard reset of the affected plugin folder is required:

1. Close Neovim.
2. Delete the corrupted plugin folder in the terminal, e.g.:

```bash
cd ~/.local/share/nvim/lazy
rm -rf LuaSnip
```

3. Start Neovim.
4. Run `:Lazy sync` and press `I` to clone the plugin cleanly again.

#### Treesitter / AI Chat

If the AI chat fails to open with a YAML parser error, Neovim cannot find the compiled parsers. This is fixed by forcing a specific parser directory in `lua/plugins/editor.lua`:

1. Ensure your Treesitter configuration includes:
   ```lua
   parser_install_dir = vim.fn.stdpath("data") .. "/parsers",
   ```
2. And that this path is added to the runtimepath: `vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/parsers")`.
3. Run `:TSInstall! yaml markdown_inline` inside Neovim to force a fresh, correctly linked installation.

## Author

Marcel
