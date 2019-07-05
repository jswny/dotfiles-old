# Properly set XDG directory variables if they don't already exist (only for this file)
set -q XDG_DATA_HOME; or set -l XDG_DATA_HOME ~/.local/share

# Add VSCode to $PATH
set -l vscode_path
switch (uname)
    case Darwin
        set vscode_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
end
set PATH $vscode_path $PATH

# Set VSCode as the default editor
set -xg EDITOR "code"

# Disable the greeting message
set fish_greeting

# Use gls instead of ls if it is available
if command -sq gls
    alias ls="gls --color"
end

# Use Solarized Dark dircolors
set -l dircolors_provider dircolors
if command -sq gdircolors
    set dircolors_provider gdircolors
end
eval ($dircolors_provider -c $XDG_DATA_HOME/dircolors-solarized/dircolors.256dark)
