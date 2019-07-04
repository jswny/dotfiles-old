# Dotfiles
These are my personal dotfiles.

## Files
The following files are contained in this repository. Each file is listed with its description and where to symlink it in your local filesystem.
- `fish/fish_variables`: 
  - `ln -s fish/fish_variables ~/.config/fish/fish_variables`
  - Fish universal variables
- `hyper/hyper.js`
  - `ln -s hyper/hyper.js ~/.config/hyper/hyper.js`
  - Hyper Terminal configuration
- `iterm2/com.googlecode.iterm2.plist`
  - Configure iTerm2 to use this file for preferences directly (symlinks don't work)
  - iTerm2 configuration
- `nvim/init.vim`
  - `ln -s nvim/init.vim ~/.config/nvim/init.vim`
  - NeoVim configuration

## Prerequisites
### Packages
Install the following:
- Either [iTerm2](https://www.iterm2.com/) if you are using MacOS, or [Hyper Terminal](https://hyper.is/) if you are using Windows
- [Fish Shell](https://fishshell.com/)
- [Tmux](https://github.com/tmux/tmux)
- [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm)
- [NeoVim](https://neovim.io/) (must install from `HEAD`)

### Setup
- Fish as your default shell
```sh
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish
```
- TPM plugins installed
  - <kbd>prefix</kbd> + <kbd>I</kbd> inside Tmux
- Python 2 and 3 providers installed for NeoVim
```sh
pip2 install pynvim
pip3 install pynvim
```
