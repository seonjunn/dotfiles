if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Override fish_greeting as blank
set fish_greeting ""

#=
#  ALIASES
#=
alias x="exit"
alias vim="nvim"
alias l="ls"
alias ls="exa -l"
alias rm="rm -i"
alias hangul="xmodmap -e 'remove mod1 = Alt_R'; xmodmap -e 'keycode 108 = Hangul'"

#=
#  PLUGINS
#=
#- autojump
if test -f /home/sk1m/.autojump/share/autojump/autojump.fish; . /home/sk1m/.autojump/share/autojump/autojump.fish; end
