# Southern African farm ERP — research progress

Research and design completed: **19 November 2026**.

## Objective

Specify a practical, stable farm ERP for Namibia, South Africa and Botswana, built as cooperating Joomla components through Joomla Component Builder (JCB) in JoomEngine Playground. Produce an implementation roadmap another agent can follow from initial definitions through installation, testing, migration and operation.

## Completed research package

The branch was opened as a draft pull request after the initial scaffold, then expanded through successive published research commits. Three parallel investigations covered native JCB/Playground authoring, the supplied ERP references, and Southern African farm requirements. Integration and independent reviews converted those findings into the product and implementation contract indexed in [README](README.md).

| Deliverable | Completed design coverage |
| --- | --- |
| Product and farmer workflows | Livestock, gardens/crops, woodwork, food/feed production, markets, lodging, hunting, staff, equipment, water, fuel, expenses and accounts |
| Component ownership | Seven cooperating Joomla components, with stock and accounting owned by one Ledger component |
| Domain registry | 127 entities, 1,036 explicit logical fields and 395 declared relationships, plus common inherited fields |
| Command registry | 46 operations with payload contracts, permissions, locking, effects, idempotency, correction rules and acceptance references |
| Delivery plan | 16 dependency-linked milestones, M00–M15, with a useful limited pilot before complete ERP release |
| Acceptance backlog | 93 cases; every implementation case remains `not_run` |
| Regional research | Three initial country packs, 40 primary institutional sources and 27 farm operating scenarios |
| ERP comparison | Qualified comparison of all three supplied repositories and 13 worked workflow patterns |
| JCB implementation guidance | Native source workflow, capability/risk matrix, source/version evidence and mandatory proof gates |
| Operational handoff | Security, migration, backup/restore, cutover, support, farmer experience and implementing-agent instructions |

The seven JSON files are logical design registries and transport/configuration schemas. They are not importable JCB package records, compiled extensions or implemented endpoints. Source qualifications and pinned revisions are recorded in the [source register](sources/SOURCE_REGISTER.md).

## Material review decisions

- Keep stock quantity, valuation and accounting effects under one owner and one database transaction. Prove the actual shared connection and native cross-component bridge at M01 before building dependent workflows.
- Author and maintain the product through JCB-native definitions and Powers. Rebuild and restore from exported source; generated-file edits alone do not qualify as a lasting change.
- Treat posted records as immutable and use explicit commands for issue, payment, transfer, allocation, reversal and other consequential transitions. Test every generic UI/API/import route for bypasses.
- Use canonical non-null stock keys and existing physical-resource parent locks; do not assume database exclusion indexes or unmodelled capacity tables.
- Separate independent stock holds and animal output/action restrictions. Preserve restricted-cohort ancestry through splits and individualisation, and reject direct Ledger routes that bypass Livestock eligibility.
- Preserve credit-note allocation without inventing cash, approved time-cost snapshots, reservation deposit liabilities and source-linked reversals.
- Let enterprise slices follow the stable pilot while native accounting progresses in parallel. Complete ERP release still requires native books and all relevant country, integrity and recovery gates.
- Limit initial offline work to authorised observation drafts. Country activation requires effective-dated evidence and accountable local review; conflicting official summaries do not become invented production values.

## Verification and evidence boundaries

Documentation verification includes JSON syntax, ownership, identities, field/index/relation consistency, component and milestone dependency cycles, domain-table coverage, command/case/milestone links, local document paths and JSON pointers, evidence requirements for executed-status claims, and unresolved merge markers. The reproducible entrypoint is [tools/validate-roadmap.sh](../../tools/validate-roadmap.sh).

The final validation commands are:

```bash
bash -n tools/validate-roadmap.sh
bash tools/validate-roadmap.sh
git diff --check
```

All three commands passed on the completed research package. The validator checked all seven contract files, the exact 127-entity model, 270 local destinations and 28 JSON pointers across 22 Markdown documents and the registries.

The command names were additionally cross-checked between the 46-entry registry, strict command-envelope enumeration and prose command catalogue. All 79 unique pinned GitHub source-file targets were checked against their available repository snapshots. In a disposable copy, the validator rejected an invalid relationship target, an unsupported passed-test claim, a dependency cycle, a missing local Markdown destination and a merge conflict marker.

These checks validate the research package. They do **not** constitute full JSON Schema evaluation, a complete CommonMark/heading-anchor or live external-link audit, legal certification, or a JCB/Playground/ERP runtime test. No ERP extension was implemented, compiled, installed or exercised in this research task. The 93 acceptance cases and all 16 implementation milestones retain their unexecuted statuses. Source documents reporting their own runtime observations remain qualified by their original fixtures and evidence boundaries.

## Next implementation action

Follow the [implementing-agent brief](IMPLEMENTING_AGENT_BRIEF.md), beginning with M00 and M01 in the [delivery roadmap](DELIVERY_ROADMAP.md). Confirm the first farm and current supported toolchain, then prove the minimal native Livestock → Ledger → Core path with rollback, retry, concurrency, denied access, fresh source rebuild and independent restore. Only expand once that proof passes. Open business choices remain in the [decision register](DECISIONS_AND_OPEN_QUESTIONS.md); they do not block independent synthetic proof work.

## Sources supplied by the owner

- https://github.com/joomengine/skills
- https://github.com/vast-development-method/dolibarr-doc
- https://github.com/vast-development-method/erpnext-doc
- https://github.com/vast-development-method/odoo-doc

## Working boundaries

The product targets Namibia, South Africa and Botswana with NAD, ZAR and BWP. The architecture distinguishes a usable farm pilot from complete ERP readiness. Regulatory rules remain dated, configurable and subject to country-specific professional verification before the affected capability is used in production.
