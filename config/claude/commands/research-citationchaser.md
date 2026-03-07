<!-- resource_dir: /Users/seonjunkim/.dotfiles/config/agents/skills/research/literature-search/citationchaser -->

# Citation Chaser

Perform forward and backward citation chasing for systematic literature reviews.
Source: https://github.com/nealhaddaway/citationchaser

## Definition

- **ID**: citationchaser
- **Type**: Command
- **Author**: Research Skills
- **Description**: Find papers that cite a seed paper (forward) or papers it cites (backward)

## Commands

### Backward Citation Chasing
```
/citationchaser backward "10.1145/1234567"
```
Find all papers referenced by the given paper.

### Forward Citation Chasing
```
/citationchaser forward "10.1145/1234567"
```
Find all papers that cite the given paper.

### Export to RIS
```
/citationchaser forward "10.1145/1234567" --export citations.ris
```
Export results in RIS format for import to Zotero/EndNote.

## Requirements

- Python 3.10+
- Web browser or curl (for accessing Lens.org)
- No API keys needed (web-based, uses Lens.org)

## Setup

1. Install as part of skills-research:
   ```bash
   cd ~/.claude/skills/skills-research/literature-search/citationchaser
   ```

## DOI Formats Supported

- DOI: `10.1145/3706598`
- DOI with prefix: `https://doi.org/10.1145/3706598`
- PMID: `12345678`

## Examples

```
/citationchaser backward "10.1145/3706598"
/citationchaser forward "doi:10.1145/3706598"
/citationchaser backward "10.1145/3706598" --export backward_refs.ris
/citationchaser forward "PMID:12345678"
```

## Workflow for Systematic Reviews

1. **Find seed papers** in your literature (e.g., highly cited)
2. **Backward chasing**: Find all papers they cite
3. **Forward chasing**: Find all papers citing them
4. **Export to RIS**: Import results to Zotero for screening
5. **Use ris-to-zotero** skill to import to collection

## Notes

- Lens.org is a free web-based citation index
- No rate limiting issues (reasonable usage)
- RIS export is compatible with Zotero, Mendeley, EndNote
- Best used as part of systematic review workflow with ris-to-zotero
