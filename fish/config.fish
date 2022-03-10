if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Mute fish greeting
set fish_greeting

# lang as eng
export LC_ALL=C

# PATHS
eval (/opt/homebrew/bin/brew shellenv)
export SHELL=(which fish)
export PATH="$HOME/Library/Python/3.8/bin:$PATH"

# Plugins
zoxide init fish | source

# abbr
abbr -a cat "bat"
abbr -a v   "vim"
abbr py     "python3"

if command -v exa > /dev/null
	abbr -a l   'exa'
	abbr -a ls  'exa'
	abbr -a ll  'exa -l'
	abbr -a lll 'exa -la'
else
	abbr -a l   'ls'
	abbr -a ll  'ls -l'
	abbr -a lll 'ls -la'
end

set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

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
