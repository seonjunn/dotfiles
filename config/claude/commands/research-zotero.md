<!-- resource_dir: ~/.dotfiles/config/agents/skills/research/zotero-integration/zotero -->

# Zotero API

Query and manage your Zotero library via the HTTP API and local database.

## Definition

- **ID**: zotero
- **Type**: Command
- **Author**: Research Skills
- **Description**: Search, add, update, and manage items in your Zotero library via Web API and local database

## Commands

### Search
```
/zotero search "query text"
```
Search for items in your library by title, author, or keywords.

### Get Items
```
/zotero items [limit]
```
Fetch recent items from your library (default limit: 10).

### Collections
```
/zotero collections
```
List all collections in your library.

### Add Item by DOI
```
/zotero add-doi "10.1145/3706598.3714033" [collection] [tags]
```
Create a new item from a DOI with optional collection and tags.

### Get PDF
```
/zotero pdf <item-key>
```
Get the PDF path for a Zotero item (if available locally).

### Export
```
/zotero export [format]
```
Export items in BibTeX, RIS, CSL-JSON, or other formats.

## Requirements

- Claude Code CLI
- Python 3.10+
- `httpx>=0.25.0`
- Zotero Web API credentials (or Zotero desktop app running for local API)

## Setup

1. Clone the skills repository:
   ```bash
   cd ~/.claude/skills/
   git clone https://github.com/dostos/skills-research
   ```

2. Configure Zotero credentials:
   ```bash
   cd skills-research/zotero-integration/zotero
   cp .env.example .env
   nano .env  # Add your credentials
   ```

3. Get your Zotero credentials from https://www.zotero.org/settings/keys

## Environment Variables

- `ZOTERO_USER_ID` - Your numerical Zotero user ID
- `ZOTERO_API_KEY` - Your Zotero API key

The skill will also try to load credentials from `~/.zshrc` if environment variables are not set.

## Examples

```
/zotero search "machine learning"
/zotero collections
/zotero add-doi "10.1145/3145816"
/zotero export bibtex
/zotero items 25
```

## Notes

- Credentials can be provided via environment variables, `.env` file, or `~/.zshrc`
- Local database lookups are faster but require Zotero desktop app
- Web API works from anywhere with internet connection
