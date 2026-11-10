---
name: clean-tests
description: Test craft — fast, independent, deterministic tests that assert one concept, cover boundary conditions, and never hide a failure (T1-T9, FIRST). Use when writing or refactoring tests, and on slow or flaky tests, skipped or `.only` tests, happy-path-only coverage, or tests coupled to implementation detail.
---

# Clean tests

This skill is about **how to write a test well**. Whether a given thing deserves a test at all is decided by `risk-based-testing`, which takes precedence — it exists so that "test everything that could break" does not become "test everything".

A test is production code. It is read more often than the code it covers, and a bad one costs more than no test.

## The property that matters

**A test should fail for exactly one real reason, and that reason should be a behaviour someone cares about.**

Two failure modes to design against:

- **Fails when nothing broke** — coupled to markup, structure, call order, timing or internals. This is the test that gets deleted in frustration during a refactor, taking its real coverage with it.
- **Passes when something broke** — asserts something trivially true, mocks the thing under test, or never reaches the branch it claims to cover.

## FIRST

- **Fast** — milliseconds. A suite nobody waits for is a suite nobody runs.
- **Independent** — no shared mutable state, no ordering dependency. Each test sets up what it needs and can run alone or in any order.
- **Repeatable** — same result on any machine, any time of day, any locale, any timezone. Freeze the clock, seed the randomness, fix the locale.
- **Self-validating** — passes or fails. Never "check the log output".
- **Timely** — written with the code, not bolted on afterwards. For a bug fix, written *before* (`debugging`).

## T5 — Boundary conditions are where bugs live

The happy path is the case you already thought about. Cover instead: empty, one, many, maximum; zero and negative; null, undefined and missing versus present-but-empty; first and last; duplicates; out of order; concurrent; expired; unauthorised.

```ts
it("returns zero for an empty basket", …)
it("applies the discount at exactly the threshold", …)
it("rejects a quantity of -1", …)
```

Off-by-one and empty-input cases justify their own tests more often than any other category.

## T6 — Exhaustively test around a bug

Bugs cluster. When you fix one, test its neighbours: the adjacent branch, the boundary either side, the same mechanism on the sibling path. The cost is minutes; the hit rate is high.

## One concept per test

Not one assertion — one *concept*. Several assertions about the same outcome are fine; assertions about four unrelated behaviours in one test tell you nothing about which broke.

```ts
// Bad — one failure hides the other three
it("user", () => {
  expect(user.name).toBe("Alice")
  expect(user.isValid()).toBe(true)
  user.activate()
  expect(user.isActive).toBe(true)
})

// Good — each names its own behaviour
it("is valid when created with a name and email", …)
it("becomes active when activated", …)
```

The test name should state the behaviour, so a failure in CI is diagnostic on its own. `it("works")` is worthless; `it("rejects a quote whose brand belongs to another tenant")` is a specification.

## Arrange, act, assert

Keep the three visibly separate, and keep the arrangement small. If setup dwarfs the assertion, that is a design signal (`T8`) — the unit under test probably has too many dependencies.

Use builders or factories with sensible defaults so each test states **only what matters to it**. A test that sets twelve fields to assert one of them buries its own point.

## Mock at the boundary, never the subject

Stub what you do not own and cannot control — network, clock, filesystem, randomness, third-party services. Do not mock the thing you are testing, and do not assert on how many times an internal helper was called; assert on the outcome.

Over-mocked tests pass while the system is broken, because they only ever test the mocks.

## T9 — Fast, and never live

No real database, no real HTTP, no real queue, no `sleep`. Use the project's existing fakes and in-memory substitutes. If a test needs a live service, it is an integration test and belongs wherever the project puts those — not in the unit suite.

Wait for conditions, never for durations. A `setTimeout` in a test is a future flake.

## T4 / T7 — Never hide a failure

- A skipped test is an unanswered question. Fix it or delete it; do not leave it skipped with "flaky, fix later".
- A committed `.only` silently disables the rest of the file. Never commit one.
- Flakiness is a bug report about the code or the test — race, shared state, time dependence, ordering. Investigate it; do not add a retry.
- When several tests fail together, read the pattern before fixing them individually. A cluster usually names one cause — often shared state that is not being reset between tests.

Never weaken a test to make a run pass: no widened tolerances, no deleted assertions, no snapshot substituted for a real check (`risk-based-testing`).

## T8 — Hard to test means badly designed

If you need extensive mocking, global state, or access to privates, the design is telling you something. Prefer fixing the seam — inject the dependency, extract the pure logic, separate the decision from the side effect — over contorting the test.

## T2 — Coverage is a diagnostic, not a target

Use it to find paths nobody thought about. Never to justify a test, and never as a number to hit. High coverage with weak assertions is worse than honest gaps, because it buys false confidence.

## Checklist

- [ ] Does the name state the behaviour?
- [ ] Can it fail for exactly one real reason?
- [ ] Would it survive a refactor that preserves behaviour?
- [ ] Would it fail if the behaviour broke? (Check by breaking it.)
- [ ] Independent of order and of other tests' state?
- [ ] Deterministic — clock, randomness, locale, timezone all pinned?
- [ ] Boundary cases covered, not just the happy path? (T5)
- [ ] One concept, with arrange/act/assert visible?
- [ ] Mocks only at boundaries, never the subject?
- [ ] Milliseconds, and no live services? (T9)
- [ ] No skipped tests, no `.only`, no retries hiding a race? (T4)

---

Derived from [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents) (MIT), adapted to be language-neutral. Full catalogue and sync record: `clean-code`. To re-sync: `clean-code-update`.
