<!-- resource_dir: /home/seonjunkim/.dotfiles/agents/skills/research/literature-search/pdf-finder -->

# PDF Finder

Find and download PDF papers from multiple open access sources.

## Definition

- **ID**: pdf-finder
- **Type**: Command
- **Author**: Research Skills
- **Description**: Locate and download papers from Zotero, Unpaywall, Semantic Scholar, and arXiv

## Commands

### Find by DOI
```
/pdf-finder "10.1145/3706598.3714033"
```
Find PDF source for a paper by DOI.

### Download
```
/pdf-finder --doi "10.1145/3706598.3714033" --download /path/to/papers
```
Download PDF to specified directory.

### Find by Zotero Key
```
/pdf-finder --key ZOTERO_KEY
```
Find PDF for an item already in your Zotero library.

### Batch Processing
```
/pdf-finder --batch dois.txt --download /path/to/papers
```
Process multiple DOIs from a file.

## Requirements

- Python 3.10+
- `requests>=2.31.0`, `httpx>=0.25.0`
- Optional: `pymupdf>=1.24.0` for PDF parsing
- Optional: Zotero desktop app for local lookups

## Setup

1. Install as part of skills-research:
   ```bash
   cd ~/.claude/skills/skills-research
   ```

2. Configure credentials:
   ```bash
   cd literature-search/pdf-finder
   cp .env.example .env
   nano .env  # Set UNPAYWALL_EMAIL
   ```

## Environment Variables

- `UNPAYWALL_EMAIL` - Email for Unpaywall API (any valid email works)
- `ZOTERO_USER_ID`, `ZOTERO_API_KEY` - Zotero credentials (inherited if set)

## Sources (Priority Order)

1. **Zotero** (local library if Zotero app running)
2. **Unpaywall** (open access via institutional repositories)
3. **Semantic Scholar** (author preprints)
4. **arXiv** (preprint server)

## Examples

```
/pdf-finder "10.1145/3706598"
/pdf-finder "10.1145/3706598" --download ~/Papers
/pdf-finder --key ABC123DEF --json
/pdf-finder --batch papers_to_find.txt --download ~/Papers
/pdf-finder "10.1145/3706598" --parse-after --output-dir ~/Papers/sections
```

## Notes

- Respects rate limiting of all APIs
- Fails gracefully if PDF not found (returns source information)
- Can parse downloaded PDFs into per-section markdown files
