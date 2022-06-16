if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Mute fish greeting
set fish_greeting

# paths
export PATH="$HOME/.local/bin:$PATH"

# abbr
abbr py     "python3"

abbr ga     "git add ."
abbr gcm    "git commit"
abbr gps    "git push"
abbr gpl    "git pull"
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

set __fish_git_prompt_show_informative_status

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
