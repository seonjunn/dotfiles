<!-- resource_dir: /home/seonjunkim/.dotfiles/agents/skills/research/conversion-utilities/ris-to-zotero -->

# RIS to Zotero Importer

Import bibliography files in RIS format to your Zotero library with automatic DOI enrichment.

## Definition

- **ID**: ris-to-zotero
- **Type**: Command
- **Author**: Research Skills
- **Description**: Import RIS files to Zotero collections with DOI lookup and deduplication

## Commands

### Basic Import
```
/ris-to-zotero citations.ris
```
Import all RIS entries to your Zotero library.

### Import to Collection
```
/ris-to-zotero citations.ris --collection COLLECTION_KEY
```
Add imported items to a specific collection.

### Add Tags
```
/ris-to-zotero citations.ris --tag "systematic-review" --tag "2026"
```
Tag all imported items.

### Batch Import
```
/ris-to-zotero citations.ris --collection KEY --batch-size 25
```
Control import batch size (pauses between batches).

## Requirements

- Python 3.10+
- `httpx>=0.25.0`
- Zotero Web API credentials
- RIS format bibliography files

## Setup

1. Install as part of skills-research:
   ```bash
   cd ~/.claude/skills/skills-research/conversion-utilities/ris-to-zotero
   ```

2. Configure credentials:
   ```bash
   cp .env.example .env
   nano .env  # Set ZOTERO_USER_ID and ZOTERO_API_KEY
   ```

## Environment Variables

- `ZOTERO_USER_ID` - Your Zotero user ID
- `ZOTERO_API_KEY` - Your Zotero API key

## RIS Format

Standard RIS bibliography format (exported by most academic databases):
```
TY  - JOUR
TI  - Paper Title
AU  - Author Name
PY  - 2023
JF  - Journal Name
DO  - 10.1145/1234567
AB  - Abstract text...
ER  -
```

## Typical Workflow

1. **Export from database** (PubMed, IEEE Xplore, Semantic Scholar, etc.)
   - Select papers → Export as RIS

2. **Import to Zotero**:
   ```bash
   /ris-to-zotero results.ris --collection RESEARCH_PROJECT --tag "needs-screening"
   ```

3. **Verify in Zotero**:
   - Check imported items in collection
   - DOI automatically looked up for items with missing metadata

4. **Use with citation-chaser**:
   - Export backward/forward citations as RIS
   - Import the results using this skill

## Examples

```
/ris-to-zotero search_results.ris
/ris-to-zotero citations.ris --collection ABC123DEF
/ris-to-zotero results.ris --tag "slr-2026" --tag "draft"
```

## Output

```
Importing 42 unique DOIs...
✓ Success: 38
✗ Failed: 2 (duplicate DOI)
⊘ Skipped: 2 (no DOI found)
```

## Notes

- Deduplicates by DOI automatically
- Pauses between batches to respect API rate limits
- Failed imports show specific error reasons
- Works with RIS files from any academic database
- Pairs with citationchaser for snowballing literature searches
