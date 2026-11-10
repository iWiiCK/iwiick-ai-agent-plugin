---
name: clean-code
description: The complete Clean Code rule catalogue (Robert C. Martin, Chapter 17) adapted for modern languages — comments, functions, general design, naming and test craft, with stable rule IDs so violations can be cited precisely. Use when writing, reviewing or refactoring code in any language, and when you need the full catalogue rather than one focused area.
---

# Clean code: the catalogue

The full rule set, with the original IDs preserved so a review can cite `G5` or `N7` and a human can look it up. Focused skills carry the examples: `clean-names`, `clean-functions`, `clean-comments`, `clean-general`, `clean-tests`. `boy-scout` decides *when* to apply them.

These are heuristics with very high hit rates, not laws. A rule that makes a specific piece of code worse loses — but say which rule you are setting aside and why, rather than ignoring it silently.

**Project conventions outrank this catalogue.** Match the surrounding codebase's idioms, formatter and linter even where you would have chosen differently.

## Comments (C1–C5)

| ID  | Rule                                                                          |
| --- | ----------------------------------------------------------------------------- |
| C1  | No metadata in comments — authors, dates, ticket numbers live in version control |
| C2  | Delete obsolete comments immediately                                          |
| C3  | No redundant comments that restate the code                                   |
| C4  | If a comment is worth writing, write it well — brief, correct, about *why*    |
| C5  | Never commit commented-out code                                               |

## Environment (E1–E2)

| ID  | Rule                               |
| --- | ---------------------------------- |
| E1  | One command to build the project   |
| E2  | One command to run the tests       |

## Functions (F1–F4)

| ID  | Rule                                                              |
| --- | ----------------------------------------------------------------- |
| F1  | At most three arguments — beyond that, pass a named object        |
| F2  | No output arguments — return values instead of mutating inputs    |
| F3  | No flag arguments — a boolean parameter means two functions       |
| F4  | Delete dead functions                                             |

## General (G1–G36)

| ID  | Rule                                                                         |
| --- | ---------------------------------------------------------------------------- |
| G1  | One language per file                                                        |
| G2  | Implement the behaviour the reader expects                                   |
| G3  | Handle boundary conditions explicitly                                        |
| G4  | Never switch off a safety mechanism                                          |
| G5  | DRY — one authoritative representation of each piece of knowledge            |
| G6  | Keep abstraction levels consistent — no low-level detail in a high-level module |
| G7  | Base types know nothing about their derivatives                              |
| G8  | Minimise the public surface                                                  |
| G9  | Delete dead code                                                             |
| G10 | Declare variables close to where they are used                               |
| G11 | Be consistent — the same idea gets the same shape everywhere                 |
| G12 | Remove clutter                                                               |
| G13 | No artificial coupling between unrelated things                              |
| G14 | No feature envy — a function should want its own module's data               |
| G15 | No selector arguments                                                        |
| G16 | No obscured intent — clarity beats cleverness                                |
| G17 | Put code where a reader would look for it                                    |
| G18 | Prefer a method on the thing over a function about the thing                 |
| G19 | Use explanatory intermediate variables                                       |
| G20 | A function name says exactly what the function does                          |
| G21 | Understand the algorithm you are writing                                     |
| G22 | Make logical dependencies physical — do not rely on an assumption            |
| G23 | Replace repeated type-switching with dispatch (polymorphism, a lookup table, or a discriminated union with exhaustive handling) |
| G24 | Follow the language's conventions and the project's linter and formatter     |
| G25 | Named constants, never magic numbers or bare strings                         |
| G26 | Be precise — decide about nulls, rounding, concurrency and failure           |
| G27 | Prefer structure to convention when correctness depends on it                |
| G28 | Encapsulate conditionals into well-named predicates                          |
| G29 | Avoid negative conditionals                                                  |
| G30 | A function does one thing                                                    |
| G31 | Make temporal coupling explicit — if order matters, enforce it in the API    |
| G32 | Do not be arbitrary — structure should express intent                        |
| G33 | Encapsulate boundary conditions in one place                                 |
| G34 | One level of abstraction per function                                        |
| G35 | Keep configurable data at the highest level                                  |
| G36 | Law of Demeter — avoid reaching through chains of objects                    |

## Names (N1–N7)

| ID  | Rule                                                        |
| --- | ----------------------------------------------------------- |
| N1  | Choose descriptive names that reveal intent                 |
| N2  | Name at the right level of abstraction                      |
| N3  | Use standard nomenclature — domain terms and pattern names  |
| N4  | Unambiguous names                                           |
| N5  | Name length matches scope size                              |
| N6  | No encodings — no type or scope prefixes                    |
| N7  | Names describe side effects                                 |

## Static and typed languages (S1–S3)

Adapts the original Java-specific rules to any typed language:

| ID  | Rule                                                                              |
| --- | --------------------------------------------------------------------------------- |
| S1  | Keep imports explicit and stable — no wildcard or namespace imports that hide dependencies |
| S2  | Model closed sets as enums or literal union types, not loose constants            |
| S3  | Type the public surface precisely — never `any`, `object` or an untyped dictionary at a boundary; accept `unknown` and narrow |

## Tests (T1–T9)

| ID  | Rule                                                                        |
| --- | --------------------------------------------------------------------------- |
| T1  | Test what can realistically break                                           |
| T2  | Treat coverage as a diagnostic, never as a target                           |
| T3  | A test that documents a non-obvious default earns its keep                  |
| T4  | An ignored test is an unanswered question — fix it or delete it, never hide it |
| T5  | Test boundary conditions                                                    |
| T6  | Test exhaustively around a bug you just fixed                               |
| T7  | Patterns in failures point at the design, not the tests                     |
| T8  | Untestable code is badly designed code                                      |
| T9  | Tests must be fast and must not touch live services                         |

**Scope note:** these rules govern test *craft*. What deserves a test at all is decided by `risk-based-testing`, which takes precedence — it exists precisely so that T1 does not become "test everything".

## How to use this when reviewing

Cite the rule and the fix, not just the complaint:

> `G5` — the tax rate is computed in three places; extract `TAX_RATES` and one `applyTax`.
> `F3` — `render(isTest)` does two things; split into `renderTestPage` and `renderProductionPage`.
> `S3` — the handler accepts `any`; type the payload and narrow at the boundary.

When you fix something, report it the same way: *"Extracted `SECONDS_PER_DAY` (G25)."*

Suggest incremental improvements, never a rewrite, and keep cleanup proportional to the change you were asked to make (`boy-scout`).

## Provenance

The rule catalogue and the `clean-*` family derive from **[clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents)** by Ertuğrul Demir (MIT), itself a distillation of Robert C. Martin's *Clean Code*, Chapter 17.

| | |
| --- | --- |
| Upstream | `https://github.com/ertugrul-dmr/clean-code-skills.git` |
| Synced from | `1b6b3cc1264b8fbe921c65002d05a3bf90ede178` (2026-04-21) |
| Local family | `clean-code`, `clean-names`, `clean-functions`, `clean-comments`, `clean-general`, `clean-tests`, `boy-scout` |

### Deliberate departures from upstream

Keep these when re-syncing; they are decisions, not drift:

1. **Language-neutral.** Upstream ships parallel Python and TypeScript tracks with colliding skill names. This family is one language-agnostic set, with the Java-specific `J1–J3` generalised to `S1–S3` for any typed language.
2. **`risk-based-testing` outranks `T1–T9`.** Upstream's "test everything that could break / don't skip trivial tests / use coverage tools" contradicts risk-based verification. Here, `clean-tests` owns test *craft* and `risk-based-testing` owns *what deserves a test at all*.
3. **`G23` is dispatch, not class hierarchies.** Stated as lookup tables and discriminated unions first, since class polymorphism is one implementation of the rule rather than the rule.
4. **Project conventions win.** An explicit precedence rule that upstream does not state.
5. **One plugin, flat skill names.** Shipped as the `iwiick` plugin, so the plugin namespace (`/iwiick:clean-code`) distinguishes these from third-party skills without a prefix on every name.

To re-sync, use `clean-code-update`.
