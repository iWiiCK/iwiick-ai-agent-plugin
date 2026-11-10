---
name: change-planning
description: Turn an agreed root cause into an ordered, approved, archived plan — phased structure, per-phase verification, the approval gate, and amendments instead of rewrites. Use before implementing any feature, fix, refactor, migration or multi-step change, and whenever the user asks for "a plan" or says "make a plan".
---

# Change planning

A plan exists to make the route reviewable before it is expensive. It is not a summary of intent; it is a document precise enough that someone else could execute it and reach the same result.

Do not plan what you have not analysed. If the cause is still a hypothesis, go back to `system-analysis`.

## The approval gate [MANDATORY]

1. Author the plan.
2. Present it in the conversation.
3. **Stop. Wait for explicit approval.**
4. Only then write the plan to its archive location and begin editing code.

Questions, clarifications and requested revisions are **not** approval — revise and wait again. Do not start implementing because a plan exists, because the change seems obvious, or because you are confident. The gate is the point.

If the plan changes materially during implementation, you need approval for the change, not just for the original.

## Structure

### Header

Date, the goal in a single sentence, and — when superseding an earlier plan — an explicit reference to the plan it revises.

### Root-cause analysis

Numbered findings, each naming the file and line range and quoting the offending code or query where it clarifies. This is what makes the plan auditable later: a reader can check whether the cause was real.

A plan whose analysis section is a restatement of the goal is not a plan.

### Phases

Order the work as explicit, numbered phases — `Phase 0`, `Phase 1`, … — each with:

- **Goal**: one sentence on what is true at the end of this phase.
- **Files**: the exact files it touches.
- **Steps**: concrete changes, with code or query fragments where the shape matters.
- **Verification**: the risk tier and the exact commands for *this* phase's behaviour.

**Phase 0 is groundwork** — shared types, schema, configuration, helpers — the things later phases build on. Sequence phases so that each one leaves the system working. A phase that only makes sense once the next one lands is really half a phase; merge them.

Genuinely small changes — a handful of lines across one or two files — may be a short flat checklist instead. Do not phase for ceremony.

### Verification plan

What proves the change worked, at the whole-plan level: the tests that must exist, the measurements to repeat, the manual checks a human must perform. For performance work, state the before-measurement and the instrument, so the after is comparable (`performance-optimisation`).

### Infrastructure and data decisions

State explicitly whether the plan requires deployment, migration, schema change, configuration change or new infrastructure — including "none required". Silence here is a defect; it is the item most often discovered too late.

### Risks and rollback

What could go wrong, what you would see if it did, and how to undo it. Name the irreversible steps separately — they need their own approval at execution time.

## Sizing phases

A good phase is reviewable in one sitting and independently verifiable. If a phase touches thirty files across four concerns, split it. If two phases touch the same six lines, merge them.

Order by dependency first, then by risk: get the groundwork and the safety-critical changes in early, where they get the most scrutiny.

## Amendments, not rewrites

An archived plan is a record of what you were instructed to do. Its value is that it is exactly that, unedited.

- Never edit, reformat, renumber or delete an archived plan.
- Never add progress notes or outcomes to it.
- When the approach changes, write a **new** plan that references the one it revises, and leave the original untouched.
- When a scope addition is agreed mid-flight, write an **amendment** that names the plan it extends.

Do not tidy, consolidate or re-index an archive. Stale content in an old plan is not an error; it is history.

## Secrets

Never put credentials, connection strings, keys, tokens, customer data or personal data in a plan. An archived plan cannot be scrubbed after the fact, so hold it to a stricter standard than ordinary code.

## When the request is bigger than the plan

If the work is genuinely open-ended, plan the next increment and say so, rather than authoring a speculative plan for phases you cannot yet specify. A plan with a vague Phase 5 teaches nobody anything; a plan with three concrete phases and an honest "we will plan the rest once Phase 2 lands" is useful.

## Pushing back

If you think the requested scope is wrong — too large, mis-targeted, or chasing a symptom — say so in the plan presentation, with evidence, and propose the alternative. State the trade-off plainly and then accept the human's decision. Silent compliance with a bad plan is not service.

## Forbidden

- Writing the plan file, or touching code, before approval.
- A root-cause section without file and line evidence.
- Phases that cannot be verified independently.
- Omitting the infrastructure/migration decision.
- Editing or "correcting" an archived plan.
- Secrets or personal data anywhere in a plan.
