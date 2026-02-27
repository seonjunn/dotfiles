function fish_prompt
	set_color 999
	echo -n "["(date "+%H:%M:%S")"] "
	set_color white
	echo -n (whoami)
	set_color brwhite
	echo -n "."
	set_color green
	echo -n (string replace -- '.local' '' (hostname))
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
