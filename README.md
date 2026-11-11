# IWIICK Engineering Workflow — a Devin plugin

Portable engineering discipline for AI agents. Project-agnostic procedure, installed once against your Devin account, available on every machine you sign in to and in cloud sessions.

The point of the split: **these skills carry the _how_; each repository's `AGENTS.md` carries the _what_** — its stack, commands, paths and constraints. The same workflow therefore applies everywhere, and only the thin adaptation layer changes per project.

## Install

Two delivery paths. Both serve the same `skills/` directory, so switching between them needs no rework.

### A. As a plugin — account-synced (preferred)

```bash
devin auth login            # a Devin account; see the caveat below
devin plugins install iWiiCK/iwiick-ai-agent-plugin
```

This records the plugin in your personal manifest in Devin Cloud, so it loads on every machine you sign in to and in your cloud sessions. Skills are invoked as `/iwiick:<skill>`.

```bash
devin plugins info iwiick       # what it provides, and its source
devin plugins update iwiick     # re-fetch at the latest commit
devin skills list               # confirm the skills loaded
```

> **Run plugin commands from a normal terminal.** Inside an IDE extension host (Windsurf/Devin Desktop tool shells, where `WINDSURF_EXT_HOST_PID` is set) the CLI does not pick up the stored credential: `devin auth status` reports "Not logged in" and every `plugins` command fails with `You must be logged in to manage plugins`. The credential is fine — the environment is not. A plain terminal works.

If the install reports `installed locally but not synced to your personal plugins`, the skills work on that machine but will not reach cloud sessions or your other devices. Re-run the install later; if it persists, check that the repository is reachable by Devin Cloud (a private repo may need access granted, or can be made public).

### B. Via the sync script — git-portable, no plugin system

```powershell
git clone https://github.com/iWiiCK/iwiick-ai-agent-plugin.git
cd iwiick-ai-agent-plugin
.\sync-skills.ps1 -DryRun     # preview
.\sync-skills.ps1             # install into the global skills directory
devin skills list             # confirm
```

On any other machine: clone, run the script. To update: `git pull`, run it again.

The script copies `skills/*` into the global skills directory (`%APPDATA%\devin\skills` on Windows) and **adds the `iwiick-` prefix** to each directory name, the `name:` frontmatter and every cross-reference — because that directory has no namespace, so flat names like `documentation` would risk colliding with third-party global skills. Skills are then invoked as `/iwiick-<skill>`.

It is idempotent, replaces only the `iwiick-*` directories it manages, and leaves other global skills untouched. `-DryRun` reports without writing; `-SkillsRoot` targets a different directory; `-Prefix ''` disables prefixing (not recommended).

Because the output is deterministic, you can confirm an install is current:

```powershell
.\sync-skills.ps1 -SkillsRoot "$env:TEMP\check"
# then diff "$env:TEMP\check" against %APPDATA%\devin\skills — expect no differences
```

### Which to use

**Prefer the plugin.** The sync script exists for machines where the plugin system is unavailable or where you want the skills without installing anything.

| | Plugin | Sync script |
| --- | --- | --- |
| Reaches cloud sessions | Yes, once synced to the personal manifest | No |
| New machine | Automatic on sign-in | `git clone` + run script |
| Updating | `devin plugins update iwiick` | `git pull` + run script |
| Skill names | `/iwiick:clean-code` | `/iwiick-clean-code` |

**Do not use both at once.** They install the same skills under different names, and the agent then sees every skill twice. If you switch from the script to the plugin, delete the script's output:

```powershell
Remove-Item -Recurse -Force "$env:APPDATA\devin\skills\iwiick-*"
```

## The skills

### Spine

| Skill | Owns |
| --- | --- |
| `engineering-workflow` | The non-negotiables and the routing table. Evidence over assertion, every number reproducible, root cause over symptom, the approval gate, honest handoff. Start here. |

### Stages

| Skill | Owns |
| --- | --- |
| `system-analysis` | Prove the entry point, trace end to end with `file:line`, quantify cost, enumerate where the pattern generalises, present approaches with trade-offs. |
| `change-planning` | The approval gate, phased plan structure, per-phase verification, the infrastructure decision, amendments rather than rewrites. |
| `implementation` | Conventions first, edit rather than recreate, verification batched to the end with four named exceptions, scope discipline. |
| `debugging` | Reproduce, read the real error, instrument, name the mechanism in one sentence, fix the mechanism, prove it with a failing-then-passing test. |
| `risk-based-testing` | What deserves a test (mandatory / judgement / do-not-test), the smallest honest verification scope, and never weakening a check. |
| `performance-optimisation` | Measure first, work the cost model, the five-part cache contract, re-measure with the same instrument. |
| `documentation` | Present tense, traceable claims, one audience per document, product-facing knowledge treated as product code. |
| `deployment` | What actually needs deploying, preview then stop for approval, dependency ordering, post-deploy verification, restoring borrowed context, rollback. |

### Code quality (cross-cutting)

| Skill | Owns |
| --- | --- |
| `boy-scout` | Orchestrator: one small, safe, **reported** improvement per file you touch, proportional to the task. |
| `clean-code` | The full rule catalogue with stable IDs (C, E, F, G, N, S, T) so violations can be cited precisely. |
| `clean-names` | N1–N7. |
| `clean-functions` | F1–F4, G30, G34, guard clauses, command–query separation. |
| `clean-comments` | C1–C5. |
| `clean-general` | G3, G5, G9, G16, G23, G25, G28–G36. |
| `clean-tests` | Test craft: FIRST, boundary conditions, one concept per test, mock at boundaries. |
| `clean-code-update` | Re-syncs the clean-code family against upstream without losing the local adaptations. |

## Precedence

1. **A project's `AGENTS.md` wins** over any skill here — but the agent must say out loud that it is departing, and why.
2. **A skill wins** over the agent's own preferences.
3. Within the clean-code family, **`risk-based-testing` outranks `T1–T9`** on what deserves a test. `clean-tests` governs only how a test is written.

## Using it in a repository

Keep each repo's `AGENTS.md` as a thin adaptation layer: a skill map that says which skill owns which stage, then the repo's own facts — stack, commands, safety properties, plan archive path, infrastructure protocol. Do not restate the procedure; reference the skill and supply the concrete nouns.

## Attribution

The `clean-*` and `boy-scout` skills derive from [clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents) by Ertuğrul Demir (MIT), itself a distillation of Robert C. Martin's _Clean Code_, Chapter 17. They have been adapted to be language-neutral and to defer to `risk-based-testing` on test selection; the full list of deliberate departures and the synced upstream commit are recorded in the Provenance section of `clean-code`.

Say **"update my clean code skills"** to re-sync from upstream.

## Licence

MIT.
