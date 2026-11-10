---
name: clean-code-update
description: Re-sync the clean-* skill family against its upstream source repository, reporting what changed upstream and merging it without losing the local adaptations. Use when asked to "update my clean code skill(s)", re-sync clean code rules, or check whether the upstream clean-code-skills repo has changed.
triggers:
  - user
  - model
---

# Update the clean-code skills

Re-syncs the `clean-*` family and `boy-scout` against upstream **[clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills#clean-code-skills-for-ai-agents)** (MIT, Ertuğrul Demir).

This is a **merge, not a copy**. The local family is a deliberate adaptation; a blind overwrite would reintroduce contradictions with `risk-based-testing` and break the plugin's flat naming. Upstream contributes *rules*; the local versions keep their *shape*.

| | |
| --- | --- |
| Upstream | `https://github.com/ertugrul-dmr/clean-code-skills.git` |
| Last synced commit | recorded in the Provenance table of `clean-code` |
| Files to edit | `skills/clean-*/SKILL.md` and `skills/boy-scout/SKILL.md` in this plugin repo |

## Where the files are

This plugin may be installed from its git source or linked from a local folder:

- `devin plugins info iwiick` names the installed source.
- A **git-source** install is cached read-only — **never edit the cache**. Clone or pull the plugin repo, edit there, commit, push, then `devin plugins update iwiick`.
- A **`--local`** install is linked live to its folder; edit in place and the next session picks it up. Still commit and push, or the change exists on one machine only.

## Procedure

### 1. Fetch upstream

Clone or pull the upstream repository into a scratch directory. Record the new `HEAD` commit SHA and its date.

### 2. Establish what changed

Read the last-synced SHA from the Provenance table in `clean-code`, then diff upstream between that commit and the new `HEAD`:

```
git log --oneline <last-synced>..HEAD
git diff --stat <last-synced>..HEAD
git diff <last-synced>..HEAD -- skills/
```

**If there are no changes, stop and say so.** Do not rewrite files to no effect.

### 3. Classify every upstream change

For each change, decide which it is, and say which:

| Classification | Action |
| --- | --- |
| **New rule** | Add it to `clean-code` with its upstream ID, and to the focused skill that owns its category. |
| **Changed rule wording** | Adopt it, rephrased to match the local voice and kept language-neutral. |
| **Removed rule** | Remove it locally too, unless it is load-bearing here — then keep it and note why in Provenance. |
| **New skill** | Add it as `skills/<name>/SKILL.md` with a flat name, cross-references unprefixed. |
| **Example in Python or TypeScript only** | Keep the local language-neutral treatment; port the *rule*, not the snippet. |
| **Conflicts with a deliberate departure** | Do **not** adopt. Report it, and restate why the departure stands. |
| **Install, licence or README prose** | Ignore — it does not belong in a skill body. |

The deliberate departures are listed in the Provenance section of `clean-code`. They are decisions, not drift. Overriding one needs the user's agreement, not your judgement.

### 4. Apply the merge

- Keep skill names **flat** — the `iwiick` plugin namespace already distinguishes them. A `name:` field must match its directory.
- Preserve each skill's existing structure, `description` frontmatter and checklists — do not replace a local file wholesale.
- Keep rule IDs stable. An ID already in the local catalogue must keep its meaning, or every past review comment citing it becomes wrong.
- Keep the precedence notes: `risk-based-testing` over `T1–T9`, and project conventions over everything.

### 5. Update the Provenance record

In `clean-code`, set the synced commit SHA and date to the new `HEAD`. Add a new deliberate departure if this sync created one.

### 6. Verify

- Every `clean-*` and `boy-scout` file has valid YAML frontmatter with a `name:` matching its directory.
- No `iwiick-` prefix crept back into a skill name or cross-reference.
- No rule ID means two different things.
- `devin skills list` shows the whole family after `devin plugins update iwiick`.

### 7. Commit and publish

Commit to the plugin repo with a message naming the SHA range, then push. Until it is pushed, the update exists on one machine only and will not reach cloud sessions or your other machines.

### 8. Report

```
Upstream:     <last-synced SHA> → <new SHA> (<date>)
Commits:      <count, with one-line subjects>
Adopted:      <new and changed rules, by ID>
Removed:      <rules dropped upstream and dropped here>
Rejected:     <upstream changes not adopted, and why>
Unchanged:    <files that needed no edit>
Provenance:   updated to <new SHA>
Published:    <commit pushed, or why not>
```

If nothing changed upstream: say exactly that, in one line, and change nothing.

## Forbidden

- Overwriting a local skill file with its upstream version.
- Editing the read-only plugin cache instead of the plugin repo.
- Adopting upstream's `T1–T3` testing stance over `risk-based-testing`.
- Re-introducing parallel per-language tracks with colliding skill names.
- Changing the meaning of an existing rule ID.
- Editing files when upstream has not changed.
- Updating the Provenance SHA without actually merging the changes it claims.
- Leaving the merge uncommitted or unpushed.
