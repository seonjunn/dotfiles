<!-- resource_dir: /home/seonjunkim/.dotfiles/agents/skills/research/literature-search/citation-verifier -->

# Citation Verifier

Verify and fix BibTeX citations against authoritative DOI and CrossRef metadata.

## Definition

- **ID**: citation-verifier
- **Type**: Command
- **Author**: Research Skills
- **Description**: Validate BibTeX entries, detect mismatches, and auto-correct

## Commands

### Verify Bibliography
```
/citation-verifier reference.bib
```
Check all citations for metadata mismatches.

### Generate Report
```
/citation-verifier reference.bib --out report.json
```
Output detailed verification report as JSON.

### Auto-Correct
```
/citation-verifier reference.bib --fix all --out fixed.bib
```
Automatically correct all detected issues.

## Requirements

- Python 3.10+
- `httpx>=0.25.0`
- No API keys needed (uses public CrossRef API)

## Setup

1. Install as part of skills-research:
   ```bash
   cd ~/.claude/skills/skills-research/literature-search/citation-verifier
   ```

## Check Types

Verifies against CrossRef metadata:
- ✓ Title matches
- ✓ Author names
- ✓ Publication year
- ✓ Venue/Journal name
- ✓ DOI validity

## Examples

```
/citation-verifier references.bib
/citation-verifier references.bib --out verification_report.json
/citation-verifier references.bib --fix all --out fixed_references.bib
/citation-verifier references.bib --interactive
```

## Output (Report)

```json
{
  "total": 50,
  "valid": 45,
  "warnings": 3,
  "errors": 2,
  "entries": [
    {
      "key": "smith2020",
      "status": "warning",
      "issues": ["Title mismatch", "Missing DOI"],
      "suggestion": "@article{smith2020, ... DOI={10.1145/1234567}}"
    }
  ]
}
```

## Notes

- Essential before submitting papers to journals
- Catches common BibTeX formatting errors
- Ensures DOI links work correctly
- Can be used in CI/CD pipelines
- Pairs well with zotero-bibtex for quality control
