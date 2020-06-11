# Dotfiles ![CI](https://github.com/jswny/dotfiles/workflows/CI/badge.svg) [![Docker Pulls](https://img.shields.io/docker/pulls/jswny/dotfiles)](https://hub.docker.com/r/jswny/dotfiles)
These are my personal dotfiles which I use on a daily basis on MacOS!

![Screenshot](images/screenshot.png)

## Tools
- [Brew](brew.sh)
- [iTerm2](https://www.iterm2.com/)
- [Hyper Terminal](https://hyper.is/)
- [Fish Shell](https://fishshell.com/)
- [Fisher](https://github.com/jorgebucaran/fisher)
- [NeoVim](https://neovim.io/) (latest version)
- [Tmux](https://github.com/tmux/tmux) (v2.9+)
- [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm)
- [FZF](https://github.com/junegunn/fzf)
- [FD](https://github.com/sharkdp/fd)
- [Bat](https://github.com/sharkdp/bat)
- [Delta](https://github.com/dandavison/delta)
- [The Fuck](https://github.com/nvbn/thefuck)
- [GNU Coreutils](https://formulae.brew.sh/formula/coreutils) (MacOS only)
- [Dircolors Solarized](https://github.com/seebi/dircolors-solarized)


## Setup
Run the setup script:
```sh
git clone https://github.com/jswny/dotfiles.git
cd dotfiles
scripts/setup.sh
```

## Local Configuration
### Fish
- To add local Fish configuration, simply create a file `local.config.fish` and place it in the same directory as `config.fish`. From there, `config.fish` will source that file if it exists (after it has already run all of its own commands).

### Tmux
- To add local Tmux configuration, simply create a file `local.tmux.conf` and place it in the same directory as `tmux.conf`. From there, `tmux.conf` will source that file if it exists (after it has already run all of its own commands). You can use the custom variables generated in `tmux.conf` in `local.tmux.conf` to easily cusomize Tmux.

## Docker
This repository contains a `Dockerfile` which you can use to test out these dotfiles. This will build an Ubuntu-based docker image and run it for you:
`docker build -t jswny/dotfiles . && docker run -it jswny/dotfiles`
You can also pull [the latest version from Docker Hub](https://hub.docker.com/r/jswny/devbox) if you don't want to build it yourself.

## Philosophy
- **Minimalism**
  - Minimal configuration where possible
- **Filesystem Heirarchy**
  - Use the [XDG Base Directory Spec](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html) where possible/reasonable
  - Accordingly, consume the existing XDG environment variable if possible or use a default set at the point of use, instead of relying on XDG variables being already set before the point of use.
  - See [this Arch Linux guide](https://wiki.archlinux.org/index.php/XDG_Base_Directory) for a good summary of which programs support XDG
- **Operating Systems**
  - Support MacOS and Linux
  - Support Windows to some extent, but only through WSL. When WSL 2 is stable Windows support might be more feasable, but at the moment WSL 1 breaks Fish
- **Errors**
  - Fail gracefully wherever possible but try to warn when something is going wrong if it is potentially a problem
  - Fail silently but gracefully for anticipated errors
- **Colors**
  - Use Solarized dark wherever possible due to its widespread support and ease on the eyes.
  - Use truecolor (hex colors) when possible, fallback to 256 colors, and only then fallback to ANSI colors.
- **Packaging**
  - Install packages with [Brew](https://brew.sh/). This provides the most up-to-date versions of packages.
  - Install packages from source in `$PACKAGE_SOURCE_HOME` which defaults to `~/.local/src`. This doesn't include things like [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm) which install from source but manage themselves and have a dedicated installation location.
- **Setup**
  - Setup everything possible to setup for a command-line environment
  - Don't setup anything which is not command-line (such as GUI programs, etc.). However, accomidating these if they exist is fine.
- **Local Configuration**
  - Provide local, machine-dependent configuration where necessary.
  - Local configuration should only be used in the situation where a certain configuration is short-lived, or machine-dependent (applies to a single machine, **not** a single operating system)
  - Local configuration should allow for these situations without the need to modify source-controlled files, so the repository can be kept clean and updated on a machine without affecting local configuration.

## Additional Files and Linking
Most symlinks are automatically setup in the setup script. However, non-cross-platform utilities are not, and can be handled as shown below.
- `hyper/hyper.js` -- Hyper Terminal configuration
  - `ln -s $PWD/hyper/hyper.js ~/.config/hyper/hyper.js`
- `iterm2/com.googlecode.iterm2.plist` -- iTerm2 general configuration
  - Configure iTerm2 to use this file for preferences directly (symlinks don't work)
- `iterm2/profiles.json` -- iTerm2 [Dynamic Profiles](https://www.iterm2.com/documentation-dynamic-profiles.html) configuration
  - `ln -s $PWD/iterm2 ~/Library/Application\ Support/iTerm2/DynamicProfiles/profiles.json`
