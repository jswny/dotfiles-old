#!/usr/bin/env bash

# Script for installing the dotfiles
# This script only covers installation of the dotfiles themselves, and does not handle installing any dependencies
# All dependencies should be installed before running this script

script_name=$(basename "$0")
log() {
  echo "[$script_name] $1"
}

# Set the XDG configuration directory if it is not already set
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"/root/.config"}

# Symlink Fish files
ln -s "$PWD/fish/config.fish" "$XDG_CONFIG_HOME/fish/config.fish"
ln -s "$PWD/fish/fishfile" "$XDG_CONFIG_HOME/fish/fishfile"

# Install plugins with Fisher
log "Installing Fisher plugins..."
fish -c "fisher"

# Symlink Tmux files
mkdir -p "$XDG_CONFIG_HOME/tmux"
ln -s "$PWD/tmux/.tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"

# Symlink to the regular Tmux config file location 
# As of Tmux 3.1 using XDG for the config file is supported: https://github.com/tmux/tmux/commit/15d7e564ddab575dd3ac803989cc99ac13b57198
# However, TPM doesn't recognize the XDG config file location by itself yet
# See https://github.com/tmux-plugins/tpm/issues/162
ln -s "$XDG_CONFIG_HOME/tmux/tmux.conf" "$HOME/.tmux.conf"

# Install TPM plugins
log "Installing TPM plugins..."
"$XDG_DATA_HOME"/tmux/plugins/tpm/bin/install_plugins

# Symlink NeoVim files
mkdir -p "$XDG_CONFIG_HOME/nvim"
ln -s "$PWD/nvim/init.vim" "$XDG_CONFIG_HOME/nvim/init.vim"
ln -s "$PWD/nvim/lcnv-settings.json" "$XDG_CONFIG_HOME/nvim/lcnv-settings.json"

# Install NeoVim plugins and output to log file since this output is not noninteractive
log "Installing NeoVim plugins..."
nvim --headless '+PlugInstall --sync' +qa &> /var/log/nvim_plug_install.log
