# Fish

set fish_greeting
fish_vi_key_bindings


# Local Environment

if test -f $HOME/.env
	source $HOME/.env
end


# Core Environment

set -l _os (uname)
fish_add_path -g $HOME/.dotfiles/bin
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/bin
if test -d $HOME/.cargo
	fish_add_path -g $HOME/.cargo/bin
end
if test -d $HOME/.nvm
	set -gx NVM_DIR $HOME/.nvm
	set -l _ver (string trim (cat "$NVM_DIR/alias/default" 2>/dev/null))
	while test -f "$NVM_DIR/alias/$_ver"
		set _ver (string trim (cat "$NVM_DIR/alias/$_ver"))
	end
	if test -d "$NVM_DIR/versions/node/$_ver"
		fish_add_path -g "$NVM_DIR/versions/node/$_ver/bin"
	end
end
if test $_os = Darwin
	if test -d /opt/homebrew/bin
		fish_add_path -g /opt/homebrew/bin
	end
end
set -gx EDITOR vim
set -gx TERM xterm-256color
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Abbreviation
# mv/cp/rm/mkdir are abbrs, not aliases: an alias is a function, so fish's own code and scripts would get -v/-i too.

abbr -a mv	"mv -iv"
abbr -a cp	"cp -riv"
abbr -a rm	"rm -Iv"
abbr -a mkdir	"mkdir -vp"
abbr -a vfish	"vim $HOME/.config/fish/config.fish"
if test $_os != Darwin
	abbr -a sai "sudo apt install"
end

if command -q git
	abbr -a ga	"git add"
	abbr -a gb	"git branch"
	abbr -a gcm	"git commit -m"
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
	set -gx ANDROID_ADB_SERVER_PORT 5037
	set -gx ADB_SERVER_PORT 5037
end

if command -q eza
	abbr -a l	"eza -l -s type"
else
	abbr -a l	"ls -l"
end

abbr -a rp "realpath"

# Util

# Dotfiles auto-update
if status is-interactive; and set -q SSH_CONNECTION
	echo (date '+%F %T') "ssh+interactive: invoking dotpl" >> ~/.dotfiles/.dotpl.log
	bash -c 'fish -c dotpl > /dev/null 2>&1 & disown' 2>/dev/null
	if test -f ~/.dotfiles/.setup-needed
		echo "dotfiles: setup.sh changed — run ~/.dotfiles/setup.sh"
	end
	if test -f ~/.dotfiles/.dotpl-failed
		echo "dotfiles: auto-pull is failing — see ~/.dotfiles/.dotpl.log"
	end
end

if command -q fzf
  if fzf --fish >/dev/null 2>/dev/null
    fzf --fish | source
  else if functions -q fzf_key_bindings
    # Older fzf releases expose fish integration via this function.
    fzf_key_bindings
  end
end

if command -q zoxide
	zoxide init fish | source
end

