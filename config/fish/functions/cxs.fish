# Codex under a `ccsx auth` profile, used like `ccs <account> --resume`:
#   cxs                     default profile (change it with `ccsx auth switch <name>`)
#   cxs work                that profile
#   cxs work --resume       resume picker in that profile (`codex resume`)
#   cxs --yolo ...          every other option goes to codex unchanged
# `ccsx <profile>` itself fails in CCS 8.11 while the CCS default is a Claude
# account, so the profile is handed over through CCS_CODEX_PROFILE instead.
function cxs --description 'run Codex under a ccsx profile'
	set -l profile
	if set -q argv[1]; and test -d $HOME/.ccs/codex-instances/$argv[1]
		set profile $argv[1]
		set -e argv[1]
	end

	if set -l i (contains -i -- --resume $argv)
		set -e argv[$i]
		set argv resume $argv
	end

	if test -n "$profile"
		CCS_CODEX_PROFILE=$profile ccsx $argv
	else
		ccsx $argv
	end
end
