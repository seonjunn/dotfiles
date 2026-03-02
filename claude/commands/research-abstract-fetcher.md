<!-- resource_dir: /home/seonjunkim/.dotfiles/agents/skills/research/literature-search/abstract-fetcher -->

# Abstract Fetcher

Fetch paper abstracts from multiple open access sources.

## Definition

- **ID**: abstract-fetcher
- **Type**: Command
- **Author**: Research Skills
- **Description**: Retrieve abstracts from Semantic Scholar, OpenAlex, and web search

## Commands

### Single DOI
```
/abstract-fetcher fetch "10.1145/1234567"
```
Get abstract for a single paper.

### Batch Processing
```
/abstract-fetcher batch input.json output.json
```
Process multiple DOIs from JSON file.

### Check Status
```
/abstract-fetcher status results.json
```
Check success/failure statistics for batch run.

## Requirements

- Python 3.10+
- `requests>=2.31.0`
- No API keys needed (uses public APIs)

## Setup

1. Install as part of skills-research:
   ```bash
   cd ~/.claude/skills/skills-research/literature-search/abstract-fetcher
   ```

2. Configure (optional):
   ```bash
   cp .env.example .env
   ```

## Environment Variables

- `ABSTRACT_FETCHER_DELAY` - Rate limiting delay (optional, defaults to 0.5s)

## Sources (Cascading Order)

1. **Semantic Scholar API** - Most complete abstracts
2. **OpenAlex API** - Fallback with good coverage
3. **Web Search** - Last resort for rare papers

## Examples

```
/abstract-fetcher fetch "10.1145/3706598"
/abstract-fetcher batch dois.json abstracts.json
/abstract-fetcher status abstracts.json
```

## Input Format (for batch)

```json
[
  {"doi": "10.1145/3706598"},
  {"doi": "10.1145/3145816"}
]
```

## Output Format

```json
[
  {
    "doi": "10.1145/3706598",
    "abstract": "Abstract text...",
    "source": "semantic_scholar"
  }
]
```

## Notes

- Automatic rate limiting to avoid hitting API limits
- Gracefully handles missing abstracts
- Batch processing with progress reporting
