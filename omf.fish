# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Basics
set EDITOR "nvim"
set TERM "kitty"
set SHELL "fish"

# Load Oh My Fish configuration.
source $OMF_PATH/init.fish

# Set Starship shell prompt
starship init fish | source

# Show colorscript
colorscript -r
