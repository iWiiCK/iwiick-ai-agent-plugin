---
name: clean-names
description: Name things so the code explains itself — descriptive, unambiguous, right level of abstraction, length matched to scope, no type encodings, and side effects visible in the name (N1-N7). Use when naming or renaming variables, functions, types, modules or files, and on cryptic identifiers, Hungarian notation, interface prefixes or misleading function names.
---

# Clean names

A name is the cheapest documentation there is, and the only kind that cannot go stale without the compiler noticing. **If a name needs a comment to explain it, the name is wrong.**

## N1 — Descriptive names reveal intent

```ts
const d = 86400                        // what is d?
const SECONDS_PER_DAY = 86400          // obvious

function proc(v: number[]) { … }       // does what?
function filterPositiveAmounts(amounts: number[]) { … }
```

Searchability matters as much as readability: you can grep `SECONDS_PER_DAY`, not `86400`.

## N2 — Name at the right level of abstraction

Name what it means, not how it is stored. The implementation will change; the meaning should not.

```ts
getMapOfUserIdsToNames()   // leaks the data structure
getUserDirectory()         // survives a refactor
```

## N3 — Use standard nomenclature

Reach for the vocabulary the reader already has: the domain's terms (`premium`, `deductible`, `settlement`) and well-known pattern names (`Factory`, `Repository`, `Adapter`). A shared word beats an invented one, and an invented one beats a vague one.

Be consistent across the codebase: pick one of `fetch` / `get` / `load` / `read` per meaning and hold the line (`G11`).

## N4 — Unambiguous names

```ts
rename(source, target)                  // renaming what? paths? keys?
renameFile(oldPath, newPath)
```

Beware near-identical names for different things (`AccountInfo` vs `AccountData`), and single names covering two concepts.

## N5 — Length matches scope

A two-character name is fine in a three-line closure and indefensible at module scope. The further a name travels from its declaration, the more it must carry on its own.

```ts
const total = amounts.reduce((sum, amount) => sum + amount, 0)   // fine
const MAX = 5                                                     // too thin at module scope
const MAX_RETRY_ATTEMPTS = 5
```

The inverse also holds: a forty-character name inside a one-line lambda is noise.

## N6 — No encodings

Types and scope are the type system's job and the editor's job, not the name's.

```ts
const strName = "Alice"      →  const name = "Alice"
const arrUsers: User[] = []  →  const users: User[] = []
interface IUserRepository    →  interface UserRepository
const m_count = 0            →  const count = 0
```

The one legitimate exception is a project-wide convention you did not invent and should not fight (`G24`).

## N7 — Names describe side effects

A name that hides what the function does to the world is actively dangerous — callers will assume it is safe to call twice.

```ts
// Bad: creates the entry as a side effect
function getConfig(path: string) { … }

// Good: the name admits it
function getOrCreateConfig(path: string) { … }
```

Same rule for functions that write, cache, mutate arguments, emit events, or charge money. If it has a side effect, the name says so — and if the name promises a query, it must not command.

## Checklist

- [ ] Could a new reader guess what this holds or does, without reading the body? (N1)
- [ ] Does the name survive changing the implementation? (N2)
- [ ] Does it use the domain's word, consistently with the rest of the codebase? (N3)
- [ ] Could it be confused with something else nearby? (N4)
- [ ] Is the length proportional to the scope? (N5)
- [ ] Any type, prefix or scope encoding to strip? (N6)
- [ ] Does it disclose every side effect? (N7)

## Renaming safely

A rename is a refactor. Use the language tooling rather than find-and-replace; check strings, serialised keys, database columns, API fields, translations and documentation before assuming a symbol rename is complete. A rename that silently changes a wire or storage key is a bug, not a cleanup.

Keep renames proportional and reported (`boy-scout`).

---

Derived from [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents) (MIT), adapted to be language-neutral. Full catalogue and sync record: `clean-code`. To re-sync: `clean-code-update`.
