#!/usr/bin/env bash

# Exit on any error, undefined variable, or pipe failure 
set -euo pipefail

# Script for installing the dotfiles
# This script only covers installation of the dotfiles themselves, and does not handle installing any dependencies
# All dependencies should be installed before running this script

script_name=$(basename "$0")
script_dir=$(dirname "$0")
log() {
  echo "[$script_name] $1"
}

# Set the XDG configuration directory if it is not already set
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"/root/.config"}

# Symlink Fish files
ln -s "$script_dir/../fish/config.fish" "$XDG_CONFIG_HOME/fish/config.fish"
ln -s "$script_dir/../fish/fishfile" "$XDG_CONFIG_HOME/fish/fishfile"

# Install plugins with Fisher
log "Installing Fisher plugins..."
fish -c "fisher"

# Symlink Tmux files
mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -s "$script_dir/../tmux/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

# If the Tmux version is < v3.1, symlink to the regular Tmux config file location 
# As of Tmux 3.1 using XDG for the config file is supported: https://github.com/tmux/tmux/commit/15d7e564ddab575dd3ac803989cc99ac13b57198
tmux_version=$(tmux -V | sed -nE 's/^tmux ([0-9]+\.[0.9]+).*/\1/p')
if (( $(echo "$tmux_version 3.1" | awk '{print ($1 > $2)}') )); then
  ln -s "$XDG_CONFIG_HOME/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

# Install TPM plugins
log "Installing TPM plugins..."
"$XDG_DATA_HOME"/tmux/plugins/tpm/bin/install_plugins

# Symlink NeoVim files
mkdir -p "$XDG_CONFIG_HOME/nvim"
ln -s "$script_dir/../nvim/init.vim" "$XDG_CONFIG_HOME/nvim/init.vim"
ln -s "$script_dir/../nvim/lcnv-settings.json" "$XDG_CONFIG_HOME/nvim/lcnv-settings.json"

# Install NeoVim plugins and output to log file since this output is not noninteractive
log "Installing NeoVim plugins..."
nvim --headless '+PlugInstall --sync' +qa &> /var/log/nvim_plug_install.log
