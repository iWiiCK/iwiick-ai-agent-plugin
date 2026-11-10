---
name: clean-comments
description: Comment only what the code cannot say itself — no metadata, no redundancy, no commented-out code, no stale docs, and explain why rather than what (C1-C5). Use when writing or reviewing comments and doc blocks, and on commented-out blocks, TODO banners, author/date/ticket metadata, or docs that no longer match the code.
---

# Clean comments

> The best comment is the code that did not need one.

A comment is a failure to express something in code — sometimes a necessary one. Every comment is also a maintenance liability, because nothing enforces that it stays true. Write few, and make them earn their place.

## The default: refactor instead

Before writing a comment explaining *what* code does, try a better name (`clean-names`), an explanatory intermediate variable, or an extracted function (`clean-functions`). That version cannot go stale.

```ts
// Bad
// check if the user is eligible for the discount
if (u.age > 65 && u.years > 5 && !u.suspended) { … }

// Good — the condition names itself
if (isEligibleForLoyaltyDiscount(user)) { … }
```

## C1 — No metadata in comments

No authors, no dates, no ticket numbers, no change history. Version control owns all of it, keeps it accurate, and does not drift.

```ts
// Author: Alice — Modified: 2024-01-15 — JIRA-4821   ← delete
```

## C2 — Delete obsolete comments immediately

A comment describing code that no longer exists is worse than no comment: it actively misdirects. When you change code, read the comments around it and fix or delete them in the same edit.

This applies with full force to doc blocks whose parameters, return types, thrown errors or examples no longer match the signature.

## C3 — No redundant comments

If the comment restates the code, delete it.

```ts
i += 1 // increment i                      ← noise
user.save() // save the user               ← noise

i += 1 // the display is 1-indexed         ← earns its place
```

## C4 — If it is worth writing, write it well

Be brief, be grammatical, be specific, and explain **why** — the reason, the constraint, the non-obvious consequence. The code already shows *what*.

Comments that genuinely earn their place:

- **Why this and not the obvious thing**: "Sequential on purpose: the API rate-limits concurrent writes per account."
- **A non-obvious consequence**: "Must run before the cache is warmed, or stale brands leak across tenants."
- **A workaround with its cause**: "Upstream returns 200 with an empty body on timeout; treat empty as failure."
- **A legal, regulatory or business rule** a reader could not infer.
- **A deliberate performance trade-off**, with the measurement that justified it.
- **A warning of consequences**: "Not idempotent — retrying double-charges."

## C5 — Never commit commented-out code

```ts
// function oldCalculateTax(income: number) {
//   return income * 0.15
// }
```

Delete it. Nobody knows how old it is, whether it works, or whether it is safe to restore — so nobody ever will delete it, and it accretes. Version control has the old version.

## TODO, FIXME and friends

A `TODO` in committed code is a note to nobody. Either do it, or put it where work is actually tracked. If the project genuinely uses in-code markers, follow its convention and make the comment actionable — what, and the condition under which it becomes necessary. Never leave a bare `// TODO: fix this`.

## Doc blocks

Document the public surface — what the caller needs that the signature cannot express: units, ranges, error conditions, idempotency, ordering guarantees, side effects, thread or concurrency expectations. Do not restate parameter names and types the signature already declares.

Internal functions rarely need a doc block. If one does, that is usually a hint the name or the shape is wrong.

## Checklist

- [ ] Could a rename, a variable or an extraction replace this comment?
- [ ] Any metadata to strip? (C1)
- [ ] Does every surviving comment still match the code? (C2)
- [ ] Any comment that restates its code? (C3)
- [ ] Does each remaining comment explain *why*, briefly and precisely? (C4)
- [ ] Any commented-out code to delete? (C5)
- [ ] Any bare TODO that should be tracked properly or acted on?

## Note for agent edits

Do not add or remove comments that are not part of the change you were asked to make — beyond one reported boy-scout cleanup (`boy-scout`). If you delete an existing comment by accident, put it back.

---

Derived from [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents) (MIT), adapted to be language-neutral. Full catalogue and sync record: `clean-code`. To re-sync: `clean-code-update`.
