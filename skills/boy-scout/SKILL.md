---
name: boy-scout
description: Leave every file you touch a little cleaner than you found it — one small, safe, reported improvement alongside the change you were asked to make. Use when editing, fixing or refactoring existing code, and on prompts like "while you're at it", "any quick wins", "tidy this up", "anything else obviously wrong".
---

# The boy scout rule

> "Always check a module in cleaner than when you checked it out." — Robert C. Martin

You do not have to make a module perfect. You have to make it **slightly better** than you found it. Small improvements compound; the absence of them is how codebases rot.

This skill orchestrates the focused clean-code skills. It answers *when* and *how much*, not *what good looks like*.

## The deal

Complete the requested change first. Then make **one** adjacent improvement to code you were already in, and **report it**.

That last part is not optional. An unreported cleanup is an unexplained diff line, and it makes review harder rather than easier — which is the opposite of the point.

## What qualifies

Safe, local, obvious, and reviewable at a glance:

- Rename a variable or function whose name misleads → `clean-names`
- Delete a redundant, obsolete or commented-out comment → `clean-comments`
- Remove dead code or an unused import
- Replace a magic number or bare string with a named constant → `clean-general`
- Extract a deeply nested block into a well-named function, or flatten it with a guard clause → `clean-functions`
- Collapse a duplicated branch you can see in the same function
- Add a missing boundary check you can prove is needed

## What does not qualify

- Anything that changes behaviour. If it changes behaviour, it is a separate change needing its own agreement.
- Anything outside the files your task already touches.
- Reformatting a file the formatter did not ask you to reformat.
- Restructuring a module, renaming across the codebase, or changing a public interface.
- A refactor you cannot verify with the test scope you are already running.
- "Improvements" to a file whose conventions you do not yet understand — read it properly first, or leave it alone.

## Proportionality

Keep the cleanup smaller than the task. A one-line bug fix justifies a one-line tidy, not a 200-line refactor. If the file needs real work, say so and offer it as a follow-up — do not smuggle it in.

When a diff is under review, every unrelated line costs the reviewer attention. Spend that budget deliberately.

## Pushing back the other way

Sometimes the honest answer is **no cleanup**. A file you do not understand, a hot path under a deadline, a security-sensitive function, or a module someone else is actively changing — leave it, and say why. "Didn't touch anything else here; that module is mid-migration" is a good answer.

## When reviewing rather than editing

Load `clean-code` for the full catalogue, cite violations by rule ID, and propose incremental fixes ranked by value. Never propose a rewrite.

## Reporting

One line, in the handoff, naming the rule:

> Also cleaned up: extracted `RETRY_LIMIT` from the literal `5` (G25); removed an unused import.

## Forbidden

- Cleanup that changes behaviour.
- Cleanup outside the files the task already touches.
- Cleanup you do not report.
- Cleanup larger than the change it accompanies.
- Reformatting beyond what the project's formatter does.

---

Derived from [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents) (MIT), adapted to be language-neutral. Full catalogue and sync record: `clean-code`. To re-sync: `clean-code-update`.
