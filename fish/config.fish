if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Mute fish greeting
set fish_greeting

# Language as engligh
export LC_ALL=C

# PATHS
eval (/opt/homebrew/bin/brew shellenv)
export SHELL=(which fish)
export PATH="$HOME/Library/Python/3.8/bin:$PATH"

# Plugins
zoxide init fish | source

# aliases
alias cat   "bat"
alias l    "exa -l"
alias rm    "rm -i"
alias v     "vim"
alias py    "python3"


function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "

	set_color 3bb 
    echo -n (whoami)

	set_color bbb 
    echo -n "."

	set_color b6b 
    echo -n (hostname) | sed 's/.local//'
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end
