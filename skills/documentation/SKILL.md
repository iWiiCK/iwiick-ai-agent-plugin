---
name: documentation
description: Write and maintain documentation that stays true — present-tense description of the system as it is, every claim traceable to code, updated in the same change as the behaviour it describes, written for one named audience. Use when changing behaviour that is documented, writing a README or guide, or maintaining agent-facing or product-facing knowledge files.
---

# Documentation

Documentation has exactly one job: let someone act correctly without reading the source. It fails silently — when it goes stale nothing breaks, nothing turns red, and the reader confidently does the wrong thing. That is worse than having no documentation at all, and it is the failure this skill exists to prevent.

## The core rule

**Documentation describes the system as it is, in the present tense.**

- No roadmap items, no "coming soon", no aspirational features.
- No migration history, phase numbers, or "formerly known as".
- No changelog narrative inside reference documentation. History belongs in version control and in the plan archive.
- Every claim must be traceable to something in the repository — code, schema, configuration, infrastructure. If you cannot point at it, do not write it.

If you change behaviour, update the affected documentation **in the same change**. Not afterwards, not in a follow-up. A rename of a page, a field, a command or a concept is enough to require it.

## Write for one audience

Decide who the reader is before the first sentence, and never mix two audiences in one document:

- **Engineers** — may see file paths, table names, code, infrastructure, real environment names.
- **Operators / admins** — need exact procedures, commands, preconditions and failure recovery; not internals.
- **End users** — need the interface's own vocabulary: pages, buttons, settings. No table names, no column names, no code, no file paths, no infrastructure.
- **Agents** — need procedures and constraints, not prose. See `engineering-workflow` and the project's agent instructions file.

A sentence only comprehensible to someone who has read the source does not belong in user-facing or product-facing documentation, even when it is accurate.

## Where things belong

- **Reference** — what the system is, and how its parts relate. Explanatory, stable.
- **Guides** — how to do a thing, start to finish, in order, with the exact commands.
- **Operations** — deployment, infrastructure, environments, incident procedures.
- **Agent instructions** — conventions and constraints for automated contributors.
- **Plan archive** — the dated, immutable record of what was decided. The deliberate exception to the present-tense rule: plans are history and must never be edited (`change-planning`).

Prefer editing the document that already covers the area over adding a new one. Fragmentation is the main way documentation dies.

## Do not generate documentation nobody asked for

Do not create summary files, migration notes, status reports, "what I changed" documents or implementation notes as artifacts. Put that in your handoff message and in the commit message, where it belongs. The exception is a persistent project-knowledge file the project actually maintains.

## Product-facing knowledge is part of the product

When a system reads documentation at runtime — an in-app assistant, a help surface, an onboarding tour, a support bot — those files are product code, not documentation. Treat them accordingly:

- Nobody reads them directly, so staleness is invisible until it misleads a real user. Update them in the same change as the behaviour, always.
- Write in the interface's vocabulary, naming only things the reader can actually see and click.
- Every answer must land somewhere actionable. Abstract explanation with no control to act on fails the bar even when it is true.
- Never name another customer, tenant or brand in content that ships to all of them.
- If the project has an automated consistency check for this corpus, run it. When it reports drift, fix the content — never weaken the check.

## Keeping it honest

- **Generated files are generated.** If a file is produced by a script, never hand-edit it; run the generator. Say so at the top of the file.
- **Exact commands, copy-pasteable, in the shell the reader actually uses.** Shell syntax is not portable — a `bash` heredoc does not parse in PowerShell. Either match the project's documented shell or give both forms.
- **Preconditions before steps.** What access, credentials, network position or state the reader needs first.
- **Say what failure looks like.** The error they will see, and what to do about it.
- **Link rather than duplicate**, unless duplication is deliberate because the audiences differ — and then say that it is deliberate.

## Reviewing documentation you did not write

When you touch an area, check whether its documentation is still true. If it is not, fix it or report it — "that's not my document" is not available. Do not, however, rewrite a document's structure as a side effect of a small change.

## Commit and handoff prose

The diff shows *what* changed. Your commit body must carry *why* — the problem, the cause, the decision. State what was verified and anything deliberately left unverified. Write it for the person who finds this commit in six months while bisecting.

## Forbidden

- Documenting intent, plans or future work as if it exists.
- A claim you cannot trace to code, schema or configuration.
- Changing behaviour without updating the documentation in the same change.
- Hand-editing a generated file.
- Mixing audiences — internals in user-facing content, or interface vocabulary in engineering reference.
- Naming a real customer or tenant in content that ships to all of them.
- Creating unrequested summary, status or migration documents.
- Editing an archived plan.
