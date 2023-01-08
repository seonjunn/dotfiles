if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Mute fish greeting
set fish_greeting

# lang as eng
export LC_ALL=C

# PATHS
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:/Applications/kitty.app/Contents/MacOS:$HOME/.local/bin"
eval (/opt/homebrew/bin/brew shellenv)
export SHELL=(which fish)
#export PATH="$HOME/Library/Python/3.8/bin:$PATH"
export PATH="$HOME/.android/platform-tools:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/bin:$PATH"

export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-18.jdk/Contents/Home

# Plugins
zoxide init fish | source

# alias
alias vim "nvim"

# abbr
abbr py     "python3"

abbr ga     "git add ."
abbr gb     "git branch"
abbr gcm    "git commit"
abbr gps     "git push"
abbr gpl     "git pull"
abbr gco    "git checkout"
abbr gd     "git diff"
abbr gl     "git lg"
abbr gst    "git status"

if command -v exa > /dev/null
	abbr -a l   'exa -l'
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
#
# Hishtory Config:
#export PATH="$PATH:/Users/sk1m/.hishtory"
#source /Users/sk1m/.hishtory/config.fish

# fzf
fzf_key_bindings
