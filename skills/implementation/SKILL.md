---
name: implementation
description: Execute an approved plan well — follow existing conventions, work phase by phase, batch verification to the end, keep the diff to the agreed scope, and hand back with an honest account of what ran. Use whenever editing code against a plan or an agreed change.
---

# Implementation

Implementation is the stage where discipline pays and improvisation costs. The plan decided *what*; this skill is about doing it without surprises.

## Before the first edit

Confirm all three, explicitly:

1. **The plan is approved.** If not, you are still in `change-planning`.
2. **You know the conventions.** Read neighbouring code before writing new code: how this codebase structures modules, names things, handles errors, validates input, accesses data, writes tests. Mimic it. Your preferences lose to the codebase's patterns.
3. **You know the real dependencies.** Never assume a library is available because it is popular. Check the manifest. If a dependency is genuinely needed, add it with the package manager rather than hand-editing the manifest, prefer a version that has been published long enough to be vetted, and avoid floating ranges that resolve to brand-new releases.

## Edit, don't recreate

Search for the existing file, function or component and edit it. Creating a parallel implementation because the original was hard to find is the most common way agents produce duplication.

Prefer the smallest change that fully solves the problem. Collapse duplicate branches, avoid needless nesting, share abstractions that already exist. Do not add defensive error handling at every line — think about where the real boundaries are and handle them there.

Do not add or remove comments that were not part of the change. If you delete an existing comment by accident, put it back.

## Work phase by phase

Execute the phases in order. Complete one before starting the next. If a phase turns out to be wrong, stop and revise the plan rather than improvising a different route silently.

Track progress visibly for multi-phase work, and keep exactly one phase in flight.

## Verify once, at the end

Run the project's formatting, lint, typecheck and tests for the chosen risk tier **once, after the final phase** — not between every phase. The same failures surface at the end, where they are fixed in one pass. Running a test file you have just written is always fine; it is cheap.

This governs *when*, never *whether*. The end-of-work run is mandatory.

Verify mid-change only when a later phase would silently build on a broken earlier one — which is narrower than it sounds. The cases that qualify:

- A **generated artifact** a later phase consumes. Run the generator and look at the output.
- A **shared type or core-package change** later phases code against.
- A **schema change** whose shape later phases read or write.
- A **new abstraction several later phases depend on**, where getting it wrong means redoing all of them.

Then verify *that one thing* and nothing else. A self-contained phase — a new module with its own tests, a prompt edit, a docs pass — gets no isolated run; carry on and let the final run catch it.

The honest cost of batching is that a failure is attributed less precisely. In practice that is cheap: the suite names the file and the case.

## Scope

The diff should contain the agreed change and nothing else. Two legitimate exceptions:

- **Boy-scout cleanups**: small, obviously safe improvements to code you are already touching — a name, a magic number, a dead import. Report them. See `boy-scout`.
- **Blocking defects**: something genuinely broken that prevents the plan from working. Fix it, and call it out separately in the handoff.

Anything else you notice goes in the follow-ups list for the human to decide. Do not silently expand, and do not silently drop a requested item — if something looks infeasible, keep it on the list and say what blocked you.

## When something unexpected appears

- **The plan's assumption was wrong** → stop, say so, revise the plan, get agreement. Do not quietly substitute a different approach.
- **A check fails for a pre-existing reason** → investigate enough to tell the difference between your regression and a pre-existing failure, then report which it is. Never hide it, and never delete the failing check.
- **The fix requires a destructive or irreversible step** → describe exactly what you would run and wait for approval for that specific action.
- **You are stuck** → try other angles, read the surrounding system, search for prior art in the repo. Escalate rather than guessing on anything involving credentials, permissions, environment configuration or cost.

## Security, always

Never log or expose secrets. Never commit credentials. Never weaken a security or compliance control to get a build green — escalate instead. Validate input at trust boundaries. Keep data access scoped to the caller's authorisation, and treat any multi-tenant or per-account boundary as a safety property, not a filter.

## Handing back

State, honestly:

- What changed, described as behaviour rather than a list of files.
- Why — the cause, not just the instruction.
- The risk tier and why it applies.
- The exact commands that ran, and their results.
- **What you did not verify**, and why that is acceptable.
- The infrastructure/migration/deployment decision, explicitly, including "none required".
- Follow-ups and anything that still worries you.

Write the commit message for the shell the human actually uses, in the format the project asks for, carrying *why* in the body — the diff already carries *what*. Do not create the commit unless the project's rules allow it.

## Forbidden

- Editing code before the plan is approved.
- Introducing a library without checking it is already a dependency.
- Recreating a file that already exists.
- Reporting a full pass when a subset ran.
- Disabling, skipping or loosening a check to get green.
- Expanding scope without agreement, or dropping a requested item without saying so.
- Committing when the project forbids it, or pushing without being asked.
