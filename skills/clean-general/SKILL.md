---
name: clean-general
description: Core design principles — DRY, single responsibility, named constants, clear intent, dispatch over repeated type-switching, encapsulated conditionals and boundaries, Law of Demeter, dead code removal (G3, G5, G9, G16, G23, G25, G28, G30, G31, G33, G36). Use when reviewing or refactoring code quality, and on duplicated logic, magic numbers, long if/else chains, property-access trains or functions juggling responsibilities.
---

# General design principles

The highest-value rules from the catalogue, with the reasoning. The full list lives in `clean-code`.

## G5 — DRY

Every piece of knowledge has exactly one authoritative representation.

```ts
// Bad — the rate exists in three places and will diverge
const caTotal = subtotal * 1.0825
const nyTotal = subtotal * 1.07

// Good — one source of truth
const TAX_RATES = { CA: 0.0825, NY: 0.07 } as const
function totalWithTax(subtotal: number, state: keyof typeof TAX_RATES) {
  return subtotal * (1 + TAX_RATES[state])
}
```

Duplication of *knowledge* is the problem, not duplication of characters. Two functions that look alike but answer to different reasons for change should stay apart — coupling them is worse than repeating them. Ask: "when this rule changes, must both copies change?" Only then extract.

## G25 — Named constants, never magic values

```ts
if (elapsed > 86400) { … }                 // 86400 what?
if (elapsed > SECONDS_PER_DAY) { … }
```

Applies to bare strings as well: status values, role names, event names, queue names, feature keys. A typo in a magic string is a runtime bug; a typo in a named constant is a compile error (`S2`).

## G16 — No obscured intent

Clever is not a virtue. The reader is you, in six months, at speed.

```ts
return ((x & 0x0f) << 4) | (y & 0x0f)      // ?
return packCoordinates(x, y)
```

Nested ternaries, dense one-liner chains and implicit coercions all buy brevity with comprehension. Trade the other way.

## G23 — Dispatch over repeated type-switching

One `if`/`switch` on a kind is fine. The *same* switch appearing in several places is the smell — every new kind means hunting down every site.

Replace it with whatever your language and codebase do idiomatically: a lookup table, a discriminated union with exhaustive handling, a strategy map, or polymorphism.

```ts
// Bad — this shape will reappear in five other functions
function pay(e: Employee): number {
  if (e.type === "salaried") return e.salary
  if (e.type === "hourly") return e.hours * e.rate
  return e.base + e.commission
}

// Good — one table, exhaustively checked by the compiler
const PAY: { [K in Employee["type"]]: (e: Extract<Employee, { type: K }>) => number } = {
  salaried: (e) => e.salary,
  hourly: (e) => e.hours * e.rate,
  commissioned: (e) => e.base + e.commission,
}
```

In a functional or component-oriented codebase, reach for the union-plus-table form before introducing a class hierarchy. Class polymorphism is one valid implementation of this rule, not the rule itself.

## G28 / G29 — Encapsulate conditionals, avoid negatives

```ts
if (!record.isNotArchived) { … }                    // two negatives, one headache
if (isArchived(record)) { … }
```

A boolean expression with more than two clauses wants a name. Naming it makes the call site readable and gives the concept one place to live.

## G30 — One responsibility

If you can extract another function with a meaningful name, the original did more than one thing. At module level the same applies: a file that both builds queries and formats currency has two reasons to change.

## G3 / G33 — Boundary conditions, encapsulated

Decide explicitly about empty, zero, one, maximum, missing, duplicate and out-of-order — and keep the decision in one place rather than scattering `length - 1` and off-by-one arithmetic across the file.

Empty input is the most frequently forgotten case and the most frequently expensive: an empty list should short-circuit, not fan out into work that produces nothing.

## G31 — Make temporal coupling explicit

If `b()` must run after `a()`, do not rely on a comment or on luck. Make `a()` return what `b()` needs, or expose one function that does both in order. Hidden ordering requirements fail silently and intermittently.

## G36 — Law of Demeter

```ts
const dir = context.options.scratch.absolutePath   // knows three layers of someone else's shape
const dir = context.scratchDir()
```

Each `.` past the first couples you to a structure you do not own. Long optional-chain trains (`a?.b?.c?.d`) usually signal the same problem, plus uncertainty about what is actually guaranteed.

## G9 / G12 — Delete dead code and clutter

Unused functions, unreachable branches, unused imports, empty catch blocks, abandoned feature flags, variables assigned and never read. Delete them. Version control is the archive, and dead code costs every future reader an investigation.

Check for non-obvious callers first — reflection, string registries, dependency injection, public exports, tests.

## G35 — Configuration at the top

Configurable values belong at the highest level and get passed down. Reading an environment variable in the middle of a data-access function makes it untestable and unpredictable.

## Review checklist

- [ ] Duplicated knowledge that must change together? (G5)
- [ ] Magic numbers or bare strings? (G25)
- [ ] Clever code that could be plain? (G16)
- [ ] The same type-switch in more than one place? (G23)
- [ ] Multi-clause or negated conditionals that want a name? (G28, G29)
- [ ] Functions or modules with more than one reason to change? (G30)
- [ ] Empty, zero, one and maximum handled — and in one place? (G3, G33)
- [ ] Hidden ordering requirements? (G31)
- [ ] Property-access trains? (G36)
- [ ] Dead code, unused imports, empty catches? (G9, G12)
- [ ] Configuration read at the point of use instead of injected? (G35)

Project conventions and the surrounding code's idioms outrank every rule here (`G24`). When you set a rule aside, say which and why.

---

Derived from [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents) (MIT), adapted to be language-neutral. Full catalogue and sync record: `clean-code`. To re-sync: `clean-code-update`.
