# Dotfiles
These are my personal dotfiles.

## Files
The following files are contained in this repository. Each file/directory is listed with its description and where to symlink it in your local filesystem.
- `fish/` -- All Configuration
  - `ln -s fish ~/.config/fish` (note that the `~/.config/fish` directory must not exist yet to symlink properly)
  - `fish/config.fish` -- General Fish configuration
  - `fish/fish_variables` -- Fish [universal variables](https://fishshell.com/docs/current/tutorial.html#tut_universal)
  - `fish/fishfile` -- Fisherman plugin list
- `hyper/hyper.js` -- Hyper Terminal configuration
  - `ln -s hyper/hyper.js ~/.config/hyper/hyper.js`
- `iterm2/com.googlecode.iterm2.plist` -- iTerm2 general configuration
  - Configure iTerm2 to use this file for preferences directly (symlinks don't work)
- `iterm2/profiles.json` -- iTerm2 [Dynamic Profiles](https://www.iterm2.com/documentation-dynamic-profiles.html) configuration
  - `ln -s iterm2 ~/Library/Application\ Support/iTerm2/DynamicProfiles/profiles.json`
- `nvim/init.vim` -- NeoVim configuration
  - `ln -s nvim/init.vim ~/.config/nvim/init.vim`

## Prerequisites
### Packages
Install the following:
- Either [iTerm2](https://www.iterm2.com/) or [Hyper Terminal](https://hyper.is/)
- [GNU Coreutils](https://formulae.brew.sh/formula/coreutils) if you are using MacOS
- [Fish Shell](https://fishshell.com/)
- [Fisher](https://github.com/jorgebucaran/fisher)
- [FZF](https://github.com/junegunn/fzf)
- [Ripgrep](https://github.com/BurntSushi/ripgrep)
- [Tmux](https://github.com/tmux/tmux)
- [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm)
- [NeoVim](https://neovim.io/) (must install from `HEAD`)

### Setup
- [Fish as your default shell](https://fishshell.com/docs/current/tutorial.html#tut_switching_to_fish)
```sh
echo /usr/local/bin/fish | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish
```
- Get [dircolors-solarized](https://github.com/seebi/dircolors-solarized)
  - Clone with `git clone https://github.com/seebi/dircolors-solarized.git ~/.local/share/dircolors-solarized`
- TPM plugins installed
  - <kbd>prefix</kbd> + <kbd>I</kbd> inside Tmux
- Python 2 and 3 providers installed for NeoVim
```sh
pip2 install pynvim
pip3 install pynvim
```
