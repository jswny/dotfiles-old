# Dotfiles
These are my personal dotfiles.

## Prerequisites
### Packages
Install the following:
- [Fish Shell](https://fishshell.com/)
- [Tmux](https://github.com/tmux/tmux)
- [Tmux Plugin Manager(TPM)](https://github.com/tmux-plugins/tpm)
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