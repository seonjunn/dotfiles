---
name: research-framing
description: Help the owner propose, test and position a research claim or paper frame, so that a candidate dies cheaply and for a real reason or survives with honest evidence. Use this whenever the owner asks what the paper's claim, message, contribution or novelty is, asks whether a research idea or claim is new or already done in the literature, asks to compare with prior or related work for a research paper, to survey a research field for positioning, to pick a scope or generality level for a claim, to judge whether a prior paper kills an idea, or to write or revise a frame, positioning or related-work document. Also use it before proposing any new research frame or paper message to the owner on your own, and when the owner mentions 프레임, 클레임, 논문 메시지, 논문의 기여, 차별점, 포지셔닝, 선행 연구, novelty, positioning or related work in a paper context. Not for engineering questions such as whether a library already exists, nor for commit messages, error messages or open-source contributions. Reviewing someone else's paper is the paper-review skill; turning a settled claim into slides is the meeting-deck skill.
---

# Research framing

This skill holds principles and the workflow only. The project's own records hold the specifics:
the current claim, the measured facts, the owner's criteria for this paper, the ideas already
rejected and the prior-work table. Read those before proposing anything.

A frame is the one-sentence claim a paper stands on, with the conditions it needs. Most candidates
die. The work is to make each one die early (before supporting work is spent on it) and for a real
reason (a test, a comparable prior work, a stated criterion), and to keep the survivors honest
about how strong their evidence is. The owner decides what the frame is; the agent prepares the
decision.

## Principles

**1. Test a candidate before gathering support for it.**
- Write the claim as one sentence that someone could reject, and check it against the criteria
  the owner has stated for this paper.
- Name the cheapest test that could kill it (a short measurement, a few pages of a source, one
  question to the owner) and run that first.
- Check that it is not an already-rejected idea under a new name.
- Ask "what is new here" before "what kills it". A message another field already gave, repeated
  in a slightly different setting with nothing added, is labor, not a paper.
- Estimate the gain first: how much, against what. A frame whose best case is a marginal gain is
  not worth supporting, however cleanly it explains things.
- Pick a kill criterion because it matters to the claim, and write why. A criterion chosen
  because it is easy to measure tests nothing.

Why: kill tests that come last cost days, and rejected ideas return under new names.

**2. Keep facts apart from interpretations.**
- Keep a list of measured facts with no interpretation in it. A new candidate must explain all of
  them, not the convenient ones.
- Do not start a frame from justifying what is already built.
- Keep a control that separates a property of our implementation from a property of the problem
  or the platform. A cost of one implementation is easily read as a law of the platform.
- Narrow a claim to what the data supports, and drop the general version that loses on some
  comparison. A random or trivial baseline is a floor, not a baseline.
- A paper draft is not evidence. It can be rewritten at will. Cite the measurement or the logic
  behind a sentence, or say the support is missing.

**3. Import existing concepts; claim only what is added.**
- Before naming a concept, find the closest existing formalism or system and use its name. Do not
  build your own taxonomy of a decades-old problem.
- Show the split as a table: imported (from where) / added by us. The contribution is the second
  column.
- If the literature has no name, describe the thing by its properties. Do not coin a class name.
- When you switch from a project word to the literature's, say so once ("previously called X").
  Place our own components in their lineage: which known techniques they descend from, what they
  do and what they do not do.

Why: a renamed existing concept reads as a false novelty claim, and a reviewer from that field
will see it at once.

**4. Scope by properties.**
- Write the scope as the properties the claim needs, not as machine or product names, and tag
  each claim with the properties it needs.
- For each candidate write the widest scope in which its sentence could stand, and check the prior
  work of that scope with the rejection rule in principle 5.
- When generality and gain trade against each other, show both candidates and let the owner pick.

**5. Prior work sharpens a claim first, and rejects it rarely.**
Before reading, write: the claim as a measurement on a named setup; the setting as part of the
claim (platform, unit, constraints); and our whole combination. Then hold each paper against the
whole combination, not against its pieces.
- **Rejection rule.** Reject only when one prior work (or one tight cluster in the target
  community), in a comparable setting, states the whole combination, or the claim follows from it
  with no new inference. Everything else is positioning:
  - pieces scattered over several papers are citations;
  - the same word is not the same work until the setting and the boundaries match;
  - the union of several papers' strengths is not a prior work. Weigh each paper's weaknesses too.
- **Match the unit first.** Write the unit (one component, a composed system, a whole
  application) and the kind of platform on both sides. A result about one component in isolation
  does not reject a claim about the composed system. The rule holds equally when prior work is
  used to reject one of our own sentences.
- **Stages.** A prior work has (1) exposed an option, (2) noted a phenomenon, (3) measured it, or
  (4) built something that exploits it. A lower stage never refutes a higher one: an option in a
  tool's interface does not refute a measurement of how that option interacts with others.
- **Sharpen.** Use each prior result to narrow where our claim aims, and record the row:
  original sentence → prior work (unit, platform, what it shows) → narrowed sentence.
- **Report findings, not verdicts.** "Paper P solves X for one unit and leaves Y to the user" is a
  finding. "Our direction is dead" is a verdict, and one input does not decide it. Put the
  counter-example first and most visibly, with its stage and setting.

**6. Tag every citation by how you know it.**
- Tags: primary (you opened and read it), secondary (extracted by another survey or agent, not
  rechecked), figure-read, own inference. A secondary citation cannot change a conclusion.
- Write "X does not do Y" only when the source says so. Otherwise write "not found in the
  sections read (names)", and not before reading the method section that would describe it.
- Keep the source's conditions when paraphrasing. Never widen "such as" to "all". Read the rest
  of a quoted sentence: a clause can support a claim that its continuation takes back.
- Mark quotation and your own inference separately, sentence by sentence.

The paper-review skill applies the same discipline to negative claims about a single paper.

**7. No universal negatives.**
"Nobody does X" cannot be confirmed, and one counter-example kills it, whatever the quality of
the research. Such a claim dies in every survey. State a measurement on a named setup, which no
citation can kill. A survey supports at most "our survey did not find it", with where it looked.

**8. Classifications and generality claims must be able to fail.**
- Before reporting a distribution over categories, write for each category whether any input in
  the set could reach it at all, and state the selection bias of the input set. A zero in an
  unreachable category is a tautology, not a result.
- Test a framework on fresh cases, or with labels that predate it. Whether past work followed its
  order shows consistency, not effectiveness.

**9. Every piece of work names the claim it serves.**
- Each experiment, analysis and agent brief states the claim or open question it serves, or
  "none: <reason>". Work with no slot is not done.
- Prioritize the weakest part of the claim that matters most. Do not sink into one parameter, one
  error source or evaluation detail.
- When the frame changes, check every running and planned item against the new frame and stop
  those serving an abandoned claim.

**10. A cold reviewer reads it before the owner does.**
- Before a frame-level proposal or a prior-work comparison goes to the owner, give it to a fresh,
  read-only reviewer with no context and a fixed brief (`references/cold-review-brief.md`). The
  brief lists the exact files to read, carries the proposal verbatim, argues nothing, and says
  not to trust the proposer.
- For a prior-work comparison, the reviewer re-checks every quotation against the original. The
  check comes before the report; a wrong statement that reaches the owner first costs trust.
- Show the reviewer's answer together with the proposal, including where it disagrees.
- Split a survey into independent chunks. Paste principles 5 to 7 into every survey brief word
  for word, keep your own hypothesis out of it, and save each brief next to its result.

## Workflow

1. **Read the project's records**: the current claim, the fact list, the rejected ideas and the
   owner's criteria. Do not start from the end of the log; the last argument of the last session
   is not the frame.
2. **Test** the candidate (principle 1). Stop at the first failed check and record why.
3. **Prior-work pass** (principles 5 to 7): write the claim, setting and combination first, read
   primary sources, fill one row per paper, update the positioning table.
4. **Cold review** (principle 10).
5. **Present to the owner**, briefly: the one-sentence claim, what is new, the closest prior work
   and the distinguishing sentence, the kill test and its result, the widest scope where it
   stands, how strong the evidence for each supporting fact is, and the cold reviewer's answer.
   Give findings; the owner gives the verdict.
6. **Record** the outcome the same turn in the project's records; a rejected candidate is
   recorded with what killed it.

## Prior-work row

One row per paper; the positioning table is these rows.

| column | content |
| --- | --- |
| decides itself | what the system or method determines, as opposed to what the user writes |
| outside its boundary | what it leaves to the user, to tuning or out of scope. The most important column: our position is usually outside someone else's boundary |
| setting | unit, platform, constraints |
| stage | option exposed / phenomenon noted / measured / exploited |
| source | primary (sections read) or secondary |

## Files

- `references/cold-review-brief.md`: the fixed brief for the cold reviewer, and the quote check.

## Related skills

- `paper-review`: reviewing someone else's paper; its claim ledger and negative-claim check.
- `meeting-deck`: the claim slide (a claim is something that could be rejected, sibling claims
  are of one kind) and how a settled frame becomes slides.
- `experiment-rigor`: how a measurement becomes evidence (repeats, fixing the prediction first,
  fair baselines).
