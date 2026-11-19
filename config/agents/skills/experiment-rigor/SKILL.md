---
name: experiment-rigor
description: Rules for measurements that someone will act on. Use whenever you design, run, compare or report a measurement, benchmark, profile, A/B test or timing; when you choose what to optimize or decide whether a change is a gain ("is it faster", "did it regress", "same or different"); and when you check numerical accuracy or correctness against a reference (tolerances, golden outputs, divergence hunting). Trigger even for a quick single comparison or a one-line "it got faster" report, because the failures this skill prevents (one run read as a difference, a control that never took effect, a tolerance loosened to pass) look like success when they happen. Not for fixing ordinary unit or snapshot tests, or for reading a timing that nobody will compare or act on.
---

# Experiment rigor

A number is a claim about a distribution, measured in one environment, answering one question.
Every rule below protects one of those three parts: the spread, the environment, or the question.

Scope: the comparison and recording rules are for claims that will be reported or acted on. One
diagnostic run may pick the next experiment without them. Say which kind a run is when you report it.

## Principles

### a. Choose the work from evidence about the objective

Before choosing or delegating a substantial optimization, state the user-visible
metric, representative workload and correctness boundary, then the evidence
locating a meaningful cost or gap. With a faster reference, first align inputs,
outputs, precision and measurement scope; compare elapsed time at common coarse
boundaries and refine the large differences. Without a reference, use measured
latency, waits, resource saturation or a defensible cost bound to locate the
constraint. A visible code difference, high utilization, fewer operations or
passing tests alone does not establish the opportunity.

Before accelerating measured work, establish why it must exist. Distinguish a
user or external requirement from a representation choice or an added internal
guarantee. Tests written with an implementation preserve its behavior but do
not by themselves justify that requirement. Compare removing unnecessary work
with making it faster, including proof and experiment cost. Trace callers and
consumers before removal; make any observable contract change explicit. Do not
turn a deletion heuristic into a quota or permission to discard evidence.

Name a causal hypothesis, the plausible end-to-end benefit and the cheapest
experiment that can distinguish it from alternatives. A small reversible A/B
may be cheaper than more profiling; do not require exhaustive instrumentation.
Choose by recoverable benefit, confidence and experiment/implementation cost,
not simply by the largest profile row. Necessary work may offer less opportunity
than smaller removable work. Select tools for the question: elapsed-time
decomposition locates latency, resource checks locate saturation/errors, and
wait analysis explains blocking. No one view covers all three.
Separate inclusive time, overlapping work and the dependency path that limits
completion. Check measurement coverage and observer effects; leave unexplained
time explicit. One diagnostic can select the next experiment, but performance
claims require repeated comparable runs and correctness checks.

Reassess when a candidate fails, costs more than expected or stops explaining
the goal's gap. Repairing that candidate is not automatically the next priority.
At delegation and acceptance, connect the work to the measured objective;
keep prerequisites and local improvements distinct from end-to-end progress.

**Why:** an optimization effort chose visible code differences before matching costs
against the reference, then spent too long repairing rejected candidates.
This is a general performance-engineering selection failure, not a mandate to
always prioritize a particular optimization or profiling tool.

Four additions to the selection step:

- **Size the gain before the work.** Write "N× faster than what" first. A gain of a few percent
  may not be worth the work even when the fix is fundamental.
- **Fix a slow development loop first.** Before repeating an expensive campaign, read the measured
  build, transfer, execution and validation costs. A dominant, avoidable repeated cost gets a small
  scoped fix before the batch, even though it is "only infrastructure".
- **Find the mechanism, then write a small rule that matches it.** Do not apply a blanket rule
  everywhere, and reject a tuned constant that only makes one case pass posing as a fix.
- **Attribute cost only from measurement.** Do not blame a delay or a cost on a plausible cause
  without measuring the critical path.

### b. Same, different and faster are claims about a distribution

- **At least three runs per arm**, on the same machine, with the arm order alternated (A B A, or
  A B B A). Quote the spread across runs, not only within one run.
- **A within-run interval says nothing about run-to-run variance.** A bootstrap over blocks of one
  run answers "how much does this vary inside this run". Thermal state, buffer placement and
  anything else fixed within a run and free between runs is a separate variance component.
- **An effect smaller than the run-to-run spread is not an effect yet.** If that spread is not
  known for the quantity, measure it first. When the evidence does not settle it, write
  "not established".
- **A single run is reported as "one run"**, in the sentence that reports it, and never described
  with "same", "no difference", "unchanged" or "X is larger than Y".
- **When the effect is smaller than drift across a session**, compare within a round and paired,
  with alternating order. An unpaired A-then-B comparison measures the drift.
- **Repeat a one-run finding before it becomes a premise** for further work.

### c. Name the statistic, and attribute causes by controlled comparison

- **Latency is a median** (with its spread, for example the interquartile range or the range of run
  medians). A mean is for totals, throughput and analyses built on expectation, which is linear
  where a median is not; then both sides of the comparison are means.
- **Never substitute one statistic for a missing other**, and never sum gains from separate
  experiments into one total.
- **A causal claim needs a comparison where only that factor moves.** Attribute a combined gain by
  leave-one-out on the same code, not by the chronological chain of changes. Do not assign a gap to
  one cause when other policies also differ.
- **Choose a metric that can fail.** A percentage that is high with one data point cannot test a
  shape; use enough points to test the claim.

### d. Compare like with like

- **Never compare numbers from different environments or execution modes**: machine, clocks,
  thermal state, cache state, order, precision, data format, input data. A cross-environment
  difference is real, reproducible, and about nothing, which makes it look stable under repetition.
- **Different precisions or formats are a trade-off, not a comparison.** Match every field both
  sides store before putting their numbers side by side.
- **Give the baseline its best realistic configuration.** A gain against a handicapped baseline is
  not a gain.
- **A control counts only if it also holds in the real workload.** Removing something in a small
  harness that a long production run cannot avoid makes the harness describe a regime the workload
  never runs in. Either measure in the real regime or apply a control the real run also enforces,
  and scope results from the easier regime as such.

### e. Control the environment, then read it back

- **A control that was written but not read back did not happen.** Set every performance-relevant
  knob from config, confirm it is in effect, and restore it afterwards, failure paths included.
  Some writes fail silently (a missing privilege, a value the system clamps).
- **Record the settings the run actually used**, resolved once, with any override and its source.
  No silent fallback or call-site default. A setting whose only record is an ambient environment
  variable is not reproducible.
- **A key recorded as applied that changes nothing is worse than no key.** Parsing is not applying;
  find the line that consumes the value.
- **No silent substitution of inputs.** Zeros, random data, a different model or a cached stand-in
  are used only when declared, and the declaration lands in the record. A run on substituted
  inputs does not measure the deployed workload.
- **Every reported number carries its environment** (machine identity, build identity, resolved
  settings, date). A number that cannot be re-run from its record is a note, not a result.
- **A diagnostic stays off during measurement until it is shown to be harmless.** An observer must
  reproduce the uninstrumented output and timing before its trace is used to attribute a cause.
- **Warm-up is excluded by a stated rule**, never averaged away. The first iterations of a session
  are a different regime.
- **Identify an entity by provenance** (who created it, which run produced it), never by name,
  index, arrival order or a transient state. Ids get recycled.

### f. Keep the evidence

- **Keep raw per-sample data and derive labels later.** No threshold discards its own input; an
  exclusion rule tags what it excludes. Relabelling is free; re-measuring is not.
- **Measure assumed constants in the same run.** Plan on the assumption, record the measured value,
  use it where it exists, and flag when the two diverge.
- **Evidence is never overwritten.** Each new run or comparison gets a fresh destination, archived
  results are never written into, and failed runs are kept.
- **Tag each claim with its evidence class**: measured (with machine, run count and date),
  computed, estimated, read from a source, or from memory.
- **Audit a document's numbers by recomputing them from raw data**, and search the original records
  before writing "no record".
- **Question whether a gain is real and the comparison fair before explaining it.** State
  confidence per claim and the limits of a single-factor ablation.

### g. Fix the decision rule before seeing the result

For claims that will be reported (keep it to a short note; this is not a ritual for diagnostics):

- **Before measuring, write down** what changes, the expected result, the correctness bar and the
  decision rule, somewhere later edits are visible. For an analysis of existing records, fix the
  scoring before reading them.
- **Never edit the rule after seeing results.** A change is a separate, dated amendment. Editing
  the rule means rerunning.
- **Label anything chosen after seeing the data as post hoc**, and report the alternative reading
  beside it. A test on already-known results shows consistency, not prediction.
- **Thresholds come from a stated procedure applied mechanically**, with sensitivity shown at
  several settings. Never choose the reference population by the distribution being measured, and
  never score an indicator that appears in its own definition.

### h. Numerical correctness comes before speed

- **Use an independent oracle** with matched precision, inputs and output scope. Your own
  artifacts (hand-written implementations, earlier captures) are regression references, not authorities.
- **Results are pass, fail or unverified.** A missing or incompatible reference is "unverified",
  with what must be obtained to verify it. A partial capture cannot qualify the whole output.
- **One acceptance rule for every case.** Do not negotiate a weaker rule per input. Pin bounds
  independently of the candidate; never fit a tolerance to captured outputs.
- **Never loosen a tolerance to make a check pass.** A change to rounding or approximation
  semantics is an explicit numerical-policy change, recorded and tested separately.
- **A speed number counts only if accuracy is at least the baseline's**, measured against a
  reference of the same precision. A faster but less accurate variant is a separate version,
  never presented as the comparison.
- **Validate numeric changes on worst-case inputs**, not only on typical ones.

Divergence protocol, when outputs differ from the oracle:

1. Fix the identity of the inputs and reference, and the arithmetic contract.
2. Find the first stage whose output diverges.
3. Replay that stage with the same captured input.
4. Prove the observer harmless: the instrumented build must reproduce the uninstrumented outputs
   before its trace attributes a cause.
5. Keep a minimal regression that discriminates the cause.
6. Revalidate the complete path after integration; a patched intermediate alone is not an
   end-to-end correctness result.

## Procedure

### Before the run

- State the question, metric, workload, correctness boundary and the size of gain that would matter.
- For a reported claim, write the prediction and decision rule (section g).
- Check executable and build identity, argument schema and input pins. Before widening an interface
  change, build one minimal case against the real toolchain.
- Look at the count or summary of what a selecting or materializing step will pick before running it.
- **Smoke the full path, analysis included, then read the analysis output, not the exit code.** A
  plan that proposes hours of machine time is not finished until it contains this step.

### During the run

- Apply controls from config and read them back (section e). Record the settings the run used.
- **Fail loudly.** A run that measured nothing must not report success: assert on preconditions
  that would give a plausible but empty result, count incomplete items explicitly, never print a
  verdict computed from nan or from no data, and do not let a component's failure become a silent
  exit. Flush partial outputs to disk if a long run crashes.

### Comparing and reporting

- Three or more runs per arm, alternated, with the spread across runs (section b).
- Name the statistic (a median for latency) and give each number its evidence class (section f).
- Correctness first: a speed number without a passing accuracy check is not reported (section h).

## Failures these rules come from

- A single run per condition produced two findings that a replicate would have overturned: one was
  an ordering confound, the other an environmental difference between the runs.
- A control write failed silently for lack of privilege; only reading it back showed it never applied.
- A run wrote its results and exited zero while one of its components had recorded nothing.

## References

Brendan Gregg, [Performance Analysis Methodology](https://www.brendangregg.com/methodology.html)
(method choice, anti-methods and cheap discriminating tests); Cary Millsap,
[Diagnosing Before Resolving](https://carymillsap.blogspot.com/2009/09/on-importance-of-diagnosing-before.html)
(diagnose large costs, choose the best net benefit). These guide judgment rather
than mandate an exhaustive checklist.

Related: [Musk's engineering process, original interview publisher](https://everydayastronaut.com/starbase-tour-and-interview-with-elon-musk/)
(question requirements and attempt removal before optimizing what remains;
contextual engineering guidance, not a universal acceptance rule).
