dotfiles go brrr

## starting fresh (again)

if you can be a sudoer:
```sh
curl -fsSL https://raw.githubusercontent.com/seonjunn/dotfiles/master/setup.sh | sudo bash
```

if you can't be a sudoer:
```sh
curl -fsSL https://raw.githubusercontent.com/seonjunn/dotfiles/master/setup.sh | bash
```

to run only specific modules (prefix-matched):
```sh
bash setup.sh dot cl        # dotfiles + claude
bash setup.sh --list        # show available modules
bash setup.sh --dry-run     # print commands without running
```

## with home manager

`homeModules.base` (`nix/home/`) sets up the same shell, tools, git, ssh defaults, tmux/vim, node and
agent files declaratively. Defaults live in `nix/data/*.toml`; your own config imports the module and
adds identity, ssh hosts and extra packages through the usual Home Manager options:

```nix
inputs.dotfiles.url = "github:seonjunn/dotfiles";
# homeConfigurations.<you>.modules = [ dotfiles.homeModules.base ./me.nix ];
# me.nix: programs.git.settings.user = { name = "..."; email = "..."; };
```

on a machine with home manager, setup.sh leaves the files it owns alone and skips the package steps.

## useful stuff

- `dotsetup` — runs setup.sh (do this when it warns you to)
- `dotpl` — pull manually (usually not needed, happens on login)
