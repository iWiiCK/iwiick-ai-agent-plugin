---
name: system-analysis
description: Understand how a system actually works before changing it — trace a behaviour end to end with file and line evidence, quantify what it costs, test whether the pattern generalises, and present solution approaches with honest trade-offs. Use for "how does X work", "why is X slow", "is this a problem elsewhere", architecture review, or any investigation that precedes a plan.
---

# System analysis

The purpose of analysis is to replace belief with evidence. You are finished when you can describe the mechanism, show where it lives, say what it costs, and state which parts you did not check.

## 1. Frame the question

Write down, in one or two lines: the behaviour under investigation, the entry point the user actually triggers, and what a satisfying answer would contain. Analysis without a stated question sprawls.

Watch for the **wrong entry point** — the single most expensive mistake in this stage. If the user clicks a row and you analyse the route you *assume* that opens, you may optimise a page nobody visits. Find the link, the handler, the dispatch; prove the entry point before tracing from it.

## 2. Trace end to end

Follow one concrete request the whole way and back:

> trigger → client state → transport → server handler → authorisation and tenancy resolution → data access → external calls → response assembly → client render

At every hop record the **file and line range**, and the name of the function. Read the code; never infer behaviour from a filename, a type, or a function's name. Names lie — `getConfig` may write, `loadX` may load everything.

Produce the chain as an ordered list a human can walk with you. If a hop fans out, say how wide. If a hop repeats, say how many times.

## 3. Quantify

A trace tells you the shape; numbers tell you whether it matters. For the traced path, count what you can actually count:

- **Round trips** — queries, HTTP calls, cache reads, file reads. Per request, not per function.
- **Fan-out** — anything inside a loop or a `map` over results. `N` requests hiding behind one call is the classic finding.
- **Volume** — rows returned, bytes transferred, size of the largest payload. Look specifically for large text/blob columns and unbounded `SELECT`s.
- **Sequencing** — how many strictly sequential waves exist, and which of them could run concurrently.
- **Concurrency limits** — pool sizes, connection caps, rate limits, worker counts. A fan-out of 40 behind a pool of 6 is a queue, not a fan-out.
- **Repetition across the request** — the same expensive call made twice because two callers each need it.

Get these from the system where possible: query logs, server timings, instrumentation, a counting query. Where you have to reason instead of measure, label it clearly as reasoning.

**Record the method next to every number.** A number without its method cannot be re-measured later, which makes any later "improvement" unprovable.

## 4. Separate the cause from the correlation

Fast components can compose into a slow system. Before concluding, ask:

- Is each step slow, or are there simply too many of them?
- Is the work itself expensive, or is it waiting for a shared, limited resource?
- Does the volume scale with the user's data, with the tenant's data, or with the whole table? (Cross-boundary scans hide here.)
- Is this on the critical path to first paint, or after it?
- Does it happen on every request, or only cold?

The common shape: every individual operation is fast and every measurement looks fine, yet the whole is slow because of count, contention and payload size. Do not stop at "the queries all run in 20ms".

## 5. Test whether the pattern generalises

A finding at one endpoint is a hypothesis about the codebase. Deliberately go looking for the same shape elsewhere: the same helper called from other handlers, the same unbounded load, the same missing scope predicate, the same sequential waterfall on sibling routes.

Report it as a **list with counts** — "this helper is called by 9 handlers; 6 of them only need two of its five queries" — not as "this probably happens elsewhere too". If you claim a breadth, you must be able to enumerate it.

This step is what turns a local fix into a systemic one, and it is the step most often skipped.

## 6. Present approaches, not a single answer

Give the human real choices, usually two to four, ordered by effort-to-value:

For each: **what it changes**, **what it buys** (quantified or honestly estimated), **what it costs** (effort, risk, new failure modes), **what it rules out later**.

Then state your recommendation and why. Flag any approach that needs a decision only the human can make — infrastructure spend, schema change, behaviour change visible to users, anything that touches money or data retention.

Do not write a plan yet. Approaches first, agreement, then `change-planning`.

## 7. State the boundary of your analysis

Close with what you did not examine and why: paths not traced, numbers estimated rather than measured, environments not checked (cold start, production data volumes, concurrency under load). This is not hedging — it is the part of the report that prevents false confidence.

## Output shape

```
Question:        <what was asked>
Entry point:     <the real one, with evidence it is the one used>
Flow:            <ordered hops, each with file:line>
Cost:            <counted round trips / fan-out / volume / waves / limits, each with its method>
Root cause:      <the mechanism, distinguished from its symptoms>
Generalises to:  <enumerated list of other places with the same shape>
Approaches:      <2-4, each with buys / costs / rules out>
Recommendation:  <one, with reasoning>
Not examined:    <explicit gaps>
```

## Forbidden

- Tracing from an assumed entry point without proving it is the one used.
- Describing behaviour from a name, signature or type instead of the body.
- Any count, size or duration you cannot reproduce.
- "This pattern probably exists elsewhere" without the enumerated list.
- Collapsing to one approach when the trade-off is genuinely the human's to make.
- Editing code. Analysis reads; it does not fix.
