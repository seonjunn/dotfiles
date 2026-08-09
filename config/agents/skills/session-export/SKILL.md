---
name: session-export
description: Export a conversation into a set of handoff documents — an index plus topic documents plus a discard log — complete enough that a future Claude session with zero prior context can load them and continue the work. Use whenever the user asks to export, 내보내, 정리해서 문서로, 세션 정리, 이거 문서화해줘, wrap up this session, save this conversation, hand it off to the next session, or write up what we did here. Trigger even when the request is one casual word ("export", "정리해줘") and even when the conversation seems small enough to summarize directly — this skill exists because one-shot summaries silently drop constraints, corrections, and abandoned paths, and it defines the inventory, invalidation, and multi-pass verification rules that prevent that.
---

# Session Export

Turn a conversation into a document set that **a fresh Claude session, holding zero prior context, can load and immediately continue the work from**.

The export covers the conversation up to the point this skill is invoked — not necessarily the end of a session. It may be run several times as work develops, and each run produces a complete set rather than a delta.

That reader is the design constraint behind every rule here. It has no memory of the session. It cannot ask what "that approach" referred to. It will act on whatever the documents say and will not know what they left out. So:

- nothing load-bearing may be missing,
- nothing abandoned may read as still live,
- nothing speculative may read as established.

The failure this skill prevents is not "the summary was too short." It is "weeks later the work was redone, because a constraint, a number, or a already-rejected path was never written down."

## Output

The export produces **exactly one session directory and nothing else**. It does not create, name, or assume the layout of anything around it. The output is a plain directory of markdown files — it may end up in a note vault, a repo, a synced folder, or a directory someone opens files from later, so emit nothing tool-specific.

```
<working directory name>/
├── index.md                 entry point
├── 01-<topic>.md            body; usually just one (see Phase 2)
└── discarded.md             every decision that was reversed or abandoned
```

**The directory name carries no meaning and must not be relied on.** The user, or tooling acting for them, will name and place the directory; downloads may arrive flattened anyway. Give it a plain descriptive working name and put nothing in it that is not also inside `index.md`.

**`index.md` records the export timestamp — date and time — and the topic.** These are what identify one export against another, including two exports of the same work an hour apart, which is why they live in the file rather than in a folder name that will be replaced.

**Cross-references use plain filenames** — `01-gather-optimization.md`, or "the Speedup estimate section of `01-gather-optimization.md`". No wikilinks, no relative paths, no syntax that assumes a particular tool. These files might be opened in an editor, pasted into a chat, or read by a script; plain names work in all three and degrade into readable text when they resolve to nothing.

**`index.md` carries the one-line summary, the document map, and short global aids for reading the set** — a glossary of project-specific vocabulary being the main one. The line to hold is between *decoding aids*, which belong in the index because they serve every document, and *substance* — current state, decisions, open threads, constraints — which lives in the body documents and is only pointed to from the index. Without that line the index reabsorbs the whole export and drifts out of sync with it.

Write the summary so it names both what got settled and what is still open. It is the line a person scans to decide whether this is the export they want, and it is what they copy into whatever list of sessions they keep elsewhere.

**Each export is independently sufficient.** Exports repeat — later in the same session as things develop, and in later sessions on the same work. Whenever an earlier export exists, consult it freely, but restate whatever from it still matters instead of pointing back. Self-containedness wins over avoiding duplication. The invariant this buys is that the newest export is always enough on its own, which is what makes it safe for the user to delete, overwrite, or stack the older ones however they like. Note the superseded directory name in `index.md` for provenance, but never write a document that requires reading it. If there is no earlier export, omit the line rather than leaving a placeholder.

**Language**: keep *content* in whatever language the conversation used — including a mixed style such as Korean prose with English technical terms. Do not translate. Translation is restatement, and restatement is where invented claims and dropped hedges enter; a constraint or a correction the user stated in passing loses force in translation in ways that are hard to detect afterward. Technical terms, identifiers, and proper nouns stay in original form regardless.

Keep the *scaffolding* in English regardless of content language: section headings, status markers, index table columns, and the short imperative lines addressed to the receiving session. This keeps the skeleton identical across exports from different projects, and these are short fixed phrases with no translation loss.

If the user explicitly asks for the whole export in another language, comply — but preserve the original wording verbatim, as a quoted line beneath the translation, for constraints, corrections, and stated requirements. Those are the items where translation loss does real damage.

**Length**: uncapped. Completeness always beats brevity. But uncapped is not a license to pad — restating the same point three ways dilutes signal for the next session as badly as omitting it. The target is *nothing missing*, not *many words*.

## Environment

Resolve the destination before writing. The core of this skill — inventory, structure, verification, content rules — is identical everywhere; only where the files land and how they are handed over changes.

1. **The user named a path** → write there.
2. **The destination is reachable from this machine** (Claude Code, or Cowork with access to the folder) → create the directory there directly.
3. **No filesystem access to the destination** (web or mobile chat) → build the directory under `/mnt/user-data/outputs/` and hand it over with `present_files`.

**Do not write outside the session directory** in any environment, and do not name or place it. If the user keeps a list of past sessions, an overview, or any other cross-cutting file, it is theirs — the one-line summary in `index.md` is there for them or their tooling to pick up. Guessing at the name or format of a file you have not been shown, and editing it, is the kind of help that has to be undone.

### When the session ran in Claude Code

**Check whether the context was compacted.** Long coding sessions get summarized mid-flight, and a summary is exactly the lossy artifact this skill exists to prevent. If any part of the session is only available to you as a compaction summary, you cannot claim completeness for it. Say so explicitly, both in `index.md` under the summary and in the first body document — which stretch is affected, and that detail from it may be missing — and offer to re-export from a fuller transcript if the user can supply one. Silently exporting a compacted session as if it were complete is the worst failure available to this skill, because the resulting document looks exactly like a good one.

**Reference the repository instead of copying it.** For code that lives in a repo the user controls, record the path, the commit or branch, and *why it matters* — a pasted copy of a file that keeps changing goes stale without any signal. Keep verbatim copying for the snippets actually discussed in conversation, for anything not yet committed, and for code whose exact form was the subject of a decision.

## Process

Six phases. Do not skip the inventory (Phase 1) and do not collapse the verification cycles (Phases 4–6) into a single glance. Those are the parts that actually catch things.

### Phase 0 — Source and scope

Look for a raw transcript before falling back to memory. In web/mobile chat that is `/mnt/transcripts/`; in Claude Code it is the session's own JSONL under `~/.claude/projects/<slug>/`. If a transcript exists, that is the ground truth — read it, because the in-context view of a long conversation may be truncated. If there is none, work from the conversation in context.

Default scope is the whole conversation so far, from its start to the point of invocation. Only ask the user to narrow it if the session obviously contains two or more unrelated projects. Do not ask otherwise; asking is friction and the default is almost always right.

### Phase 1 — Inventory before writing

Walk the source **turn by turn, in order**, and build a raw ledger — `export-ledger.md` in a scratch location outside the session directory (`/home/claude/` in web/mobile chat, the session scratchpad in Claude Code) — before writing any document. This is the mechanism that makes completeness checkable instead of aspirational. Skipping it and writing straight from memory of the conversation is the single most common way this task fails.

For each item, record: a short id, the turn it came from, its type, and the content itself (verbatim where verbatim matters — see the content rules below).

Types worth separating:

| type | what it is |
|---|---|
| `decision` | something settled and acted on |
| `rejected` | something considered and dropped → goes to `discarded.md` |
| `constraint` | a requirement, limitation, or non-negotiable that shaped decisions |
| `fact` | verified information: measured results, confirmed behavior, things the user asserted about their world |
| `hypothesis` | proposed but unverified — including Claude's own suggestions |
| `open` | a question raised and not answered; a choice deferred |
| `artifact` | code, file, command, config, schema produced or referenced |
| `preference` | how the user wants things done (style, tools, conventions) |
| `rationale` | *why* something was chosen — often the highest-value item and the easiest to lose |

**The user's own turns are the highest-signal source.** Requirements dropped in passing, corrections to Claude, "아니 그게 아니라", stated preferences, and rejected suggestions carry information no amount of re-reading Claude's output recovers. Walk them with extra care.

### Phase 2 — Structure

Group ledger items into topic documents by **subject or work unit, never chronologically**. A chronological retelling forces the next session to reconstruct the current state by replaying history; a subject-organized document states it.

**Default to fewer files.** The only thing splitting buys a handoff is selective loading — the ability to work on one task without reading everything. If the whole export fits comfortably in context anyway, splitting buys nothing and costs cross-reference drift. Splitting because the material has several headings is not a reason; that is what headings are for.

The minimum viable set is `index.md` plus `discarded.md`, with the substance living in one body document. Add a second topic document only when both of these hold:

- the export is large enough that a future session would meaningfully avoid loading part of it (roughly: past 1,500–2,000 words of content), **and**
- the subjects are independent enough that a task would plausibly need one and not the other.

If a session covered two genuinely unrelated projects, split on that boundary regardless of size.

Then check the split against the ledger: every item has a destination, and nothing is duplicated across documents in a way that could drift out of sync.

**Watch for overloaded words in filenames and headings.** A cold reader resolves ambiguity by guessing, and guesses wrong. "Baseline" meaning both the current implementation and the comparison target is the kind of collision that only becomes visible in Phase 5 — catch it here instead.

### Phase 3 — Write

Write `index.md`, then the body document(s), then `discarded.md`. Apply the content rules below.

### Phase 4 — Verification cycle 1 (forward: source → documents)

Re-walk the source and map **every ledger item** to a specific file and section. Record the mapping — a table is fine — and treat any unmapped item as a finding: either add it, or move it to the discard log with its reason. "It seemed minor" is not a reason to drop something silently; minor details are frequently what carries nuance.

Also spot-check fidelity in this pass: numbers, code, commands, and names in the documents must match the source character for character.

### Phase 5 — Verification cycle 2 (reverse: cold read)

**Read only the produced documents. Do not look at the conversation during this pass.** Read as the future session would — no memory, no context. This catches a different class of defect than Phase 4, which is why it is a separate pass and why the direction matters.

Flag every instance of:

- a term, abbreviation, or project-specific name used but never defined,
- a reference with no antecedent ("the earlier approach", "as discussed", "the previous version"),
- a claim whose status is unclear — decided or proposed? measured or guessed?
- an instruction that cannot be acted on because a needed detail is absent,
- two documents that contradict each other,
- something stated as settled that the discard log also lists as dropped,
- **a statement you cannot trace to a specific turn** — if you cannot say where it came from, you invented it,
- **a summary or heading that asserts something the body marks as unverified**,
- **a relative time expression** ("next week", "later", "다음 주") left unanchored.

Then return to the source and resolve each flag.

### Phase 6 — Cycle 3, if warranted

Run a third pass only if cycle 2 produced substantive changes. Focus it on what changed, plus a re-check of two things that degrade easily: the open-threads list in the index, and the boundary between what is live and what is discarded.

**Stop condition**: a cycle yields only cosmetic edits.

**When the source is too large to re-walk in full**, do not quietly downgrade to a skim. Split it into sections, run the passes section by section, and record in the ledger which sections received which pass. Then state the coverage in `index.md`. A partial verification that is labelled is useful; one that is presented as complete is not.

Note that this skill usually runs late in a session, when the remaining context budget is at its smallest and the source at its longest. If it is clear you cannot hold source, ledger, and drafts at once, say so before starting rather than producing a confident-looking export built on a fading view of the conversation.

**Each cycle must leave a written findings list.** A pass that concludes "checked, nothing found" without an itemized record did not happen — that phrasing is the signature of a verification that was skipped. Note the findings in the ledger as you go.

Finally, hand the set over. If the directory was built under `/mnt/user-data/outputs/` (Environment case 3), call `present_files` with `index.md` first, then the rest, and tell the user the intended folder name in the chat response since the download may not preserve it. If it was written to a real path on this machine (cases 1 and 2), just state the path and list the files.

## Content rules

**Preserve verbatim; do not summarize:** code, formulas, numeric results, commands, file paths, error messages, configuration, identifiers, and the names of papers, APIs, libraries, and kernels. Summarizing these destroys the thing that makes them reusable. If a code block ran and mattered, it goes in whole.

**Mark only what is not settled.** Settled is the unmarked default — do not tag it. Tag only the two states a reader could act on wrongly:

- `[unverified]` — proposed but not tested; includes every suggestion Claude made that was never checked, and every estimate presented alongside real measurements
- `[open]` — unresolved, needs a decision

Marking everything defeats the purpose: when `[settled]` is on most lines, the eye stops registering markers and `[unverified]` disappears into the texture. Scarcity is what makes the tag do work. If it is genuinely ambiguous whether something was settled, that ambiguity is itself `[open]`.

Without this distinction a future session cites a guess as a finding. That is the most damaging error the export can produce, because it is invisible downstream.

**Include conversational history only when the path itself carries information the endpoint does not.** Worth keeping: an approach was tried and failed (so it is not retried), a requirement surfaced through a correction, a constraint emerged from a misunderstanding. Not worth keeping: how the conversation arrived at an answer that stands on its own. Default to the endpoint; keep the path when the path is the point.

**Include a detail when acting without it could produce a wrong move.** That is the operational test — not "does it feel important." Fine-grained details that carry nuance about *why* something is the way it is qualify.

**The set must be self-contained.** An arbitrary new session, given these files and nothing else, must be able to acquire what it needs from them alone. It cannot open the original conversation, follow a link out, or ask what something meant. So: define every project-specific name at first use, spell out what an external tool or file is when you mention it, and never let a claim rest on something the reader cannot see. The test is not "would the user understand this" — the user was there. It is "would a stranger with the relevant technical background be able to act on this."

**Individual documents do not need to stand alone** — the set is delivered and read as a whole. So state each thing exactly once, in one place, and let `index.md` say where it is. Repeating material across documents to make each one independently complete buys nothing here and costs drift: two copies of a constraint become two different constraints the moment one is edited.

**Every document points back to the index.** One line at the top — that `index.md` holds the map and the glossary — so the set can be traversed from any file, not only downward from the index.

**Non-text artifacts need a text handle.** Diagrams, images, charts, and rendered outputs produced during the session do not survive into a markdown handoff. Record what each one showed and what it was for, in words, and note that the original is not included. A future session cannot open an image it was never given, but it can act on a description of what the image established.

**Write only what the session contains.** Do not add options, alternatives, framing, or connective claims that were never discussed, however reasonable they seem. Writing an export puts you in a generative mode and plausible additions slip in easily — a design rationale nobody stated, an extra "could return if" condition nobody considered. The next session cannot tell your additions from the record and will treat them as prior work. If you genuinely believe something is missing, that is a thought for the next session to have, not a line for this document. Anything you concluded rather than read gets marked as an inference.

**Status markers must survive summarization.** A summary, heading, or index line must never assert what the body marks `[unverified]`. Compression is exactly where hedges get dropped, and a laundered estimate at the top of a document outranks the caveat buried below it.

**Anchor every relative time expression.** "Next week", "later", "다음 주", "지난번" are meaningless to a session reading months afterward. Convert to absolute dates against the session date, and where something was pending, say so explicitly — including the instruction to ask the user for the current status rather than assume it still holds.

**Never let the index outsource judgment.** If the next session must decide something, the index says so explicitly rather than leaving the decision implicit in an unmentioned gap.

## Templates

### `index.md`

The index is a **map plus decoding aids**, not a content document. It says what the export is, what each document holds, and defines the vocabulary needed to read any of them. Substance stays in the body.

```markdown
# <session subject, one line>

Exported YYYY-MM-DD HH:MM · <project or repo>
<one-sentence summary of the whole session: what got settled, what is still open>

> Handoff export, complete on its own. The documents below are meant to be read together.
> Before proposing any new direction, check `discarded.md` — several options are already rejected there.
> <if applicable> Supersedes the earlier export `<prior name or timestamp>`; nothing from it is required.

## Documents
| file | contents | read when |
|---|---|---|
| `01-....md` | current state, open threads, constraints, <subject matter> | ... |
| `discarded.md` | reversed and abandoned decisions | before proposing anything that sounds new |

## Glossary
<Project-specific vocabulary, abbreviations, internal names. A fresh session does not know these. Keep to one line each — this is a decoding aid, not a place for substance.>
```

Optional YAML frontmatter (`date`, `project`, `topic`) only if the user asks for it. Keep out any field that goes stale unless someone updates it later: `status: active`, progress percentages, next-action dates. A stale field is worse than an absent one, because the next session trusts it.

### Body document

```markdown
# <topic>

> Part of this export; `index.md` has the document map and glossary.

## Current state
<Where the work stands **as of this point in the session**. Two to five sentences.>
<Write "as of this session", not "currently" — the reader may arrive months later and work may have continued elsewhere. A block that reads as project-wide truth invites the next session to conclude that whatever is absent here does not exist.>

## Open threads
<Unanswered questions, deferred choices, things left for later. Each with enough context to be acted on cold. Omit the section only if genuinely empty.>

## Hard constraints
<The requirements that must not be violated or optimized away.>

## <substantive sections, organized by subject>
```

When the export has more than one body document, the state, open threads, and constraints go in the first one and the index's map points there. They are cross-cutting, and splitting them leaves no single place that answers "where does this stand."

### `discarded.md`

If the session genuinely reversed nothing, omit the file and say so in one line in the index — an absent file otherwise reads as a step that was skipped.

Otherwise, every reversed or abandoned decision, each with:

```markdown
## <what was considered>
- **Dropped because**: <the reason, concretely>
- **When**: <the point in the session, if it clarifies>
- **Could return if**: <the condition that would make it viable again — or "no">
```

The `Could return if` field earns its place: it stops the next session from re-proposing something already rejected, without permanently closing off an option whose rejection was conditional.

## Failure modes

Check for these before finishing — each is a real way this task goes wrong:

- **Summarized code or numbers.** Now unusable. The most common defect.
- **Chronological narrative instead of a knowledge document.** Forces the reader to replay the session to learn the state.
- **The answer survived but the constraint that produced it did not.** The next session then optimizes the answer away.
- **The user's corrections were dropped** because Claude's own output was more salient during recall.
- **Claude's speculation recorded as established fact.**
- **A discarded approach described in the present tense** somewhere in a topic document, contradicting the discard log.
- **Invented content** — a plausible-sounding claim, alternative, or rationale that no turn supports.
- **A hedge lost in compression** — the body says estimated, the summary says is.
- **Over-splitting** into fragments that only make sense read together.
- **An overloaded word in a filename or heading** ("baseline" meaning both the current implementation and the comparison target), which a cold reader resolves the wrong way.
- **Silent omission** of something judged minor at write time.
- **A verification pass that produced no findings list** — treat this as a pass that did not run.
