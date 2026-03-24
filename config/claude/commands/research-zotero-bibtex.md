<!-- resource_dir: ~/.dotfiles/config/agents/skills/research/zotero-integration/zotero-bibtex -->

# Zotero BibTeX Extractor

Extract BibTeX entries directly from your local Zotero SQLite database.

## Definition

- **ID**: zotero-bibtex
- **Type**: Command
- **Author**: Research Skills
- **Description**: Fast BibTeX extraction from local Zotero database without API calls

## Commands

### By DOI
```
/zotero-bibtex --doi "10.1145/1234567"
```
Get BibTeX entry for a specific DOI.

### By Title
```
/zotero-bibtex --search "keywords"
```
Search for items by title and export as BibTeX.

### By Collection
```
/zotero-bibtex --collection "Collection Name"
```
Export all items from a collection as BibTeX.

## Requirements

- Zotero desktop app (for local database access)
- Python 3.10+
- No external dependencies

## Setup

1. Install as part of skills-research repository:
   ```bash
   cd ~/.claude/skills/skills-research
   ```

2. Configure database path (optional):
   ```bash
   cd zotero-integration/zotero-bibtex
   cp .env.example .env
   nano .env  # Set ZOTERO_DB_PATH if non-standard location
   ```

## Environment Variables

- `ZOTERO_DB_PATH` - Path to your Zotero database (defaults to `~/Zotero/zotero.sqlite`)

## Examples

```
/zotero-bibtex --doi "10.1145/3145816"
/zotero-bibtex --search "neural networks"
/zotero-bibtex --collection "My Research" --out references.bib
```

## Notes

- Much faster than Web API since it queries SQLite directly
- Requires Zotero app to have indexed the database
- Works offline once Zotero database is synced
