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

## useful stuff

- `dotsetup` — runs setup.sh (do this when it warns you to)
- `dotpl` — pull manually (usually not needed, happens on login)
