if status is-interactive
    # Commands to run in interactive sessions can go here
end

# 
set fish_greeting

# paths
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"

# aliases
alias ls "exa -l"
