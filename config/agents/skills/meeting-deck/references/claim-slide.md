# The claim slide

Settle this slide before any design work; it is the slide that gets rewritten when the content is
not settled.

## Template

```
Observation A   a fact about the setting the approach exploits (checked, with its source)
Observation B   a second fact, if there is one

        claim                                         status
C0 goal  what the system achieves; can be tested       not tested / partial / shown
C1 ...   a means; says which observation it uses       ...
C2 ...   a sibling means; same kind as C1              ...

Validation plan
1. first step, doable this week
2. ...
3. the step that would show C0 (e.g. a new case with no case-specific work)
```

Keep each table cell short (about ten words); the explanation goes in the notes.

## Checks

1. **Could someone reject it?** A direction is not a claim. A thesis says what is true here and
   what would show it false.
2. **What is different here, and why could earlier work not do it?** Name the observation that is
   new or newly available in this setting, and let each claim use one.
3. **Are siblings the same kind?** An abstraction and the rules written over it are separate
   claims. Checks and experiments go under validation, not beside the claims.
4. **Does each sub-claim explain why the parent holds here and not in general?** The shape is:
   "this usually fails for reasons X and Y; here they do not apply because ...; this experiment
   shows it." A sub-claim that suddenly narrows the scope looks arbitrary.
5. **Is the dependency between claims stated,** and is each claim big enough to stand and really
   the part that makes the goal possible?
6. **Is it reinventing the wheel?** State what the abstraction gives that the closest existing one
   does not.
7. **Is an adopted frame being sold as a claim?** A complete taxonomy that was borrowed or chosen is
   a frame, not a finding.
8. **Does the evidence hold?** Withdraw evidence that is circular, measured on the cases the
   values were tuned on, or built on a quantity already dropped. Without evidence, write
   "not tested" and present a direction.
9. **Is every word defined** on the slide or an earlier one?

## Status words

Plain words: `not tested`, `<what exists> only`, `not written`, `shown on <cases>`. No percentage
of support without its exact definition.
