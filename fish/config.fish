# Properly set XDG directory variables if they don't already exist
set -q XDG_DATA_HOME; or set XDG_DATA_HOME ~/.local/share

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