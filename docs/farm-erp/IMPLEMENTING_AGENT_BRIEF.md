# Handoff to the implementing agent

## Goal

Build the farm ERP specified in this repository using **Joomla Component Builder in JoomEngine Playground**, maintaining all application behaviour in native JCB definitions, Powers, plugins/modules and supported assets. Deliver usable, tested Joomla components and their complete editable sources. The initial countries are Namibia, South Africa and Botswana; currencies NAD, ZAR and BWP.

This is the implementation handoff, not evidence that the ERP already exists. Start when the user authorises implementation. Use the current conversation's scope and destinations; do not infer permission to publish a real farm database or deploy production merely from this file.

## Read before authoring

1. [Product scope](PRODUCT_SCOPE.md), [architecture](ARCHITECTURE.md) and [decisions](DECISIONS_AND_OPEN_QUESTIONS.md).
2. [JCB build guide](jcb/JCB_PLAYGROUND_BUILD_GUIDE.md) and [capability/risk matrix](jcb/JCB_CAPABILITY_AND_RISK_MATRIX.md).
3. The current [JoomEngine Skills](https://github.com/joomengine/skills) operating contract, root entrypoints, version policy, request-to-extension workflow and applicable Packages/Playground/Power model instructions.
4. [Domain model](DOMAIN_MODEL.md), [finance and stock](FINANCE_STOCK_AND_COSTING.md), [integration contracts](INTEGRATION_CONTRACTS.md), [farmer experience](FARMER_EXPERIENCE.md).
5. [Delivery roadmap](DELIVERY_ROADMAP.md), [acceptance plan](ACCEPTANCE_AND_TEST_PLAN.md), [operations/migration](SECURITY_OPERATIONS_AND_MIGRATION.md) and the structured registries.
6. Relevant [ERP comparison](research/ERP_REFERENCE_COMPARISON.md), [regional requirements](research/SOUTHERN_AFRICA_REQUIREMENTS.md) and their pinned sources for the slice being implemented.

Do not treat the three ERP reference repositories as upstream manuals or proof that JCB already implements their behaviour. Do not treat this repository's JSON design registry as a JCB import package.

## Fixed implementation boundaries

- Seven working component names: Core, Ledger, Livestock, Crops, Make, Stay and Work, as registered in [components.json](contracts/components.json).
- One legal entity, one Joomla installation and one transactional database per deployment; several farms and enterprises within it.
- Core owns common parties/products/units/scope/files/infrastructure. Ledger owns stock/trade/financial effects. Other domains call owners; they do not write their tables directly.
- Native Fields and Admin Views, including every persisted child, define the schema. Dynamic Gets and Templates/Layouts supply routine reads/presentation. Powers hold justified custom domain behaviour with real callers.
- New source starts in JCB. No hand-built scaffold followed by Extrusion; no permanent manual generated-file patches.
- One outer transaction and driver for domain completion, stock/valuation, required GL, audit and outbox; no external network request inside that critical path.
- Commands enforce current scope, expected versions, unique request/effect identities and transitions. Generic CRUD must not bypass posted-record rules.
- Independent stock holds and output-specific animal restrictions remain effective until their own valid release/expiry; never clear them as a single Boolean.
- Use approved country/effective-date settings. Missing regulatory configuration disables only the relevant live capability.
- Operational/export mode can deliver useful enterprise work before native books activate; full ERP completion still includes native accounting and regional release gates.

## First concrete assignment

Execute M00 and M01. Resolve current compatible stable runtime versions, author minimal Core and Ledger, and demonstrate the actual supported owner-model/Power bridge. Add a minimal Livestock caller to prove the three-owner transaction. Verify source identity, SQL/route generation, role denial, fault rollback, replay, concurrency on a native target, source export/rebuild and independent restore.

Do not claim a generic `bootComponent()->getService()` exists. Inspect the generated model/provider APIs and document the supported bridge actually used. Do not expand the full schema until the P0 gates pass.

Then execute M02–M04 to deliver a useful farmer pilot. Continue M05 and selected M06–M10 slices according to their dependencies and actual farm priorities; complete M11–M15 for the agreed regional release. Keep partial releases accurately labelled.

## Work organisation

Use focused branches/PRs and successive commits. Parallel agents can research domains, author isolated source graphs and review evidence. **Exactly one controller mutates a live Playground at a time.** Keep an owner for shared source identities, dependencies and integration.

For each slice record: requirement/scenario IDs, owning entities, maintained definition IDs, source commits, runtime versions, commands/permissions, actual tests/results, installer hashes and outstanding limitations. Continue independent useful work when one adapter or business decision is blocked. Do not invent credentials, government APIs, legal defaults or completed test results.

Use the supplied Skills feedback procedure for reproducible gaps in its guidance. Preserve failure evidence and carry lasting fixes back to the correct source. A local syntax check is not a compile/install/runtime receipt.

## Completion contract

Delivery requires:

1. Working farmer-facing flows for every agreed enterprise and role.
2. JCB-generated installers with a dependency/compatibility manifest and checksums.
3. Complete editable JCB package graph plus supporting Power/catalogue/asset/seed/migration sources.
4. Passing required acceptance cases with source/runtime/actor/effect evidence; named unrun optional cases and limitations.
5. Reconciled stock, valuation, AR/AP, cash/bank and GL where native books are active.
6. Approved country capability matrix and documented unsupported functions.
7. Tested fresh install, representative upgrade, independent source rebuild and backup restore.
8. Reviewed migration/cutover, role training, operations/support and usable handoff.

The research PR is the plan. A successful build completes these outcomes; it does not merely create the tables, menus or screenshots.
