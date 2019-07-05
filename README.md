# Dotfiles
These are my personal dotfiles.

## Files
The following files are contained in this repository. Each file is listed with its description and where to symlink it in your local filesystem.
- `fish/config.fish` -- Fish configuration
  - `ln -s fish/config.fish ~/.config/fish/config.fish`
- `fish/fishfile` -- Fisherman plugin list
  - `ln -s fish/fishfile ~/.config/fish/fishfile`
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
- [GNU Coreutils](https://formulae.brew.sh/formula/coreutils) if you are using MacOS
- [Fish Shell](https://fishshell.com/)
- [Fisher](https://github.com/jorgebucaran/fisher)
- [FZF](https://github.com/junegunn/fzf)
- [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)
- [Tmux](https://github.com/tmux/tmux)
- [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm)
- [NeoVim](https://neovim.io/) (must install from `HEAD`)

### Setup
- [Fish as your default shell](https://fishshell.com/docs/current/tutorial.html#tut_switching_to_fish)
```sh
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish
```
- Solarized Dark colors set for Fish
  - Set from running `fish_config`
- Get [dircolors-solarized](https://github.com/seebi/dircolors-solarized)
  - Clone with `git clone https://github.com/seebi/dircolors-solarized.git ~/.local/share/dircolors-solarized`
- Set FZF universal variables
  - `set -U FZF_LEGACY_KEYBINDINGS 0`
  - `set -U FZF_TMUX 1`
  - `set -U FZF_COMPLETE 1`
- TPM plugins installed
  - <kbd>prefix</kbd> + <kbd>I</kbd> inside Tmux
- Python 2 and 3 providers installed for NeoVim
```sh
pip2 install pynvim
pip3 install pynvim
```
