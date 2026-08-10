# Standing review guideline

The lab's review guideline, originally written by Kyungjin and edited by Hyunwoo.
Read this when no venue-specific guideline accompanies the request. When one does
accompany it, that one governs and this file serves as background.

---

## Before writing

Read the introduction, the main technique, and the evaluation carefully. Consult
background and related work while reading the technique section, since the
contribution is rarely legible without them. Full understanding on a first pass is
not the norm. Rereading the next day often resolves what the first pass did not.

Three questions must be answerable before writing begins.

- What is this paper trying to solve?
- What is the key idea or approach?
- What are the key evaluation results?

---

## The frame of a critique

Work through these while reading. They exist to surface criticisms that a single
pass misses.

### Problem statement

- What motivates the paper?
- What problem do the authors solve?
- Is the problem novel, in the sense that few have looked at it? Why or why not?
- Is the problem important? Why or why not?

### Solution approach

- How did the authors approach the problem?
- Is the approach different from what others have tried?
- Is the approach solid and sound?
- What alternative solutions exist?
- What are the trade-offs between the proposed approach and those alternatives?
- What technical challenges did implementation involve, and how were they overcome?

### Contribution

- What are the key contributions?

### Experiments and evaluation

- Do the experiments support the paper's claims?
- **Comparisons.** Does the paper need comparisons to other methods? What did the
  authors compare against?
- **Metrics.** What metrics are used, and do they establish the main contribution?
- **Workload and data.** What workloads and data are used, and are they appropriate
  to the claims?
- **Additional experiments.** What is missing, and specifically what would it show?
- **Interpretation.** Are the results presented fairly and comprehensively?
- Would you have designed the experiments the same way?

### Writing and presentation

- Are the structure and presentation effective?
- Given the same idea and the same results, would you have told the same story?

### Literature review

- Did the authors review and compare against prior work?

### Overall

- What are three strong points, including any not covered above?
- What are three weak points, including any not covered above?
- If the paper is well received despite its limitations, why? Reviewers see
  limitations clearly and accept papers anyway. Understanding why is as valuable as
  identifying the flaw.

---

## Writing the review

Give a score based on first impression, then revisit it once the review is written.

### Summary

Four elements: what the paper is about in one sentence, the challenges it addresses
in one or two sentences, a compact but detailed description of the proposed
technique in two or three sentences, and the evaluation results in one or two
sentences.

The summary exists so the authors can confirm the paper was read carefully. Write it
in your own words. After writing it, read it again and check that someone who has
not seen the paper could grasp the idea from it alone.

### Strengths and weaknesses

Provide at least two or three of each regardless of the recommendation. Be as
specific as possible.

```
Bad:  The evaluation was done extensively.
Good: The authors collected real-world data from different settings and evaluated
      the system across factors such as the number of users and weather conditions.

Bad:  The writing quality can be improved.
Good: The details of the proposed system are missing and described only at a high
      level, which makes the contribution difficult to assess.

Bad:  Describe X in detail.
Good: [state the specific detail that is missing]
```

For a positive recommendation, the strengths must convince the other reviewers. For
a negative one, the authors must be able to agree with the weaknesses.

### Detailed comments

Open with a paragraph giving the main reason for the recommendation. Follow with two
or three paragraphs explaining it further, grouped by section if that helps. Close
with questions and minor comments: design choices, evaluation settings, typos,
figures, sentences.

For a negative recommendation, add constructive comments aimed at the next
submission.

---

## Common mistakes

### Weakness and strength items lacking justification or detail

These items decide the outcome, so the reason for the recommendation must be both
clear and specific. High-level comments that could apply to any paper do not qualify.
Name which part of the writing, which prior work, which idea.

Localized comments such as "a detail in one section is missing" or "the baseline is
simple" invite the response that these are fixable after acceptance. A baseline
criticism becomes substantive only with an additional argument, such as that the
missing baseline is always used in this area, or that its performance plausibly
approaches the proposed method.

### Failing to help the paper as a whole

Specific comments matter, but the review must also address the problem, the approach,
the technique, and the experiments as a whole. This matters most for a negative
recommendation. The authors need to know what would change the outcome.

A useful test: if every comment in the review were addressed, would the paper be
accepted? Reviews that cannot answer this leave the authors unable to act.

Write as if the recipient is a colleague whose next version you want to see accepted.
This is also the best preparation for reviews of your own work.

### Missing citations

Any criticism of the literature review needs two or three concrete references.

### Expression

- Keep critical sentences dry. Excess wording wounds the recipient without adding
  information.
- Word choice: naive becomes simple. "The comparison with the baseline is unfair"
  becomes "the comparison is favorable to the proposed approach".
- Cut unnecessary adverbs: very, at all, completely, too, already.
- Do not repeat the same criticism.
- Avoid the second person. "The authors" is also often inappropriate, since the
  subject of review is the work. Prefer the work, the system, the technique, the
  proposed approach.
- Avoid conditional requests. "If there are accuracy-aware scheduling papers, compare
  against them" leaves the decision to the authors. Check whether they exist, then
  ask directly.
- Avoid seems, aim at, tries, would be. Hedging does not earn leniency for a
  misreading; it only weakens the appearance of expertise. Read closely enough to
  write with confidence. The polite conditional in "it would be better to" is fine.
- Do not open a sentence with a subordinating conjunction. Sentences beginning with
  Although or As usually carry a redundant clause. Put the main clause first and let
  the qualification follow as its own sentence.
- Avoid long subjects followed by a weak verb, especially when the subject contains a
  clause. Choose a verb that carries meaning rather than building around is, has, or
  makes.
- Cut verbose phrasing. If covering a word or phrase with your thumb leaves the
  sentence intact, remove it.
- Avoid depending on and reflecting. Their meaning is usually unclear, which normally
  signals that the underlying thought is not yet specific.
- Prefer requests over questions. Stating where and how to fix something reads as
  more considered, especially for major comments. Useful phrasings: it would be
  better to, I recommend, it is recommended, it would help readers, I wish, I would
  like to see, X would convince Y better.
- The review is read by the program committee and by the authors, who need to see
  that the paper was understood. Write it to stand on its own.

---

## After writing

Read the review several times. Keep the tone constructive throughout, and present
criticism as your own assessment rather than as settled fact.

```
Bad:  The writing quality is bad.
Good: The writing quality can be improved by X.

Bad:  The proposed system is too simple and shallow.
Good: This paper proposes a simple yet effective technique. It should be developed
      further to handle more difficult settings.
```

Imagine reading this review as the author of the paper. Then check that the review
justifies the score first assigned, and change the score if it does not.

Do not finish the review in one sitting. Allow time to read the paper from different
angles, and discuss it with the second reviewer, which helps considerably.
