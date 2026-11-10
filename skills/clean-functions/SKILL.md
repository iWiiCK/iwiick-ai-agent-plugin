---
name: clean-functions
description: Write functions that do one thing and are obvious from the outside — at most three arguments, no output arguments, no flag arguments, no dead functions, one level of abstraction, guard clauses over nesting (F1-F4, G30, G34). Use when writing or refactoring functions, components or handlers, and on long parameter lists, boolean parameters, deep nesting or unused exports.
---

# Clean functions

A function should be small, do one thing, and be understandable from its signature without reading its body.

## F1 — At most three arguments

Beyond three, the call site stops being readable and the order becomes a trap.

```ts
// Bad — what does the fourth boolean mean at the call site?
createUser(name, email, age, country, timezone, language, true)

// Good — named, reorderable, extensible
type NewUser = {
  name: string
  email: string
  country: string
  timezone: string
  subscribeToNewsletter: boolean
}
function createUser(user: NewUser) { … }
```

Two or more arguments of the same type side by side are a bug waiting to happen (`copy(source, target)` — which way round?). Name them in an object or encode the direction in the function name.

The same rule applies to UI component props: past a handful, group them.

## F2 — No output arguments

A function should return its result, not reach into its inputs and mutate them. Mutation through a parameter is invisible at the call site.

```ts
// Bad — caller cannot tell their object was changed
function appendFooter(report: Report): void {
  report.content += FOOTER
}

// Good
function withFooter(report: Report): Report {
  return { ...report, content: `${report.content}${FOOTER}` }
}
```

Where the language and codebase genuinely favour in-place mutation for performance, make it obvious in the name (`sortInPlace`, `mutateX`) and keep it local.

## F3 — No flag arguments

A boolean parameter means the function does at least two things, and the call site reads as a riddle.

```ts
render(true)                    // true what?

renderTestPage()                // two functions, each doing one thing
renderProductionPage()
```

If the two paths share most of their work, extract the shared part and let the two entry points call it. Where a parameter genuinely selects among several modes, use a named union — `render(mode: "test" | "production")` — never a bare boolean.

## F4 — Delete dead functions

If nothing calls it, delete it. No "just in case", no commented-out body, no `_old` suffix. Version control remembers.

Check properly before deleting: dynamic dispatch, string-keyed registries, dependency injection, framework conventions, public package exports and tests can all be real callers that a naive search misses.

## G30 / G34 — One thing, one level of abstraction

If you can extract another function with a meaningful name, the original was doing more than one thing. Mixing levels — high-level orchestration interleaved with byte-twiddling or SQL string building — forces the reader to change gear mid-paragraph.

A reliable test: can you describe what the function does in one sentence, without "and"?

## Guard clauses over nesting

Handle the exceptional cases first and return early. Deep nesting hides the main path.

```ts
// Bad
function price(order) {
  if (order) {
    if (order.items.length > 0) {
      if (order.customer) {
        …
      }
    }
  }
}

// Good
function price(order: Order): Money {
  if (!order.items.length) return Money.zero
  if (!order.customer) throw new MissingCustomerError(order.id)
  …
}
```

Three levels of indentation is a smell; four is a refactor.

## Command–query separation

A function either answers a question or changes something — not both. `isValid()` must not persist. `save()` must not return a different object than you expect. When a function must do both, the name has to say so (`N7`).

## Checklist

- [ ] Three arguments or fewer, and no same-typed pair that could be swapped? (F1)
- [ ] Returns its result rather than mutating inputs? (F2)
- [ ] No boolean flag selecting between behaviours? (F3)
- [ ] Every function here actually called? (F4)
- [ ] Describable in one sentence without "and"? (G30)
- [ ] One level of abstraction throughout? (G34)
- [ ] Guard clauses instead of nesting, three levels or fewer?
- [ ] Queries do not command, and commands do not pretend to be queries?

---

Derived from [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents) (MIT), adapted to be language-neutral. Full catalogue and sync record: `clean-code`. To re-sync: `clean-code-update`.
