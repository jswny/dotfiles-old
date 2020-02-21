# Properly set XDG directory variables to defaults if they don't already exist (only for this file)
set -q XDG_CONFIG_HOME; or set -l XDG_CONFIG_HOME ~/.config
set -q XDG_DATA_HOME; or set -l XDG_DATA_HOME ~/.local/share

# Prevent Tmux from re-sourcing the config
# if status is-interactive
# and set -q TMUX
#     exit
# end

# Start the ssh-agent and add the default key if ssh-agent exists
if type -q ssh-agent
    eval (ssh-agent -c) > /dev/null
    ssh-add 2> /dev/null
end

# Add VSCode to $PATH if it exists
set -l vscode_path
switch (uname)
    case Darwin
        set vscode_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
end

# Set VSCode as the default editor if it exists
if test -e $vscode_path
    set PATH $vscode_path $PATH
end

if type -q "code"
    set -xg EDITOR "code --wait"
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
end

# Alias The Fuck if it is available
if type -q "thefuck"
    thefuck --alias | source 
end

# Abbreviations and Universal Variables
# We set these here so that we can leave the fish_variables file out of source control and keep it machine independent
# These items are also human-readable as listed here

# Abbreviations
# abbr gc "git commit -S -m"
# abbr gs "git status"
# abbr gs "git push"

# Configure Git to use Delta
git config --global core.pager "delta --dark"

# Variables

# Make sure Fish uses 24bit colors
set -g fish_term24bit 1

# Set Solarized Dark colors
set -U fish_color_autosuggestion '586e75'
set -U fish_color_cancel '-r'
set -U fish_color_command '93a1a1'
set -U fish_color_comment '586e75'
set -U fish_color_cwd 'green'
set -U fish_color_cwd_root 'red'
set -U fish_color_end '268bd2'
set -U fish_color_error 'dc322f'
set -U fish_color_escape '00a6b2'
set -U fish_color_history_current '--bold'
set -U fish_color_host 'normal'
set -U fish_color_match '--background=brblue'
set -U fish_color_normal 'normal'
set -U fish_color_operator '00a6b2'
set -U fish_color_param '839496'
set -U fish_color_quote '657b83'
set -U fish_color_redirection '6c71c4'
set -U fish_color_search_match 'bryellow' '--background=black'
set -U fish_color_selection 'white' '--bold'  '--background=brblack'
set -U fish_color_user 'brgreen'
set -U fish_color_valid_path '--underline'
set -U fish_pager_color_completion 'B3A06D'
set -U fish_pager_color_description 'B3A06D'
set -U fish_pager_color_prefix 'cyan' '--underline'
set -U fish_pager_color_progress 'brwhite' '--background=cyan'

# Disable the default virtualenv prompt (bobthefish has it built-in)
set -x VIRTUAL_ENV_DISABLE_PROMPT 1

# Set bobthefish config options
set -g theme_color_scheme terminal
set -g theme_display_date no

# Set Bat options
# The theme will also apply to Delta
set -gx BAT_THEME ansi-dark

# Use Bat to colorize manpages
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Set FZF Fish options
set -Ux FZF_CD_COMMAND 'fd --type d --follow --exclude .git --exclude venv . $dir 2> /dev/null'
set -Ux FZF_CD_WITH_HIDDEN_COMMAND 'fd --type d --hidden --follow --exclude .git . $dir 2> /dev/null'
set -Ux FZF_COMPLETE '1'
set -Ux FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git --exclude venv 2> /dev/null'
set -Ux FZF_DEFAULT_OPTS '-i --height 40% --color dark,hl:33,hl+:37,fg+:235,bg+:136,fg+:254 --color info:254,prompt:37,spinner:108,pointer:235,marker:235'
set -Ux FZF_ENABLE_OPEN_PREVIEW '1'
set -Ux FZF_FIND_FILE_COMMAND 'fd --type f --hidden --follow --exclude .git --exdlude venv . $dir 2> /dev/null'
set -Ux FZF_LEGACY_KEYBINDINGS '0'
set -Ux FZF_OPEN_COMMAND 'fd --hidden --follow --exclude .git --exclude venv . $dir 2> /dev/null'
set -Ux FZF_PREVIEW_DIR_CMD 'fd --hidden --follow --exclude .git --max-depth 1 --color always . 2> /dev/null'
set -Ux FZF_PREVIEW_FILE_CMD 'bat --color=always --style=plain'
set -Ux FZF_TMUX '1'
set -Ux FZF_TMUX_HEIGHT '40%'

# Source machine-dependent configuration
# Only sources the file if it exists
# This should be the last thing in this file so the local configuration can override things as needed
set -l machine_configuration_path $XDG_CONFIG_HOME/fish/local.config.fish

if test -e $machine_configuration_path
    source $machine_configuration_path
end