#!/bin/bash

# Navigate to the Neovim directory (adjust path if necessary)
cd ~/repos/neovim || exit

echo "--- Starting Neovim Update Process (Stable) ---"

# 1. Fix potential permission issues from previous 'sudo make install'
echo "Checking file permissions..."
sudo chown -R $(whoami):$(id -gn) .

# 2. Fetch latest changes from remote
echo "Fetching from origin..."
git fetch --all --tags

# 3. Force reset to the official stable branch
# This cleans up the 'detached HEAD' state
echo "Resetting local branch to origin/stable..."
git checkout -B stable origin/stable
git reset --hard origin/stable

# 4. Deep clean the repository
# -x: remove ignored files, -d: remove directories, -f: force
echo "Cleaning build artifacts..."
git clean -xdf

# 5. Build Neovim
# Using RelWithDebInfo is the recommended default for performance and debugging
echo "Starting build process..."
make CMAKE_BUILD_TYPE=RelWithDebInfo

# 6. Optional: Install
read -p "Build finished. Do you want to install Neovim now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Installing..."
  sudo make install
  echo "Installation complete!"
else
  echo "Skipping installation. Binary is available in ./build/bin/nvim"
fi

echo "--- Done! ---"
