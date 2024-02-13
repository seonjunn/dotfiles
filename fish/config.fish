# Fish

set fish_greeting
fish_vi_key_bindings


# Path

if test -d $HOME/.cargo
	export PATH="$HOME/.cargo/bin:$PATH"
end

# Alias 

alias mv	"mv -iv"
alias cp	"cp -riv"
alias rm	"rm -Iv"
alias mkdir	"mkdir -vp"


# Abbreviation

abbr -a sfish	"source $HOME/.config/fish/config.fish"
abbr -a vfish	"vim $HOME/.config/fish/config.fish"

if command -q git
	abbr -a ga	"git add"
	abbr -a gb	"git branch"
	abbr -a gcm	"git commit"
	abbr -a gps	"git push"
	abbr -a gpl	"git pull"
	abbr -a gco	"git checkout"
	abbr -a gd	"git diff"
	abbr -a gl	"git log --branches --graph --decorate --oneline"
	abbr -a gst	"git status"
	abbr -a gcl	"git clone"
end

if command -q docker
	abbr -a dk	"docker"
end

if command -q adb
	abbr -a add	"adb devices"
	abbr -a adp	"adb pair"
	abbr -a adc	"adb connect"
	abbr -a adsh	"adb shell"
end

if command -q exa
	abbr -a l	"exa -l -s type"
else
	abbr -a l	"ls -l"
end


# Util 

if type -q fzf_key_bindings
	fzf_key_bindings
end
	

if command -q zoxide
	zoxide init fish | source
end
