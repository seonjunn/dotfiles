function open --description 'open with default app, detached from terminal'
    if test (count $argv) -eq 0
        set argv .
    end
    for target in $argv
        setsid -f xdg-open $target >/dev/null 2>&1 </dev/null
    end
end
