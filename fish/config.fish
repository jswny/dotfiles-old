# Properly set XDG directory variables if they don't already exist (only for this file)
set -q XDG_DATA_HOME; or set -l XDG_DATA_HOME ~/.local/share

# Prevent Tmux from re-sourcing the config
# if status is-interactive
# and set -q TMUX
#     exit
# end

# Start the ssh-agent and add the default key
eval (ssh-agent -c) > /dev/null
ssh-add

# Add VSCode to $PATH if it exists
set -l vscode_path
switch (uname)
    case Darwin
        set vscode_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
end

if test -e $vscode_path
    set PATH $vscode_path $PATH
else
    echo 'Could not find a valid path for VSCode to add to $PATH'
end

# Add Rustup to $PATH if it exists
set -l rustup_path
switch (uname)
    case Darwin
        set rustup_path "$HOME/.cargo/bin"
end

if test -e $rustup_path
    set PATH $rustup_path $PATH
else
    echo 'Could not find a valid path for Rustup to add to $PATH'
end

# Set VSCode as the default editor if it exists
if type -q "code"
    set -xg EDITOR "code"
else
    echo 'Could not find a valid VSCode executable "code" in $PATH'
end

# Disable the greeting message
set fish_greeting

# Use gls instead of ls if it is available
if command -sq gls
    alias ls="gls --color"
    set -xa THEFUCK_OVERRIDDEN_ALIASES 'ls,'
end

# Use Solarized Dark dircolors if they exist
set -l solarized_dark_dircolors_path $XDG_DATA_HOME/dircolors-solarized/dircolors.256dark

set -l dircolors_provider dircolors
if command -sq gdircolors
    set dircolors_provider gdircolors
end

if test -e $solarized_dark_dircolors_path
    eval ($dircolors_provider -c $solarized_dark_dircolors_path)
else
    echo "Could not find Solarized Dark dircolors to use in \"$solarized_dark_dircolors_path\""
end

# Alias The Fuck if it is available
if type -q "thefuck"
    thefuck --alias | source 
else
    echo 'Could not find a valid The Fuck executable "thefuck" in $PATH'
end

# Abbreviations and Universal Variables
# We set these here so that we can leave the fish_variables file out of source control and keep it machine independent
# These items are also human-readable as listed here

# Abbreviations
# abbr gc "git commit -S -m"
# abbr gs "git status"
# abbr gs "git push"

# Normal Variables
# Disable the default virtualenv prompt (bobthefish has it built-in)
set -x VIRTUAL_ENV_DISABLE_PROMPT 1
# Set bobthefish config options
set -g theme_color_scheme solarized-dark
set -g theme_display_date no

# Universal Variables
set -Ux FZF_CD_COMMAND 'fd --type d --follow --exclude .git . $dir 2> /dev/null'
set -U FZF_CD_WITH_HIDDEN_COMMAND 'fd --type d --hidden --follow --exclude .git . $dir 2> /dev/null'
set -U FZF_COMPLETE '1'
set -U FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git 2> /dev/null'
set -U FZF_DEFAULT_OPTS '-i --height 40%'
set -U FZF_ENABLE_OPEN_PREVIEW '1'
set -U FZF_FIND_FILE_COMMAND 'fd --type f --hidden --follow --exclude .git . $dir 2> /dev/null'
set -U FZF_LEGACY_KEYBINDINGS '0'
set -Ux FZF_OPEN_COMMAND 'fd --hidden --follow --exclude .git . $dir 2> /dev/null'
set -U FZF_PREVIEW_DIR_CMD 'fd --hidden --follow --exclude .git --max-depth 1 --color always . 2> /dev/null'
set -U FZF_PREVIEW_FILE_CMD 'head -n 10'
set -U FZF_TMUX '1'
set -U FZF_TMUX_HEIGHT '40%'
