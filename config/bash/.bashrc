# i love fish
if [ "$SSH_TTY" ]
then
	[ -x "$(command -v fish)" ] && exec fish "$@"
fi
