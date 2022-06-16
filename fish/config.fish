if status is-interactive
end

# Mute fish greeting
set fish_greeting

# plugins
#zoxide init fish | source

# abbr
abbr -a v "vim"
abbr -a py "python3"

if command -v exa > /dev/null
	abbr -a l   'exa -l'
	abbr -a ls  'exa'
	abbr -a ll  'exa -l'
	abbr -a lla 'exa -la'
else
	abbr -a l   'ls'
	abbr -a ll  'ls -l'
	abbr -a la  'ls -a'
	abbr -a lla 'ls -la'
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# <<< conda initialize <<<


# Generated for envman. Do not edit.
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"

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
