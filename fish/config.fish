# Fish

set fish_greeting
fish_vi_key_bindings


# Local Environment

if test -f $HOME/.env
	source $HOME/.env
end


# Core Environment

set -l _os (uname)
set -gx PATH $HOME/.dotfiles/bin $PATH
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/bin $PATH
if test -d $HOME/.cargo
	set -gx PATH $HOME/.cargo/bin $PATH
end
if test -d $HOME/.nvm
	set -gx NVM_DIR $HOME/.nvm
	set -l _ver (string trim (cat "$NVM_DIR/alias/default" 2>/dev/null))
	while test -f "$NVM_DIR/alias/$_ver"
		set _ver (string trim (cat "$NVM_DIR/alias/$_ver"))
	end
	if test -d "$NVM_DIR/versions/node/$_ver"
		set -gx PATH "$NVM_DIR/versions/node/$_ver/bin" $PATH
	end
end
if test $_os = Darwin
	if test -d /opt/homebrew/bin
		fish_add_path /opt/homebrew/bin
	end
	if test -d /opt/zerobrew/prefix/bin
		fish_add_path /opt/zerobrew/prefix/bin
	end
end
set -gx EDITOR vim
set -gx TERM xterm-256color
set -Ux LANG en_US.UTF-8
set -Ux LC_ALL en_US.UTF-8

# Alias

alias mv	"mv -iv"
alias cp	"cp -riv"
alias rm	"rm -Iv"
alias mkdir	"mkdir -vp"


# Abbreviation

abbr -a dotsetup	"$HOME/.dotfiles/setup.sh"
abbr -a sfish	"source $HOME/.config/fish/config.fish"
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

if command -q ccs
	abbr -a cld	"ccs"
	abbr -a clds	"ccs auth default (ccs-lru-account)"
  abbr -a cldr  "ccs --resume"
  abbr -a cldd  "ccs --dangerously-skip-permissions"
  abbr -a cldrd "ccs --resume --dangerously-skip-permissions"
else if command -q claude
	abbr -a cld	"claude"
end

if command -q docker
	abbr -a dk	"docker"
end

if command -q tmux
	abbr -a tm	"tmux"
	abbr -a tma	"tmux attach"
	abbr -a tml	"tmux ls"
end

if command -q adb
	abbr -a add	"adb devices"
	abbr -a adp	"adb pair"
	abbr -a adc	"adb connect"
	abbr -a adsh	"adb shell"
	set -gx ANDROID_ADB_SERVER_PORT 5307
end

if command -q python3
	abbr -a py	"python3"
	abbr -a pip	"python3 -m pip"
end

if command -q eza
	abbr -a l	"eza -l -s type"
else
	abbr -a l	"ls -l"
end


# Util

# Dotfiles auto-update
if status is-interactive; and set -q SSH_CONNECTION
	echo (date '+%F %T') "ssh+interactive: invoking dotpl" >> ~/.dotfiles/.dotpl.log
	bash -c 'fish -c dotpl > /dev/null 2>&1 & disown' 2>/dev/null
	if test -f ~/.dotfiles/.setup-needed
		echo "dotfiles: setup.sh changed — run dotsetup (or ~/.dotfiles/setup.sh)"
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
