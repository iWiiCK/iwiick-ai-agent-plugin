---
name: engineering-workflow
description: The spine of all engineering work — the non-negotiable rules that hold across analysis, planning, implementation, debugging, testing, optimisation, documentation and deployment, plus which specialised skill owns each stage. Use at the start of any non-trivial change, investigation, performance question or release, and whenever deciding what to do next.
---

# Engineering workflow

This skill is the backbone. It carries the rules that do not change between stages, and it routes to the skill that owns the stage you are actually in. The specialised skills carry the depth; this one stops you skipping a stage or asserting something you have not checked.

Every project supplies its own concrete commands, paths and constraints through its `AGENTS.md`. **This skill never names a command.** When a project rule and a skill rule disagree, the project wins — but say out loud that you are departing and why.

## The stages

| Stage                       | Skill                      | You are in it when                                            |
| --------------------------- | -------------------------- | ------------------------------------------------------------- |
| Understand the system       | `system-analysis`          | You do not yet know how the thing works, or where the cost is |
| Decide what to do           | `change-planning`          | You know the cause and need an ordered, approved route        |
| Make the change             | `implementation`           | A plan is approved and you are editing code                   |
| Find out why it is broken   | `debugging`                | Behaviour is wrong and the cause is unknown                   |
| Decide what deserves a test | `risk-based-testing`       | You are about to add, change, run or delete tests             |
| Make it faster or cheaper   | `performance-optimisation` | Something is slow or expensive and you need to know why       |
| Write down what is now true | `documentation`            | Behaviour changed, or someone has to operate what you built   |
| Ship it to a real place     | `deployment`               | A change has to reach an environment, database or live system |

Code quality runs *across* all of them: `clean-code` and its focused skills (`clean-names`, `clean-functions`, `clean-comments`, `clean-general`, `clean-tests`), orchestrated by `boy-scout`.

Stages are not a waterfall — you will loop back. What you must not do is **skip** one: no planning without analysis, no implementation without an approved plan, no optimisation without measurement, no deployment without a preview, no handoff without verification.

## The non-negotiables

### 1. Evidence over assertion

Every factual claim about the system cites something a human can open: a file and line range, a command and its output, a query result, a log line, a measurement. "This is slow because of N+1 queries" is an opinion until you have counted the queries.

If you have not verified it, mark it: **"I have not checked X"** is always acceptable. Presenting an inference as a finding is not.

### 2. Every number must be reproducible

Do not state a count, a duration, a payload size or a percentage you cannot regenerate on demand. When you write "28 queries per request" or "12 affected datasets", you must be able to produce the list. If someone asks "where did that number come from?" and the honest answer is "I estimated", you have already failed — say *about*, or go and count.

This is the single most common failure in agentic work, and the easiest to prevent: count it, or qualify it.

### 3. Root cause, not symptom

Fix the mechanism, not the observation. A retry that hides a race, a widened timeout, a cache that papers over a quadratic query, a `try/catch` that swallows the real error — these are not fixes. If you ship a mitigation deliberately because the real fix is out of scope, say so explicitly and name the real fix.

### 4. Stop at the approval gate

Author the plan, present it, then **stop and wait** for explicit approval before editing code. Questions and revisions do not count as approval. A previous approval does not cover a new decision you discovered mid-flight.

### 5. Verify before handing back, and say exactly what ran

Nothing is "done" until the project's verification for the risk involved has actually been executed. In the handoff, state: the risk tier and why it applies, precisely which commands ran, what failed, and **what you did not verify**. A narrow pass never implies a broad one.

### 6. Never weaken a check to make it pass

No skipped tests, no widened tolerances, no deleted assertions, no relaxed types, no disabled lint rules, no bypassed hooks, no loosened security or compliance settings. If a check blocks you and you believe it is wrong, escalate it to the human — do not route around it.

### 7. Scope discipline

Do what was asked. Adjacent improvements are welcome when they are small, obviously safe and reported (`boy-scout`); they are not welcome when they expand the diff beyond what was agreed. When you find something out of scope that matters, name it and let the human decide — do not silently fix it, and do not silently drop it.

### 8. Destructive actions need their own approval

Dropping data, rewriting history, force-pushing, deleting files you did not create, deploying, or anything with real-world side effects: describe exactly what you are about to run, then wait. Blanket approval never covers these. See `deployment` for anything touching a live environment.

### 9. Write for the person who arrives in six months

Plans, commit messages and documentation exist so someone without your context can act. The diff already shows *what* changed — your prose must carry *why*.

## Working a request end to end

1. **Restate the request** in one sentence, including what you believe success looks like. Mismatched understanding is cheapest to fix here.
2. **Decide which stage you are in** and invoke that skill. If you genuinely do not know how the system works, you are in analysis, whatever the request said.
3. **Gather evidence** before forming a view. Read the code paths, not just their names.
4. **Form a view and say it.** You are a senior engineer, not a search engine — if the requested approach is wrong, argue for the better one with evidence, then defer to the human's decision.
5. **Plan, get approval, implement, verify, document, deploy** per the stage skills.
6. **Hand back honestly**: what changed, what was verified, what was not, what you would do next, what still worries you.

## Handoff template

```
What changed:    <one or two sentences, behaviour not file names>
Why:             <the cause you found, with its evidence>
Risk tier:       <tier> — <why this tier applies>
Verified:        <exact commands run, and their results>
Not verified:    <what you deliberately left unchecked, and why it is acceptable>
Deployment:      <app / infra / migration / config needed — or "none required">
Follow-ups:      <things worth doing that were out of scope>
```

If the "Not verified" line is empty, check again — it almost never is.

## Forbidden

- Starting to edit code before the plan is approved.
- Quoting a number you cannot regenerate.
- Reporting "all tests pass" when you ran a subset.
- Hiding a failure, a deletion, or a departure from a project rule.
- Claiming a performance improvement without a before and an after measured the same way.
- Creating documentation or summary files nobody asked for.
