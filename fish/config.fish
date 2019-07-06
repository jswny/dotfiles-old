# Properly set XDG directory variables if they don't already exist (only for this file)
set -q XDG_DATA_HOME; or set -l XDG_DATA_HOME ~/.local/share

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
    echo 'Could not find Solarized Dark dircolors to use in "~/.local/share/dircolors-solarized/dircolors.256dark"'
end

# Abbreviations
# These don't need to be set here since they go into "fish_variables"
# They are listed here anyway in readable form
# abbr gc "git commit -S -m"