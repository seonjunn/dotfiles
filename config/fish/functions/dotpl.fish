function dotpl
	set repo ~/.dotfiles
	set log $repo/.dotpl.log
	set before (git -C $repo rev-parse HEAD)
	if not git -C $repo pull 2>> $log
		# dotpl runs detached with output discarded, so a failure is invisible
		# unless it leaves a flag behind for the next login shell to report.
		touch $repo/.dotpl-failed
		echo (date '+%F %T') "pull failed" >> $log
		return 1
	end
	rm -f $repo/.dotpl-failed
	if git -C $repo diff --name-only $before HEAD | string match -rq '^setup\.sh$|^bootstrap/'
		touch $repo/.setup-needed
		echo "setup changed — re-run dotsetup (or ~/.dotfiles/setup.sh)"
		echo (date '+%F %T') "setup changed, flag set" >> $log
	else
		echo (date '+%F %T') "ok" >> $log
	end
end
