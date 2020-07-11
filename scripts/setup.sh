#!/usr/bin/env bash
# Script to setup everything needed for this dotfiles setup

# Name of the script only
script_name="$(basename "${0}")"

# shellcheck source=scripts/common.sh
source "$(dirname "${0}")"/common.sh

# Exit on any error, undefined variable, or pipe failure 
set -euo pipefail

# Setup default environment variables
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
XDG_DATA_HOME=${XDG_DATA_HOME:-"${HOME}/.local/share"}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-"${HOME}/.cache"}

# Ensure environment variables are set for Brew
# It will error out trying to append to these if they aren't already set
PATH="${PATH:-}"
MANPATH="${MANPATH:-}"
INFOPATH="${INFOPATH:-}"

# Where to install source code for packages and other tools
PACKAGE_SOURCE_HOME=${PACKAGE_SOURCE_HOME-"${HOME}/.local/src"}

# Default values for certain variables
apt_update=0
debug=0

# Display command-line help info
help() {
  cat << EOF
usage: ${0} [OPTIONS]
  --help                Show this message
  --debug               Display extra debug info
  --no-brew-packages    Don't install brew packages from Brewfile
EOF
}

# Detect the OS currently running this script
detect_os() {
  if [[ "${OSTYPE}" == 'linux-gnu' ]]; then
    os='linux'
  elif [[ "${OSTYPE}" == 'darwin'* ]]; then
    os='mac'
  else
    unsupported_os
  fi
  log 'debug' "Detected OS \"${os}\""
}

unsupported_os() {
  log 'error' "Unsupported operating system \"${OSTYPE}\"!"
  exit 1
}

get_parent_directory() {
  # Using dirname will allow us to get the parent directory even if it doesn't exist
  parent_directory="$(dirname "${1}")"
  log 'debug' "Parent directory for \"${1}\" is \"${parent_directory}\""
}

# Check if an executable is valid
check_executable() {
  if [ -x "$(command -v "${1}")" ]; then
    log 'debug' "Executable ${1} found"
    return 0
  fi
  log 'debug' "Executable \"${1}\" does not exist"
  return 1
}

# Install a package using a supported package manager
install_package() {
  if check_executable 'apt-get'; then
    log 'debug' "Installing package \"${1}\" with apt..."
    if [ "${apt_update}" = 0 ]; then
      log 'info' 'Updating apt...'
      
      sudo apt-get update
      apt_update=1
    fi
    sudo apt-get install -y "${1}"
  else
    log 'error' "Cannot automatically install package \"${1}\", please manually install and try again!"
    exit 1
  fi
}

# Search through valid brew installation paths to find a valid executable
find_brew_executable() {
  local local_brew_executable_paths=(
    '/home/linuxbrew/.linuxbrew/bin/brew'
    "${HOME}/.linuxbrew/bin/brew"
  )

  for path in "${local_brew_executable_paths[@]}"; do
    log 'debug' "Checking \"${path}\" for brew executable..."
    if check_executable "${path}"; then
      log 'info' "Found brew executable at \"${path}\""
      local_brew_executable="${path}"
      return 0
    fi
  done
  return 1
}

# Creates the parent directory if it doesn't exist for a path
ensure_parent_dir_exists() {
  get_parent_directory "${1}"
  if [ ! -d "${parent_directory}" ]; then
    log 'debug' "Parent directory \"${parent_directory}\" for target \"${1}\" does not exist, creating..."
    mkdir -p "${parent_directory}"
  fi
}

# Ensure both sides of a symlink exist and symlink
# Creates necessary directories if they don't exist for the target
ensure_exists_and_symlink() {
  if [ ! -e "${1}" ]; then
    log 'error' "Attempted to symlink \"${1}\" to \"${2}\" but source does not exist!"
    exit 1
  fi

  if [ -e "${2}" ]; then
    log 'info' "Attempted to symlink \"${1}\" to \"${2}\" but target already exists! Skipping..."
  else
    ensure_parent_dir_exists "${2}"
    log 'info' "Symlinking \"${1}\" -> \"${2}\"..." ln -s "${1}" "${2}"
    ln -s "${1}" "${2}"
  fi
}

# Creates a file if it doesn't exist
# TODO: use common function
ensure_file_exists() {
  if [ ! -f "${1}" ]; then
    if [ -e "${1}" ]; then
      log 'error' "Item at path \"${1}\" already exists, but it is not a file!"
      exit 1
    else
      log 'info' "File \"${1}\" does not exist, creating..."
      ensure_parent_dir_exists "${1}"
      touch "${1}"
    fi
  fi
}

# Checks if a line exists in a file using a regex and Grep and appends something to the file if not
# Defaults to appending the line anyway if Grep cannot be found
ensure_line_exists() {
  ensure_file_exists "${2}"

  check_executable 'grep'
  grep_present="${?}"
  if [ "${grep_present}" = 0 ] && grep -E "${1}" "${2}"; then
    log 'info' "Line \"${1}\" already exists in file \"${2}\", skipping..."
  else
    if [ ! "${grep_present}" = 0 ]; then
      log 'warn' "Could not find grep executable to check if line \"${1}\" already exists in file \"${2}\". Adding line \"${3}\" be safe..."
    else
      log 'info' "Adding line \"${3}\" to file \"${2}\"..."
    fi

    # Write the thing directly if it is writable, otherwise use sudo tee
    if [ -w "${2}" ]; then
      log 'debug' 'Writing line normally...'
      echo "${3}" >> "${2}"
    else
      log 'debug' 'Writing line with sudo...'
      echo "${3}" | sudo tee -a "${2}"
    fi
  fi
}

# Symlinks a Tmux configuration file the regular (non-xdg) configuration location ($HOME/.tmux.conf)
symlink_tmux_conf_non_xdg() {
  ensure_exists_and_symlink "${dotfiles_path}/tmux/tmux.conf" "${HOME}/.tmux.conf"
}

get_parent_directory "${0}"
script_path="${parent_directory}"
get_parent_directory "${script_path}"
dotfiles_path="${parent_directory}"

# Ensure we aren't running as root
if [ "${EUID}" = 0 ]; then 
  log 'error' 'Please do not run as root! sudo will be used when necessary'
  exit 1
fi

# Ensure sudo is installed
if ! check_executable 'sudo'; then
  log 'error' 'sudo is required to run setup. Please run again with sudo installed'
  exit 1
fi

# Parse command-line options
for opt in "${@}"; do
  case ${opt} in
    --help)
      help
      exit 0
      ;;
    --debug)
      debug=1
      log 'debug' 'Running in debug mode'
      ;;
    --no-brew-packages)
      no_brew_packages=1
      log 'debug' 'Brew packages will not be installed'
      ;;
    *)
      log 'error' "unknown option: \"$opt\""
      help
      exit 1
      ;;
  esac
done

# Set default values for comman-line options
debug=${debug:-0}
no_brew_packages=${no_brew_packages:-0}

# Detect the OS and make sure it is a supported one
detect_os

# Verify Brew dependencies are installed
# See the following for minimum requirements to install Brew:
# Linux: https://docs.brew.sh/Homebrew-on-Linux
# Mac: https://docs.brew.sh/Installation
if [ $os = 'mac' ]; then
  if ! xcode-select -p 1>/dev/null; then
    log 'info' 'brew dependency XCode command line tools is not installed, installing...'
    xcode-select --install
  else
    log 'info' 'brew dependency XCode command line tools is already installed'
  fi
elif [ $os = 'linux' ]; then
  brew_dependencies=(
    gcc
    ldd # for glibc
    make
    curl
    file
    git
  )

  for dep in "${brew_dependencies[@]}"; do if [ "$dep" = 'ldd' ]; then
      dep_package='libc6'
    else
      dep_package="$dep"
    fi

    if ! check_executable "$dep"; then
      log 'info' "brew dependency \"$dep_package\" is not installed, installing..."
      install_package "$dep_package"
    else
      log 'info' "brew dependency \"$dep_package\" is already installed"
    fi
  done
else
  unsupported_os
fi

# Install Brew (if it isn't already installed) and source it
if find_brew_executable; then
  log 'info' "brew is already installed at \"$local_brew_executable\", skipping..."
else
  log 'info' 'Installing brew...'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

if find_brew_executable; then
  log 'info' "Sourcing brew from \"$local_brew_executable\"..."
  # Make sure $SHELL is set to bash so that this doesn't try to run commands for the user shell instead
  eval "$(SHELL=bash bash -c "$local_brew_executable shellenv")"
else
  log 'error' 'Could not find local brew executable to provide shell sourcing of brew'
  exit 1
fi

# Install Brew packages from Brewfile
if [ ! "$no_brew_packages" = 1 ]; then
  brewfile_path="$dotfiles_path/brew/Brewfile"
  log 'info' "Installing brew bundle from \"$brewfile_path\""
  brew bundle --no-lock --file "$brewfile_path"
else
  log 'info' 'Skipping brew packages installation because --no-brew-packages was specified...'
fi

# Change default shell to Fish if it isn't already
if [ -z "${SHELL:-}" ] || [[ "$SHELL" != *'fish'* ]]; then
  fish_path="$(command -v 'fish')"
  log 'info' "Changing shell to fish at \"$fish_path\"..."
  ensure_line_exists "^$fish_path$" '/etc/shells' "$fish_path"
  sudo chsh -s "$fish_path" "$(whoami)"
else
  log 'info' "\$SHELL value \"$SHELL\" already contains \"fish\", skipping default shell change..."
fi

# Symlink Fish files
log 'info' 'Symlinking fish files...'
fish_config_path="$XDG_CONFIG_HOME/fish"
ensure_exists_and_symlink "$dotfiles_path/fish/config.fish" "$fish_config_path/config.fish"
fishfile_path="$fish_config_path/fishfile"
ensure_exists_and_symlink "$dotfiles_path/fish/fishfile" "$fishfile_path"

# Add Brew source to local fish configuration if the line doesn't already exist in the file
# This will create the file if it doesn't already exist
ensure_line_exists '^eval \\$?\\(.*brew shellenv\\)$' "$XDG_CONFIG_HOME/fish/local.config.fish" "eval ($local_brew_executable shellenv)"

# Setup Fisher and install plugins
fisher_path="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
log 'info' "Installing fisher to \"$fisher_path\"..."
curl https://git.io/fisher --create-dirs -sLo "$fisher_path"
log 'info' "Installing fisher plugins from \"$fishfile_path\"..."
fish --command 'fisher'

# Symlink Tmux files
log 'info' 'Symlinking tmux files...'
 
# If the Tmux version is < v3.1, also symlink to the regular Tmux config file location $HOME/.tmux.conf
# As of Tmux 3.1 using XDG for the config file is supported: https://github.com/tmux/tmux/commit/15d7e564ddab575dd3ac803989cc99ac13b57198
executable_warning_prefix='Could not find'
executable_warning_postfix="executable to check tmux version to check if the installed tmux version supports the XDG configuration location \"$XDG_CONFIG_HOME/tmux/tmux.conf\". Symlinking tmux configuration to normal location \"$HOME/.tmux.conf\" to be safe..."
required_tmux_version='3.1'
if check_executable 'sed'; then
  tmux_version=$(tmux -V | sed -nE 's/^tmux ([0-9]+\.[0-9]+).*/\1/p')
  log 'debug' "Detected tmux version \"$tmux_version\""
  
  if check_executable 'awk'; then
    if (( $(echo "$tmux_version $required_tmux_version" | awk '{print (${1} < ${2})}') )); then
      log 'info' "Detected tmux version \"$tmux_version\" < $required_tmux_version which does not support the XDG configuration location \"$XDG_CONFIG_HOME/tmux/tmux.conf\". Symlinking to normal location \"$HOME/.tmux.conf\"..."
      symlink_tmux_conf_non_xdg
    else
      ensure_exists_and_symlink "$dotfiles_path/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
    fi
  else
    log 'warn' "$executable_warning_prefix \"awk\" $executable_warning_postfix"
    symlink_tmux_conf_non_xdg
  fi
else
  log 'warn' "$executable_warning_prefix \"sed\" $executable_warning_postfix"
  symlink_tmux_conf_non_xdg
fi

# Install TPM
tpm_path="$XDG_DATA_HOME/tmux/plugins/tpm"
log 'info' "Installing tpm to \"$tpm_path\"..."
git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_path"

# Install TPM plugins
log 'info' 'Installing TPM plugins...'
"$tpm_path"/bin/install_plugins

# Symlink NeoVim files
log 'info' 'Symlinking NeoVim files...'
ensure_exists_and_symlink "$dotfiles_path/nvim/init.vim" "$XDG_CONFIG_HOME/nvim/init.vim"
ensure_exists_and_symlink "$dotfiles_path/nvim/lcnv-settings.json" "$XDG_CONFIG_HOME/nvim/lcnv-settings.json"

# Install NeoVim Python provider
log 'info' 'Installing NeoVim python provider...'
pip3 install --upgrade pynvim

# Install Vim-Plug
vim_plug_path="$XDG_DATA_HOME/nvim/site/autoload/plug.vim"
log 'info' "Installing vim-plug to \"$vim_plug_path\""
curl --create-dirs -sfLo "$vim_plug_path" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install Vim-Plug plugins
# Log this to a file since the output is not meant to be readable outside of NeoVim
vim_plug_install_log_path="$XDG_CACHE_HOME/vim_plug_install.log"
log 'info' "Installing vim-plug plugins and logging to \"$vim_plug_install_log_path\"..."

nvim --headless '+PlugInstall --sync' +qa &> "$vim_plug_install_log_path"

# Setup dircolors-solarized
dircolors_solarized_path="$PACKAGE_SOURCE_HOME/dircolors-solarized"
log 'info' "Installing dircolors-solarized to \"$dircolors_solarized_path\""
git clone --depth 1 https://github.com/seebi/dircolors-solarized.git "$dircolors_solarized_path"

# Setup Rebar and Hex
if ! check_executable 'mix'; then
  log 'error' 'Cannot install Rebar and Hex because mix executable is missing!'
  exit 1
fi

log 'info' 'Installing Rebar via Mix...'
mix local.rebar --force

log 'info' 'Installing Hex via Mix...'
mix local.hex --force

# Setup Elixir LS
elixir_ls_path="$PACKAGE_SOURCE_HOME/elixir-ls"
log 'info' "Installing Elixir LS to \"$elixir_ls_path\"..."
git clone --depth 1 https://github.com/elixir-lsp/elixir-ls.git "$elixir_ls_path"
cd "$elixir_ls_path"
mix deps.get
mix deps.compile
mix elixir_ls.release
ln -s "$elixir_ls_path/release/language_server.sh" "$elixir_ls_path/release/elixir-ls"
# shellcheck disable=SC2016
echo set -g fish_user_paths "$elixir_ls_path/release" '$fish_user_paths' >> "$fish_config_path/local.config.fish"
