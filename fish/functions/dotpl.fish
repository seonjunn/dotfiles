function dotpl
	set repo ~/.dotfiles
	set before (git -C $repo rev-parse HEAD)
	git -C $repo pull; or return $status
	if git -C $repo diff --name-only $before HEAD | string match -q 'setup.sh'
		touch $repo/.setup-needed
		echo "setup.sh changed — re-run ~/.dotfiles/setup.sh"
	end
end
