if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

export PATH="$HOME/.local/bin:$PATH"

alias vim "nvim"
alias :q "exit"
alias :wq "exit"

# apt
abbr sai "sudo apt install"

# git
abbr ga     "git add ."
abbr gb     "git branch"
abbr gcm    "git commit -m"
abbr gps     "git push"
abbr gpl     "git pull"
abbr gco    "git checkout"
abbr gd     "git diff"
abbr gl     "git log --branches --graph --decorate --oneline"
abbr gst    "git status"

if command -v exa > /dev/null
	abbr -a l   'exa -l -s type'
else
    abbr -a l   'ls'
end
abbr -a ll  'ls -l'
abbr -a lll 'ls -la'

# fzf key bindings
fzf_key_bindings

function fish_prompt
	set_color 999
	echo -n "["(date "+%H:%M")"] "

	set_color white 
    echo -n (whoami)

	set_color brwhite 
    echo -n "."

	set_color white
    echo -n (hostname) | sed 's/.local//'
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color 6fa
		echo -n (basename $PWD)
	end
	set_color f8a
	printf '%s ' (__fish_git_prompt)
	set_color brcyan
	echo -n '~>'
    set_color -b normal
    echo -n ' '
	set_color normal
end

export TERM=xterm-256color
