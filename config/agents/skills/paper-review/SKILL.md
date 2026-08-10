---
name: paper-review
description: Write a conference or journal paper review, with every criticism verified against the paper's own text before it is written down. Use this only when the user explicitly invokes /paper-review, or explicitly asks for a review to be drafted, merged, or revised. Reading a paper, summarizing it, explaining its technique, or discussing whether its idea is sound are not by themselves requests for a review; handle those directly instead.
---

# Paper Review

A review carries weight only if every claim in it survives contact with the paper.
The most common way a review fails is not weak writing but a criticism that turns
out to be false, which the authors can refute by pointing at one figure. This skill
front-loads verification and then enforces the sentence discipline that makes the
surviving claims land.

## Inputs

The request normally arrives with the paper as a PDF, the venue name, and the
venue's review form. It may also carry a review guideline or checklist, and a
co-reviewer's review.

Sort out what arrived before starting.

- **Paper.** Read it from disk rather than skimming what appears in context. Figures,
  tables, and section structure have to be extracted rather than guessed at, and the
  mechanism differs by environment: in web/mobile chat, consult
  `/mnt/skills/public/pdf-reading/SKILL.md` first; in Claude Code, read the PDF in
  page ranges, which renders each page so that figures and tables arrive intact.
  Either way, cover every page before step 2, since the negative claims checked
  there hold only against the whole paper.
- **Review form.** Reproduce its fields and their order exactly, including the
  numbered options for scores. Mark the selected option in the way the form implies.
- **Guideline or checklist.** A supplied one governs. When none is supplied, read
  `references/lab-guideline.md`, which holds the standing guideline.
- **Co-reviewer's review.** See the merging section below.

If the venue form is missing, ask for it rather than inventing a structure, since
the form determines how much goes into the strengths and weaknesses and how much
goes into the comments.

## Workflow

Steps 1 through 3 happen before any review prose is written.

### 1. Read for structure

Read the introduction, the main technique, and the evaluation. Consult background
and related work as needed to understand the contribution. Rereading the next day
helps when the schedule allows.

While reading, build a map for later reference: which section covers what, what each
figure reports, which baselines the evaluation actually uses, and what the paper
itself names as its limitations. Criticisms will be checked against this map, and
the discussion section often concedes exactly the weakness worth raising.

Answer these three before continuing. If any is unclear, reread rather than guess.

- What problem does the paper solve?
- What is the key idea?
- What are the headline evaluation results?

Then work through the critique frame in `references/lab-guideline.md` to generate
candidates across problem statement, solution approach, contribution, experiments,
writing, and literature review. The frame exists to surface criticisms that a
single reading misses.

### 2. Build a claim ledger

List every criticism worth considering. Do not write review prose yet.

For each candidate, record where in the paper it would be checked, then check it and
mark the outcome.

- **Verified** — a sentence in the paper supports the claim. Note the sentence.
- **Refuted** — the paper already does this, or says otherwise. Drop the claim.
- **Uncertain** — no clear evidence either way. Either drop it or convert it into a
  request for clarification, never a criticism.

Two checks deserve extra care because they fail most often.

**Negative claims.** "There is no X", "the paper never compares against Y", "Z is not
evaluated" hold only after checking the whole paper. A single counterexample
collapses the claim and takes the credibility of the rest of the review with it. A
frequent instance: writing that no experiment isolates a component when an ablation
study exists. The accurate version is narrower, such as noting that the ablation
removes the system's own components but compares against no alternative design.

**Requests already satisfied.** Before writing a request, confirm the paper does not
already provide it. Asking for a breakdown by condition is wasted if a figure already
reports exactly that, and the authors will answer with a figure number.

Also record which claims rest on the paper's text and which rest on your own
calculation or interpretation. That distinction is reported in step 6.

### 3. Set the recommendation

Choose the recommendation from the verified claims, not the reverse. Then apply this
test to each surviving weakness: would a reader who accepts this item find the
recommendation reasonable?

Items that fail the test are still useful, but they belong in the comments rather
than in the weaknesses.

Watch for weaknesses that invite an easy rebuttal. "Details are missing", "the
baseline is simple", "the writing could improve" all invite the response that these
are fixable after acceptance. To carry such an item as a principal reason, supply a
supporting argument: that the missing baseline is standard in this area, or that its
performance plausibly approaches the proposed method.

Two questions calibrate the outcome. If every comment in the review were addressed,
would the paper deserve acceptance? And if the recommendation is negative, what makes
this line of work valuable enough that its next version should succeed? Reviews that
cannot answer either question are usually a collection of local objections rather
than an assessment.

### 4. Write the review

Follow the venue's form. When it offers no structure of its own, use this one.

```
Recommendation
Summary
Strengths
Weaknesses
Comments for authors
References
```

**Summary** covers four things: what the paper is in one sentence, the problem, the
approach in enough detail to show the paper was read, and the headline results. This
is where the authors confirm the review rests on an actual reading, so put it in your
own words rather than reusing the abstract's phrasing.

**Strengths and weaknesses**: at most three each, most important first, one sentence
each and two at most. Anything longer moves to the comments.

**Comments for authors**: an opening paragraph of one or two sentences giving the
overall assessment, the basis for the recommendation, and what would change it.
Everything after that is bullets, around five, three sentences each at most. They
mainly expand the weaknesses, plus one or two additional items. Separate major from
minor, and drop the labels entirely when there are no minor items.

Address the work as a whole rather than accumulating local objections. A review that
lists only surface issues leaves the authors unable to tell what would change the
outcome.

**References**: a section at the end of the comments. See the references section below.

### 5. Self-audit

Reread the whole review against the checklist at the end of this document before
delivering it. When revising afterward, check that a previously corrected error has
not returned, since condensing tends to restore earlier and less accurate phrasings.

### 6. Deliver

Hand over the review with a short note separating which statements rest on the
paper's text and which rest on calculation or interpretation. The user needs to know
in advance where they can concede during reviewer discussion.

## Sentence rules

### Judgment first, evidence second

A neutral description of what the paper does is neither a strength nor a weakness.
Every item opens with an assessment and continues with what supports it.

```
Weak:   The system keeps auxiliary constraints active during normal operation.

Strong: Keeping auxiliary constraints active during normal operation is a useful
        detail. The auxiliary state converges in advance and is available the
        moment the primary source drops out.
```

Carry this through to consequence. Stating that something is absent is only half the
item; the other half is what that absence prevents.

```
Weak:   The evaluation lacks baselines that isolate the benefit.

Strong: The evaluation cannot establish which component produces the improvement,
        as it compares only against the two fallback methods.
```

### Self-contained

The review must be intelligible to someone who has not read the paper, since the
program committee and the other reviewers read it too.

- Do not refer to sections by number. Name them by role: "the module that filters
  measurements", "the data collection procedure".
- Figures and equations keep their numbers with a description attached: "Fig. 4
  reports error against distance".
- Use the paper's own terminology, stating the role of each term on first use.

### Subject

The paper, the system, a component, or a design decision is the subject. Avoid the
second person and "the authors", since the review addresses work rather than people.

```
Weak:   A device whose tracking fails cannot corrupt the others.

Strong: Restricting the information flow to one direction avoids the error
        propagation that a joint formulation would allow.
```

### No abstract praise or blame

"a real gap", "the strongest decision", "a significant contribution" carry no content.
State what differs and how.

Describe properties of the work rather than which part of the writing improves.

```
Weak:   This would strengthen the related work section.

Strong: The contribution would be easier to credit.
```

### Requests, not questions

Propose the fix directly. A request reads as more considered than a question and
gives the authors something to act on. Leave to the authors what is theirs to decide:
ask for a distinction to be stated, rather than dictating what the distinction is.

```
Weak:   Please clarify the novelty relative to prior work.

Weak:   The distinguishing elements are A, B, and C.
        (prescribes content the authors should determine)

Strong: The contribution would be easier to credit with a direct statement of what
        the system does differently from [1] and [2]. The related work discussion
        separates the system from [1], while [2] is treated at the category level.
```

Useful phrasings: "It would be nice to", "I recommend", "I would like to see",
"X would show Y".

### Register and diction

- Constructive and even. Write as if the authors are colleagues whose next submission
  you want to see accepted.
- Match the tone to the recommendation. Superlatives in the strengths contradict a
  negative recommendation, and hedged strengths contradict a positive one.
- Break long sentences rather than chaining clauses with commas.
- Do not open a sentence with a subordinating conjunction. Put the main clause first
  and let the qualification follow as its own sentence.
- Avoid long subjects followed by a weak verb. Choose a verb that carries meaning
  instead of building the sentence around is, has, or makes.
- Avoid: seems, aim at, tries, would be, depending on, reflecting.
- Avoid: very, completely, too, already.
- Avoid conditional requests such as "if there are prior works, compare against them".
  Check whether they exist, then ask directly.
- Prefer simple over naive, and "favorable to the proposed approach" over "unfair".
- Lower uncertain claims rather than dropping the point: "X is wrong" becomes "X is
  difficult to assess and would benefit from further explanation".

### Formatting

No markdown emphasis anywhere. The only exceptions are marking the selected
recommendation and the References subheading. No label structures such as `Fix:`, no
capitalized section markers, and no sub-bullets stacked until a bullet reaches
paragraph length.

## Merging with a co-reviewer

When a co-reviewer's review is supplied, the merge is asymmetric. Their items carry
their judgment, not yours, so preserve them at the level they assigned: what they
placed in the weaknesses stays in the weaknesses, and their reference numbering stays
intact. Polishing the wording is the only change to make. Your own items may be cut
or compressed to fit.

Where both reviews reach the same point, keep their framing and add your evidence or
proposed fix beneath it. Where the two conflict, such as one review praising a design
the other calls incremental, narrow the scope of each until both hold rather than
dropping either.

Report the merge afterward as a table mapping each of their items to its location in
the merged review, so the user can confirm nothing was lost or downgraded.

## References

Verify authors, title, venue, and pages by search before citing. Cite only what
carries an argument; a baseline the authors would implement themselves needs no
citation. Place the number where the claim appears rather than in a separate
sentence, and collect the references in a section at the end of the comments.

Any criticism of the literature review needs two or three concrete citations. An
unsupported claim that related work is missing gives the authors nothing to act on.

Check whether the paper already cites the work. If it does, the criticism changes
character and grows stronger: the point is no longer that related work was missed but
that the work is cited without a stated distinction. Similarly, if the paper names an
approach as the alternative it set aside, that naming supports a request to implement
it as a baseline, and such a request is difficult to refuse.

## Checklist before delivering

1. Every factual statement has a corresponding sentence in the paper.
2. Negative claims were checked exhaustively.
3. No request duplicates what the paper already provides.
4. Strengths and weaknesses number three or fewer each and justify the recommendation.
5. The tone of the strengths matches the recommendation.
6. Each item opens with a judgment and continues with evidence.
7. Sections are named by role rather than by number.
8. Requests replace questions.
9. Criticism of the literature review carries concrete citations, and all references
   are verified.
10. The summary would let someone who has not read the paper follow the review.
11. Addressing every comment would plausibly make the paper acceptable.
