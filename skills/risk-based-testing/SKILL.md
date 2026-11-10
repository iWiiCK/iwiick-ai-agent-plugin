---
name: risk-based-testing
description: Decide what deserves a test and what does not, choose the smallest honest verification scope, and never weaken a check to get green. Use whenever adding, changing, running, pruning or reporting on tests, and when deciding how much to verify before handing work back.
---

# Risk-based testing

Test count is not a quality target. Coverage percentage is not a quality target. The only thing worth optimising is **the chance that a real regression is caught before a user sees it**, divided by the cost of maintaining the tests that catch it.

Two separate questions, answered separately:

1. **What deserves a test?** — risk tiers, below.
2. **What must I run before handing back?** — verification scope, below.

Craft questions — is this test fast, isolated, clear, asserting one concept — belong to `clean-tests`.

## What deserves a test

### Mandatory — a regression here is a real incident

Cover the changed invariant with a focused test, every time:

- **Authorisation and access control** — who may do what, and what happens when they may not.
- **Tenancy, account or ownership boundaries** — anything that could leak one customer's data to another. Assert the scoping, not just the happy path.
- **Query construction and parameter binding** — injection safety, and that the scope predicate is actually present.
- **Money** — payments, pricing, fees, totals, currency, rounding, tax.
- **Persistence and migrations** — data that must survive, and transformations that cannot be re-run.
- **Integration payloads** — the shape you send to and accept from another system.
- **Shared utilities with many consumers** — the blast radius does the arguing for you.
- **Any bug you just fixed** — a test that fails on the old code and passes on the new.

### Judgement — test when the logic can break silently

Stores, resolvers, reducers, state machines, non-trivial component logic, data transformations, caching and invalidation, concurrency and ordering. Add a focused test when there is meaningful branching, a race, a transformation that could silently corrupt, or a failure mode that produces wrong output rather than an error.

A new file or function is not, by itself, a reason for a test.

### Do not test — the cost exceeds the value

Labels, copy, styling, class names, layout, render-only wrappers, prop pass-through, routine wiring of a field into an established form, and anything a type checker already proves. Use typecheck for shape errors and review or manual inspection for appearance.

The exception that is **not** presentational: if the change affects accessibility behaviour, permissions, what is submitted, or what is stored, it is behaviour. Test the behaviour, not the markup.

### Before writing any test, answer this

> *What realistic regression does this catch, and does existing coverage already catch it?*

If you cannot name the regression, do not write the test. If existing coverage catches it, extend that test rather than adding a file.

## Verification scope — what to run before handing back

Pick the smallest scope that honestly covers the behavioural risk, and **say which you picked and why**. Scope follows risk, never file count or which directory you happened to edit.

- **Presentation only** — review the diff, check the affected surface manually where possible. Run existing tests only where they exercise behaviour you actually changed.
- **Scoped behaviour (the default)** — every new or changed test file, plus existing tests covering the changed behaviour and its directly affected consumers. Select by real dependency and failure risk, not by everything that imports a shared barrel.
- **Critical behaviour** — the mandatory list above. Verify the affected safety properties and the relevant end-to-end boundaries with targeted tests. Shared contracts and test infrastructure also need a representative consumer check and a state-reset check.

Plus whatever the project requires always: formatting, lint, typecheck for the changed packages and for consumers when a shared contract changed.

**The full suite is CI's job, not a routine local gate.** Run everything locally only when the human asks, or when a specific cross-cutting risk genuinely cannot be bounded by a focused scope — and explain that risk before you start. Touching a core package, editing three files, or changing test configuration is not by itself a reason to run everything.

Run the chosen scope **once, at the end** of a multi-phase change, not between phases (`implementation`).

## Never weaken a check

Not under any deadline, not to get a green run:

- No skipping, no `only`, no commenting out, no quarantining without agreement.
- No widened timeouts, tolerances or retries to mask flakiness. A flaky test is a bug report about the code or the test — treat it as one.
- No deleted assertions, especially the safety ones.
- No snapshot that replaces a real assertion.
- No loosened types or disabled lint rules to get past a failure.

Fix the production bug rather than changing the expectation — **unless** the behaviour change was deliberate, in which case update the test and say clearly in the handoff that you changed an expectation and why.

Pruning tests is legitimate — obsolete, redundant or purely presentational coverage can go — but only with an explicit rationale and the human's approval for the named deletions. Deleting a *failing* test is never pruning.

## Writing a test that is worth having

Assert outcomes and safety properties, not implementation structure. A test coupled to internals fails when you refactor and passes when you break behaviour — the exact opposite of useful.

Each test should be able to fail for one real reason. Prefer deterministic inputs over randomness; inject the variable rather than depending on real bucketing, real clocks, real networks or real databases. Use the project's existing fakes and stubs; never reach a live service from a unit test.

Mirror the project's test layout and naming conventions exactly.

## Reporting

```
Risk tier:    <tier> — <why it applies>
Ran:          <exact commands, and results>
New coverage: <what it protects, and the regression it catches>
Not run:      <what you deliberately skipped, and why that is acceptable>
Failures:     <each one, classified: my regression / pre-existing / environment>
```

If you added no tests, say why in one line. That is a legitimate outcome, but silence is not.

## Forbidden

- Writing a test without being able to name the regression it catches.
- Adding tests to satisfy a count, a quota or a coverage target.
- Testing labels, classes, layout or prop pass-through.
- Reporting a pass broader than what you ran.
- Skipping, weakening or deleting a check to get green.
- Deleting a failing test instead of investigating it.
- Connecting to a live service from a unit test.
