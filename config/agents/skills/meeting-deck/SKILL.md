---
name: meeting-deck
description: Prepare slide decks and meeting material for the owner's research meetings and talks (the weekly professor meeting, the team meeting, lab or paper talks), from agreeing the content and checking the owner's understanding to the slides, the speaker notes and a lint that runs before every publish. Use this whenever the owner mentions 미팅 준비, 발표자료, 슬라이드, 장표, deck, talk, PPT, presentation, weekly meeting or team meeting, asks to turn results, a frame or a claim into slides, asks to cut or fix a slide, or asks for speaker notes. Also use it when a meeting is close and the owner is still asking conceptual questions, because that is when a deck goes wrong.
---

# Meeting deck

This skill holds principles and the workflow only. Project details (incidents, rejected words,
measured examples) live in the project's own records; for the dike NPU project they are in
`npu/reference/meeting-deck-details.md` in the dike repository.

A deck is a visual reference for a talk the owner gives, not a document the room reads. Every
item on it must be something the owner understands and can defend.

## Principles

**1. The content belongs to the owner.**
- Show only what the owner understands and can explain. Material that AI produced and the owner
  has not understood and verified stays out.
- Keep what is known apart from what is not. Do not show a result whose cause is unknown; put it
  in the appendix with a note, or drop it.
- Evidence must not be circular, must not come from the cases the values were tuned on, and must
  not rest on a quantity already dropped. Without evidence, present a direction and say so.

**2. Settle the message before the design, and start early.**
- The skeleton (one line per slide: what it says) comes first, then the claim's shape, then the
  slides. Design work on unsettled content is wasted.
- Freeze the content well before the meeting. After the freeze only cut, reword or move to the
  appendix. Late work polishes; it does not add.

**3. One message per slide, tied to the claim.**
- Each slide states one thing and how it connects to the claim. If the connection does not fit
  in one line, the slide goes to the appendix.
- Results, not process. Nothing the audience already assumes.
- Concept first, then one or two examples the owner understands. A complete taxonomy is not the
  goal.
- Items side by side are of the same kind and size. A representative case goes on the main slide,
  the full data in the appendix.
- Lead with the approach and its result, not with the baseline's weakness. Say what is different
  here that earlier work did not have.

**4. A claim is something that could be rejected.**
- A direction ("a compiler can do X") is not a claim. State what is true here and how it could be
  shown false.
- Siblings in a claim hierarchy are of the same kind; tests are not claims.
- Say why the claim holds here when it does not hold in general, and which observation it uses.
- An adopted taxonomy is a frame, not a finding. Details: `references/claim-slide.md`.

**5. Every number says what it is and what to read from it.**
- What was divided by what, for which case, on which machine, over how many runs.
- Emphasis goes only on the numbers that carry the message, and the emphasis must be true for
  every highlighted row.

**6. Plain words, defined once.**
- Plain explanatory sentences: no compressed declaratives, no metaphor, no personification.
- Terms of art stay in the field's own (English) words; never translate or coin them. Define each
  term where it first appears, or use the standard term.
- No internal labels (ids, letters, step numbers) unless defined on the same slide. One term has
  one meaning throughout.
- No vague or inflated words.

**7. Form serves a talk.**
- Little text; diagrams, tables and graphs where they carry the point. A table only when it has
  real columns. No big numbers with arrows.
- Titles are plain and modest; no subtitles or taglines.
- White background, near-black text, one accent color. Line breaks and alignment are deliberate.
- Slides in English; notes and documents for the owner in Korean prose with English terms.

**8. Correct narrowly.**
- Change only what the owner named, with the smallest change that answers it.
- When cutting text, move it to the notes or appendix; keep definitions and the concept-then-
  example order. Do not swing to the opposite extreme.
- "Remove X" removes X and what depends on it elsewhere.

**9. The owner's documents hold what the owner puts there.**
- A meeting document gets only what the owner asks for (a list of the questions is fine).
- Answer questions in chat. Record judgments and results in the project's log.

**10. Check mechanically, not from memory.**
- Rules written as prose get broken. Run the lint before every publish, and get a cold read of
  the slides from a reader with no context before the owner sees the full deck.

**11. Two meetings, two audiences.**
- The professor meeting is built around positioning and the claim; the team meeting around the
  details (mechanisms, measurements, definitions). Work in the team meeting's material and take
  only the claim and positioning from it for the professor meeting.

## Workflow

Let T be the meeting start; plan backwards from it.

1. **Skeleton.** At the very start, make the deck with the format's slides only, one line of
   message each, and get the owner's agreement line by line. Work on the real deck from then on.
2. **Claim.** Agree its shape (`references/claim-slide.md`) before any design.
3. **Ledger.** In your own working record (not the owner's meeting document), keep what the owner
   has understood (in the owner's words) and what not. Slides draw only from the first list.
   When the owner asks a concept question, answer it, update the ledger and the slide.
4. **Decisions.** Keep the owner's judgments about the deck in the same record and check each
   draft against them.
5. **Build** by the principles.
6. **Lint** before every publish: `python3 -I <this skill>/scripts/lint_deck.py <deck dir>
   --notes <notes.md> [--extra-banned <project list>]`. Fix every ERROR, look at every WARN, and go
   through the CHECK lists (terms defined? numbers explained?).
7. **Cold read** before the owner sees a full deck and again about an hour before T.
8. **Freeze** about two hours before T.
9. **Notes**, when the owner wants them, in the meeting document, one section per slide: the
   message, the order of points, expected questions with answers, and what is not yet known.
   Give the owner the list of numbers you computed and where to check each.

## Files

- `references/weekly-format.md`: the professor's weekly-meeting format and requests, verbatim.
- `references/claim-slide.md`: the claim slide template and checks.
- `references/figures.md`: figure principles.
- `references/deck-artifact.md`: claude.ai slide deck artifact mechanics.
- `scripts/lint_deck.py`, `scripts/banned_words.txt`: the pre-publish lint and its generic word
  list; a project adds its own list with `--extra-banned`.
