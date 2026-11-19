---
name: unattended-work
description: Procedure for work that keeps running while the owner is away, and for several agents working on one codebase or one pool of shared resources at once. Use when the owner says they are leaving work running (overnight, "돌려놓고 잘게", going to sleep, a multi-hour run, or "알아서 진행해" said while leaving or about work that will run for hours), when a campaign will outlive the current conversation turn by hours, or when you are about to launch or coordinate two or more background agents that edit the same repository, share a build directory, or queue for the same machine or device. Not for an ordinary session with one short background job; the global rules on background work cover that.
---

# Unattended work

The owner is not there to catch a wrong turn, so the plan, the limits and the record must do it.
Global rules still apply: parallel launching, per-task model and effort, waiting on PIDs rather
than `pgrep -f`, long-running and background work, and git authority. This skill adds only what a
multi-hour or multi-agent campaign needs on top.

## 1. Before leaving: write the plan

Write it into the project's existing plan or log (not a new file), then start. It states:

- the goal and its milestones, and which one is the critical path;
- the roles, with the model and effort chosen for each (global rule) and why;
- who watches for abnormal slowness, and the triggers in section 3;
- how docs and commits are handled (global git rule; unattended work does not widen it);
- the limits in section 2, and any grant the owner gave for this campaign, quoted verbatim.
  A grant from an earlier campaign is history, not permission.

Give no completion time while a cause is still unknown. Say what is unknown instead.

## 2. Limits while unattended

- The coordinator (the session the owner talked to) owns integration, acceptance and the final
  verdict. Workers propose; they do not declare done.
- Do not change shared environments, loosen a tolerance or reference, delete originals, push, or
  open a PR. Cap the number of concurrent jobs and write the cap in the plan.
- Continue authorized work without asking for routine approvals. Escalate contract decisions
  (reference, tolerance, precision, scope) and never change them silently; record the question
  with options and a recommendation, and continue on other work.
- Close new scope at a fixed time before any deadline; after it, only finish and record.
- Long exclusive use of a shared resource (a machine, accelerator, device) needs the owner's
  approval (global rule), and does not start beyond what the grant quoted in the plan covers.
  Within the grant, announce it to the coordinator before it starts.
- Do not hold a scarce shared resource idle: queue the next job before the current one ends, and
  check one job's results while the next one runs.

## 3. Re-check triggers

Write the triggers into the plan before leaving, measured against comparable earlier stages:

- A stage runs well past its comparable baseline, or shows no progress: look at the process (CPU,
  I/O, what it waits on) before waiting longer or adding jobs. Add cores only for a demonstrated
  parallel CPU bottleneck. Record the cause and the next checkpoint.
- The global reassessment trigger ("Keep the objective" rule) applies; unattended, also write the
  decision into the plan.
- Retries: rerunning the same binary and config is a retry. Set a retry limit in the plan; at the
  limit, stop and report. A rerun after a cause confirmed by a cited line and a fix is not a retry;
  changing settings on a guess is.

## 4. Runs that outlive the session

- Long runs are detached processes with a written recovery procedure, so a session cutoff does not
  lose them. Check that waiters survive their parent agent. Every subprocess has a timeout.
- Freeze the code and config a running measurement reads. While a run uses a checkout, do not
  commit to it or leave files in it; edits happen in a snapshot. Lift only the freeze whose run met
  its completion condition. (A mid-run commit once made a run's provenance check refuse it.)
- Large outputs (exports, weights, bundles, build trees) go to the project's designated data area,
  not the repo, home or `/tmp`. Check its free space first, and never spill silently to another
  filesystem.

## 5. Coordinating several agents

- **Ownership.** Write a file-ownership split before launching. Only owners edit their files in the
  shared checkout. Others work in their own snapshot or worktree and hand over patches. Announce
  to the coordinator before touching a shared file; the coordinator checks for overlap and answers.
- **Outputs.** Workers write only to their own staging directories. The coordinator is the only
  writer of final shared outputs and project docs.
- **Shared builds.** Rebuild a shared build directory only on the coordinator's signal; agents
  build in their own directories until then. (A shared rebuild once moved another agent's
  measurement baseline mid-campaign.)
- **Briefs.** Each worker gets: the question its result serves, only the context it needs, exact
  input and output paths, its owned files, and the forbidden actions (for example no sweeps, no
  shared rebuilds, no production edits, no policy loosening). Do not embed your hypothesis; it
  comes back confirmed. Prefer a written brief to forking the whole conversation.
- **Messages to the coordinator.** Start and end of an exclusive run, blocked, a fork that needs a
  decision (options plus a recommendation), the final result. Short, decision first. No
  progress-only notices.
- **Shared bottlenecks.** Fix a bottleneck several agents hit once, centrally. Do not pull a worker
  off its task to fix it.
- **Sequential work stays in one agent.** Split only independent work. A handover is for a real
  hand-off, not a way to continue a chain.
- **Accepting worker results.** Record each worker's end state (finished, stopped by limits, taken
  over) and which mechanism actually ran (native path or fallback). Spot-check key rows of any
  extraction against the originals and say the rest is transcribed.

## 6. On an owner STOP

Launch nothing new. Let started runs finish safely, or stop only your own processes by saved PID.
Write one handover that supersedes all earlier statements, and resume only when the owner says so.

## 7. What the owner finds on return

At the top of the campaign's notes, then in one final report:

- the resume point and what is still running (PIDs, where output lands);
- per milestone: passed or failing, with numbers as ranges over stated runs, and what is verified
  versus estimated;
- decisions waiting for the owner, each with options and a recommendation;
- policy or plan changes made, commits made (with repo), commands to reproduce, remaining risk;
- the next task and the goal it serves.

Release what you hold (locks, servers, forwards) before the final report.
