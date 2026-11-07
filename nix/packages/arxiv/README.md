# arxiv-mcp-server

The root version is pinned in `requirements.in`; `requirements.txt` pins all
transitive dependencies and wheel hashes for uv on Linux and macOS. Regenerate
it with `uv pip compile --universal --generate-hashes --output-file requirements.txt
requirements.in` after changing the root version, then test both platforms.
A Home Manager config passes the version again (`dotfiles.uv.lockedTools`); keep
the two equal.

`nix/home/uv-locked.py` installs a new versioned environment and changes the
`~/.local/bin/arxiv-mcp-server` link after it works. Running MCP processes keep
their old environment. Home Manager runs it on each switch (`nix/home/uv.nix`);
setup.sh runs it on machines without Home Manager (`install_shared_mcp_servers`).
Claude Code and Codex start that command, never `uvx`, which would prefer an
older `uv tool install` copy.
