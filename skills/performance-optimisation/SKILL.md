---
name: performance-optimisation
description: Make something measurably faster or cheaper — measure before changing, work through the real cost model (round trips, fan-out, payload, concurrency limits, waterfalls, cold start), fix the dominant term, then re-measure with the same instrument. Use for slowness, latency, timeouts, high cost, scaling problems and "why is this taking so long".
---

# Performance optimisation

Two rules decide whether this work is real engineering or theatre:

1. **Measure before you change anything.** Without a before, there is no after.
2. **Fix the dominant term.** Everything else is noise until it is the dominant term.

Optimisation without measurement is guessing with extra steps, and it routinely makes systems slower and more complex at the same time.

## 1. Define the target

State the operation, the entry point the user actually triggers, the current number, and the number that would count as success. "Make it faster" is not a target; "lead open under one second, warm, at current data volumes" is.

Agree whether you are optimising latency, throughput, or cost. They trade against each other.

## 2. Measure the before

Measure end to end *and* break it down by layer: client, network, server handler, data access, external calls, serialisation, render. You cannot attribute an improvement you cannot localise.

Record for every number: **what was measured, how, where, with what data, warm or cold.** A number without its method cannot be reproduced, and an unreproducible before makes the after meaningless.

Measure more than once. Separate cold from warm explicitly — they have different causes and different fixes. Prefer the system's own instrumentation (request timings, query logs, traces, platform metrics) over a stopwatch.

If the system cannot tell you where the time goes, **adding that instrumentation is the first piece of work**, and it is usually worth keeping.

## 3. Work the cost model

Slowness in a distributed or data-backed system is almost never "the code is slow". Check these in order; the first few explain most real cases:

**Round trips and fan-out.** Count the queries, HTTP calls and cache reads per request. Anything inside a loop or a map over results is the classic N+1. Twenty fast calls beat one slow call only until latency and queueing dominate — which is immediately.

**Concurrency limits.** A fan-out of forty behind a connection pool of six is a queue. Pool sizes, connection caps, worker counts, rate limits and semaphores convert parallelism into serial waiting, and the symptom is that every individual operation still looks fast. Always find the limit and compare it to the fan-out.

**Payload volume.** Rows returned, bytes transferred, and especially large text or blob columns. Loading a megabyte to decide you needed a kilobyte is a pure waste you can usually remove by filtering earlier. Select the columns you need; filter where the data lives, not in application memory.

**Scope and selectivity.** Does the query touch the caller's data, the account's data, or the whole table? Missing scope predicates and aggregates computed across every row before being joined down to one are the most common severe findings, and they get worse as the system succeeds.

**Sequential waterfalls.** Count the strictly sequential waves. Independent work should be concurrent; dependent work should be collapsed into fewer hops. On a client, check what blocks first paint and what could stream or render a skeleton instead.

**Repeated work within one request.** The same expensive call made twice because two callers each needed it. Request-scoped memoisation is cheap and safe.

**Repeated work across requests.** Read-mostly reference data re-fetched on every request is a cache candidate — see below.

**Indexes and query plans.** Read the plan rather than guessing. Scans where a seek is possible, sorts that could be served by an index, and predicates that are not selectable because of a function wrapped around a column.

**Cold start and initialisation.** Clients, pools and credentials constructed per invocation instead of reused. Negative lookups that are never cached, so every miss is a live round trip.

**Serialisation and parsing.** Parsing a large document to read two fields.

## 4. Choose the fix by its dominant term

Rank candidate fixes by the time they actually remove, not by how satisfying they are. Prefer, in order:

1. **Do less work** — filter earlier, select fewer columns, scope the query, skip work that cannot matter (an empty result needs no enrichment).
2. **Do it in fewer hops** — batch, join, collapse waves, make independent work concurrent.
3. **Do it once** — request-scoped memoisation, then cross-request caching.
4. **Do it faster** — indexes, better plans, algorithmic change.
5. **Give it more capacity** — pool and concurrency sizing. Necessary, but it raises the ceiling rather than removing the work; do it *as well as*, never *instead of*.

Deleting work beats caching work. Caching is the last resort disguised as the first, because it adds a correctness problem to a performance problem.

## 5. If you cache, cache honestly

Every cache needs all five, decided before you write it:

- **Key** — including every dimension that changes the answer. A key missing the account or tenant dimension is a data-leak bug, not a performance bug.
- **Scope** — per request, per process, or shared. On per-invocation or autoscaling runtimes, a process cache helps only across requests that land on a warm instance; say what you expect the hit rate to be and why.
- **Bound** — a maximum size and an eviction policy. An unbounded cache keyed by user input is a memory leak and an availability risk. Check the realistic cardinality before you choose: thousands of entries per account is a different design from dozens.
- **Invalidation** — what writes evict it, and what happens in the race between a write and an in-flight read. Prefer explicit invalidation on mutation over hoping the TTL is short enough.
- **Stampede control** — coalesce concurrent misses for the same key, or the first cold request becomes a thundering herd.

Replacing a memoised function with a cache is not automatically a win. Say what it actually buys — usually crossing a boundary the memo could not cross — or do not do it.

## 6. Re-measure with the same instrument

Same method, same data, same warm/cold condition, same place. Report before, after, and the delta per layer. If the dominant term moved somewhere else, say where — that is a real and useful result.

Then check you did not trade correctness for speed: run the project's verification for the risk involved. Scope narrowing, caching and batching all touch data-correctness and authorisation boundaries, which makes most of this work **critical tier** under `risk-based-testing`.

## 7. Report without inflation

```
Target:       <operation, condition, goal>
Before:       <number, with method>
Cause:        <the dominant term, with its evidence>
Change:       <what you did, by cost-model category>
After:        <number, same method>
Delta:        <per layer where you can attribute it>
Now dominant: <where the time goes now>
Not improved: <what you did not fix, and why>
Risk:         <new failure modes introduced, especially cache correctness>
```

Quote improvements only where you measured them. "Should be faster" is not a result. An improvement under warm conditions is not an improvement under cold ones unless you measured that too.

## Forbidden

- Changing anything before you have a before-measurement.
- Any performance number without its method.
- Claiming an improvement you did not measure the same way twice.
- Adding a cache without key, scope, bound, invalidation and stampede control.
- A cache key that omits an account, tenant or user dimension.
- Raising pool or concurrency limits as the only fix, without removing the work.
- Optimising a path you have not proven the user actually takes.
