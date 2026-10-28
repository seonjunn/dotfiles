# arxiv-mcp-server

The version lives in infra `data/uv-tools.toml`. This requirements file pins all
transitive dependencies and wheel hashes for uv on Linux and macOS. Regenerate
it with `uv pip compile --universal --generate-hashes --output-file requirements.txt
requirements.in` after changing the root version, then test both platforms.

Home Manager's `uv-locked.py` installs a new versioned environment and changes
the command link after it works. Running MCP processes keep their old environment.
The container without Home Manager uses the same script and lock directly.
