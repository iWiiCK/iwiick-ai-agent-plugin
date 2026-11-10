---
name: debugging
description: Find the actual cause of broken behaviour — reproduce it, instrument the path, narrow it to one mechanism, fix the mechanism, then prove the fix with a test that would have caught it. Use for bugs, failures, crashes, flakiness, "why isn't this working", unexpected output, and failing builds or tests.
---

# Debugging

The goal is not to make the symptom go away. It is to know *why* it happened, well enough to state the mechanism in one sentence.

## 1. Reproduce it first

Nothing before this matters. Establish the smallest reliable reproduction: the exact input, environment, and sequence that produces the failure, and how often.

Capture the **real** error — the full message, the stack, the status code, the log lines around it. Agents routinely debug a paraphrase of the error and fix the wrong thing.

If you cannot reproduce it:

- Get the exact environment, version, timing and data from the human. Ask; do not guess.
- Look for what differs between working and failing: environment variables, data shape, concurrency, cold vs warm, authenticated vs not, one record vs many.
- An intermittent failure is a timing, ordering, caching or shared-state problem until proven otherwise. Treat it as a real bug, never as noise.

## 2. Read the error properly

Before forming a theory, decide what the error actually tells you:

- Which layer raised it — client, transport, framework, your code, a dependency, the platform?
- Is it the original failure, or something that caught and re-threw a different one? Chase it to the origin.
- Does the stack name your code? If it only names library frames, find the boundary where your data entered.
- Is the message about the thing you think it is? "Not found", "refused", "unauthorized" and "timeout" are frequently about a different resource than the one you are looking at.

## 3. Trace the path

Follow the failing path from entry point to failure, reading the bodies of the functions involved (`system-analysis` if the system is unfamiliar). State what you expect at each hop, then check it.

Form one hypothesis at a time, make it falsifiable, and test it. "The tenant key is empty by the time it reaches the query" is a hypothesis; "there's probably a race" is not.

## 4. Instrument to narrow it

Add temporary, targeted logging or assertions that distinguish between your competing hypotheses — the value at the boundary, the count, the branch taken, the elapsed time. One well-placed log beats ten speculative ones.

Useful narrowing moves, cheapest first:

- **Bisect the path**: confirm the data is correct halfway, then halve again.
- **Bisect history**: if it used to work, find the change that broke it.
- **Remove variables**: run the unit in isolation; replace a dependency with a stub; use fixed data instead of live.
- **Compare with a working case**: the nearest sibling that works tells you what is different.

Remove all temporary instrumentation before handing back, unless you are deliberately leaving permanent, principled telemetry — in which case say so.

## 5. Name the mechanism

Before fixing, write one sentence: *"X happens because Y, which means Z."* If you cannot write it, you have not found the cause and the fix will be a guess.

Then check the blast radius: the same mechanism almost always exists elsewhere. Go and look, and enumerate what you find.

## 6. Fix the cause

Fix the mechanism named in step 5. These are not fixes:

- A retry or longer timeout over a race or a slow dependency.
- A `catch` that swallows the error.
- A null guard that hides why the value was absent.
- A cache that masks a pathological query.
- Loosening a type, a tolerance or an assertion until the complaint stops.

If you deliberately ship a mitigation because the real fix is out of scope, label it a mitigation, name the real fix, and get agreement.

## 7. Prove it

- Write a test that **fails on the old code and passes on the new** — that is the only proof the cause was real. Add it before the fix where practical.
- Re-run your original reproduction and confirm it is gone.
- For an intermittent bug, run it enough times to mean something, and say how many.
- Verify per the project's risk tier (`risk-based-testing`).

A fix with no failing-then-passing test is a fix you are asking the human to take on faith. Say so if that is what you are doing and why.

## When the failing thing is a test

Decide honestly which of these it is, and say which:

- **A real regression you introduced** → fix the code.
- **A pre-existing or environment-dependent failure** → report it as such, with evidence; do not fold it into your change silently.
- **A deliberate behaviour change** → update the test, and state in the handoff that you changed an expectation and why.

Never delete or skip a failing test instead of understanding it.

## Handing back

```
Symptom:      <what was observed>
Reproduction: <exact steps, and reliability>
Mechanism:    <one sentence: X because Y, so Z>
Evidence:     <file:line, log lines, measurements>
Fix:          <what changed, and why it addresses the mechanism>
Proof:        <the test that fails before and passes after>
Elsewhere:    <enumerated other places with the same mechanism>
Not verified: <what remains unchecked>
```

## Forbidden

- Fixing before reproducing.
- Debugging a paraphrase of the error instead of the error.
- Shipping a symptom suppressor without labelling it as one.
- "Should be fixed now" without a test that distinguishes old from new.
- Leaving temporary debug instrumentation in the diff.
- Deleting, skipping or weakening a failing test to move on.
