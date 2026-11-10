---
name: deployment
description: Ship a change to a real environment safely — decide what actually needs deploying, preview before applying, stop for explicit approval, order dependent steps correctly, verify after, and know how to roll back. Use for deployments, releases, infrastructure changes, database migrations, configuration or secret changes, and any operation against a live environment.
---

# Deployment

Deployment is the stage where mistakes are expensive and some are permanent. The discipline is simple and non-negotiable: **know what you are changing, show it before you do it, wait to be told to go, verify afterwards, and be able to undo it.**

Everything here applies to any change against a real environment — application deploys, infrastructure definitions, schema migrations, configuration, secrets, feature state, queue and scheduler changes.

## 1. Decide what actually needs deploying

At the end of every change, state explicitly — including when the answer is "nothing" — whether each of these is required:

- **Application deployment**, and which services.
- **Infrastructure deployment**, and which stacks.
- **Database migration**, and whether it is reversible.
- **Schema or permission grants** that are applied separately from migrations.
- **Configuration or environment variables**, including new ones that must exist before the code runs.
- **Secrets**, which are never printed and never committed.
- **Scheduled jobs, queues, triggers or workers** whose definitions changed.

Silence here is a defect. "No deployment required" is a valid and useful answer; not saying is not.

Derive the answer from the diff — which files changed and what consumes them — not from memory.

## 2. Preconditions

Before touching anything:

- **Confirm the target environment, out loud.** Never infer it. If multiple environments exist, the human names the one you are deploying to, and you deploy only that one.
- **Check the parameter, environment and configuration files are in place** for that environment, and that any new configuration value exists there *before* the code that reads it ships.
- **Ask only for what this deployment needs** — the credentials, subscription or account identifiers, and network access for these environments, not all of them.
- **Record the current state** you are about to change: the running version, the current configuration, the active default account or context. You cannot restore what you did not write down.
- **Confirm you are on the right revision** — the branch and commit you intend to ship, with a clean working tree.

## 3. Preview, then stop

Run the read-only preview first — a plan, a diff, a `--what-if`, a `--dry-run`, a migration status. Show the human exactly what will change: resources created, modified, replaced or destroyed; migrations pending; configuration keys added or removed.

Then **stop and wait for an explicit "go"** for this specific change.

- A preview is never approval.
- An earlier approval never covers a new change, a new environment, or a changed plan.
- Read every line of the preview before presenting it. **A replacement or deletion of a stateful resource — a database, a volume, a store — is a stop-everything finding**, not a line in a list. Call it out separately and explain the data consequence.

## 4. Order matters

Work out the dependency order before you start, and say it:

- **Shared foundations before consumers.** Infrastructure or a shared fragment that two stacks both use goes first.
- **Configuration and secrets before the code that reads them.**
- **Additive migrations before the code that uses the new shape; destructive migrations after the code that stopped using the old one.** Expand, migrate, contract — never drop a column in the same step that stops writing it.
- **One environment at a time**, lowest-risk first, verifying each before moving on.

For anything that cannot be undone, prefer a sequence where each step is independently safe to stop at.

## 5. Destructive and irreversible steps

Dropping or truncating data, replacing a stateful resource, deleting a resource group or bucket, rewriting history, force-pushing, rotating a credential in use, sending real messages or taking real payments: describe exactly what you are about to run and what it will destroy, then wait. Every time. Even if you already have approval for the surrounding deployment.

If you realise you have already caused data loss, say so immediately and completely. Do not attempt to quietly repair it.

## 6. Verify after

A deployment that was not verified did not succeed, it merely finished.

- **Health**: the service starts, responds, and reports healthy.
- **Smoke-test the actual change** — the specific behaviour you shipped, through the path a user takes, not just a status endpoint.
- **Logs and errors** since the deploy: new exceptions, failed startups, permission errors, missing configuration.
- **Migrations applied** as expected, with the data shape you intended.
- **Nothing collateral broke** — the neighbouring surfaces that share the deployed component.
- For performance work, **re-measure with the same instrument** you used before (`performance-optimisation`).

Watch for long enough to catch delayed failures: scheduled jobs, queue consumers, cold starts, and anything that only runs on a timer.

## 7. Restore the environment you borrowed

Put back anything you changed to get the job done: the default account, subscription or context you switched; temporary firewall or network rules; temporary elevated permissions; temporary scaling. Confirm the restoration rather than assuming it, and say you did.

Remove temporary diagnostics unless you deliberately left principled telemetry — and then say so.

## 8. Rollback

Know the answer before you deploy, not after:

- What the rollback command is, and how long it takes.
- Whether the migration is reversible, and if not, what forward fix replaces a rollback.
- What state would be lost by rolling back.
- Who needs to be told.

If a deploy fails partway, stop and report the actual state — what applied and what did not — before attempting anything else. A blind retry over a partial apply is how one failure becomes two.

## Reporting

```
Target:        <environment(s), explicitly named>
Needed:        <app / infra / migration / config / secrets / jobs — or "none required">
Revision:      <branch and commit shipped>
Preview:       <what the dry run said would change>
Approved by:   <the human's explicit go>
Applied:       <in order, with results>
Verified:      <health, smoke test of the actual change, logs, migrations>
Restored:      <context/subscription/rules put back, and confirmed>
Rollback:      <the command, and what it would cost>
Not verified:  <what remains unchecked>
```

## Forbidden

- Deploying without an explicit, environment-specific "go".
- Treating a dry run, or an earlier approval, as approval.
- Inferring the target environment instead of confirming it.
- Applying to more environments than you were asked to.
- Shipping code before the configuration or secrets it depends on exist.
- Dropping a column in the same step that stops writing it.
- Any destructive step without its own separate approval.
- Reporting success on the basis that the command exited zero.
- Printing, logging or committing a secret.
- Leaving a switched account, context, or temporary access rule in place.
