if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Mute fish greeting
set fish_greeting

# lang as eng
export LANG=en_US.UTF-8
export LC_ALL=C
export LC_CTYPE=en_US.UTF-8

# PATHS
export SHELL=(which fish)
export PATH="$HOME/.cargo/bin:$PATH"
export NVM_DIR="$HOME/.nvm"

# alias
alias	vim	"nvim"
alias	timeout	"gtimeout"

# abbr
abbr	py	"python3"

# git
abbr	ga	"git add ."
abbr	gb     	"git branch"
abbr 	gcm    	"git commit"
abbr 	gps	"git push"
abbr 	gpl	"git pull"
abbr 	gco	"git checkout"
abbr 	gd	"git diff"
abbr 	gl     	"git lg"
abbr 	gst    	"git status"

# lazygit
abbr	lg	"lazygit"

# cargo
abbr	cr	"cargo run"
abbr	cb	"cargo build"

if command -v exa > /dev/null
	abbr -a l   'exa -l --icons'
else
	abbr -a l   'ls'
end
#if git rev-parse --is-inside-work-tree &> /dev/null
#	abbr -a ll 'exa -l --git --icons'
#end

set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

function fish_prompt
	set_color aaa
	echo -n "["(date "+%H:%M")"] "

	set_color 3bb 
    	echo -n (whoami)

	set_color bbb 

	set_color b6b 
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

# fzf
fzf_key_bindings

# Setting PATH for Python 3.11
# The original version is saved in /Users/seonjunkim/.config/fish/config.fish.pysave
set -x PATH "/Library/Frameworks/Python.framework/Versions/3.11/bin" "$PATH"


# zoxide setting
zoxide init fish | source
