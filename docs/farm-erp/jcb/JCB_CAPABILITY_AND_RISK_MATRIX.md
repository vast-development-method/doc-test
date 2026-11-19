# JCB capability, evidence and implementation risks

**Research date:** 19 November 2026. **Source snapshot:** `joomengine/skills@b3f79efe7e83f40aa2a5236844277dd9b67eb60e`. This ledger separates capabilities documented in the Skills, compiler source inspected during this research, historical execution receipts, and new ERP design obligations. It must not be interpreted as an ERP test report.

The companion [JCB and Playground build guide](JCB_PLAYGROUND_BUILD_GUIDE.md) defines the ordered procedure. The matrix below identifies where the implementing agent must provide additional evidence before claiming a stable product.

## Evidence classes

| Label | Meaning |
| --- | --- |
| Policy | Maintainer guidance to follow when building; not itself execution evidence |
| Documented source | The pinned Skills explain inspected source behavior and cite its implementation; this research read those guides |
| Direct source | This research additionally read the named current JCB implementation file |
| Historical runtime | A dated Skills receipt reports execution of a bounded slice; it does not validate the new ERP |
| ERP proposal | An architectural or product requirement to implement and verify |
| Unrun | No new relevant JCB/Playground execution occurred in this roadmap research |

## Capability and risk matrix

| ID | Capability and present evidence | Farm ERP consequence | Required implementation evidence / owner |
| --- | --- | --- | --- |
| JG-01 | Native records-first authoring; no hand-coded scaffold followed by Extrusion. **Policy.** [S01] | Every application table, view, command hook and owned extension must have maintained JCB source. | Build controller: trace a changed source record through compile/install/runtime; remove reliance on generated-only patches. |
| JG-02 | Current stable compiler selection with a consistent build toolchain. **Policy.** [S02] | Historical alpha/source citations cannot set the production version policy. | Release owner: record actual Joomla/JCB/PHP packages/versions/hashes; verify target compatibility. |
| JG-03 | Fields + Admin Views + component attachments generate conventional data management. **Documented source; bounded Notes historical runtime.** [S03] [S04] | A visible child editor is insufficient unless its independently persisted entity has a real view/schema. | Domain owner: inspect saved associations and emitted SQL; create/reopen rows in a clean consumer. |
| JG-04 | Definition GUID, application GUID, local ID and business key are distinct. Generated identity normalization precedes later save hooks. **Documented source.** [S05] | Animal tags, stock SKUs and invoice numbers cannot substitute for portable identities; API/import GUID preservation needs an explicit boundary. | Core/data owner: create/edit/copy/import/retry matrix; malformed/nil/duplicate rejection; actual unique indexes; cross-instance relations. |
| JG-05 | ModalSelect requires coherent key/title/routes and target edit resolution. **Documented source and reference specimens.** [S06] | A farmer must see names/tags rather than raw GUIDs; linked New must preserve parent scope and failed-save input. | UI owner: select/clear/new/edit/cancel, denied parent, GUID-to-numeric lookup and failed-save recovery. |
| JG-06 | Expert normalized subforms need child Admin Views and both model handlers. Save is complete-collection replacement; malformed values can clear rows. **Documented source.** [S07] | Ordinary collections can reuse this mechanism; ledger lines and immutable events need command-controlled lifecycle. | Domain owner: absence/null/empty/non-array, omission, cross-parent identity, child API and copy behavior. |
| JG-07 | Nested MultiSubform has source-specific linking/validation caveats; whole aggregate atomicity is not guaranteed. **Documented source.** [S07] | Deep nested financial editors would add avoidable risk to the first release. | UI/data owner: use simpler explicit editors first; prove new parent/grandchild identity and failure behavior before enabling nesting. |
| JG-08 | Dynamic Gets provide configured item/list/related retrieval and presentation data shape. **Documented source/reference patterns.** [S08] | Farmer screens need explicit farm filters, access constraints, stable sorting, query limits and empty states. | UI owner: inspect real aliases/generated properties; 0/1/many relations, denied records, list boundaries and representative query budgets. |
| JG-09 | Templates/Layouts compose pages; raw Custom View Script preparation has a bounded historical runtime pass. **Documented source; historical runtime.** [S09] | Keep daily screens coherent and maintainable; avoid one giant default body. | UI owner: inspect emitted renderers, escaping, required assets, translation extraction and mobile/keyboard behavior. |
| JG-10 | Super Power placement is namespace-driven. One administrator-owned class/caller has historical runtime evidence. **Documented source; historical runtime.** [S10] [S11] | Administrator success cannot certify frontend/API placement or cross-component ownership. | Build owner: inspect namespace/path/imports/loaders; execute each actual client; no unresolved tokens. |
| JG-11 | Enabled Class Header Code is the supported import location. A prior headerless-token failure was withdrawn as a compiler-bug claim. **Policy/documented source.** [S12] | Do not adopt a fake workaround or freeze an obsolete compiler to avoid a mis-authored class. | Power owner: header/body separation, valid imports/aliases, generated PHP lint and real caller execution. |
| JG-12 | Importing a provider does not register it; separate factories can own separate containers. **Documented source.** [S10] | Domain services need real construction and one intended transaction connection. | Architecture owner: provider registration/caller trace; dependency and driver identity assertions. |
| JG-13 | Joomla 6 provider template registers standard MVC/component services; extension template has no arbitrary ERP service getter. **Direct source at `037752c7`.** [S13] [S14] | Do not assume `bootComponent()->getService()` or a public component container exists. | Architecture owner: prove owner-model bridge or another supported maintained interface; test administrator/site/API clients. |
| JG-14 | Shared Power library placement is not automatic independently owned Joomla library packaging. **Documented source.** [S10] | Two components must not overwrite/uninstall each other's shared code. | Release owner: inspect archive ownership, manifests and loaders; compatible upgrade, missing dependency and uninstall protection tests. |
| JG-15 | Generic parent/child lifecycle can interact with Joomla Table/asset locking; an implicit commit was reported in a historical project. **Reported case, not universal finding.** [S07] | Cross-component posting must not rely on an untested whole-model transaction. | Ledger/architecture owners: forced failures before/after domain and ledger writes; same driver instance; no internal commits; native contention tests. |
| JG-16 | `add_api=3` Item includes POST/PATCH/DELETE; a runtime route plugin is required. **Documented source.** [S15] | Immutable and posted records must not be accidentally writable through generic endpoints. | API owner: route/method/field inventory; state guards through every path; direct update/delete rejection tests. |
| JG-17 | An enabled admin API discovers eligible dynamic resources; site public access can make reads public. **Direct source in current `Resources.php`.** [S16] | A private farm dashboard or guest/staff data must not leak because an unrelated admin API was enabled. | API/security owners: audit all emitted routes/serializers and anonymous requests; explicit public-resource allowlist. |
| JG-18 | PATCH hydration and identity preprocessing can obscure original omission versus submitted values. **Documented source.** [S05] [S15] | Required expected revision and immutable values must be checked against original mutation input. | API owner: omission/null/empty/stale/unknown-field cases with unchanged unrelated rows. |
| JG-19 | Complete Files/File Types feature exists as reusable graph. **Documented source/reference examples.** [S17] | Images, receipts and hunting permits need ownership-aware storage and actual download policy. | Core/documents owner: upload/type/size validation, private download denial, cleanup/retention and clean-consumer assets. |
| JG-20 | Native immediate and staged importer building blocks exist; a bounded queued Demo path has historical execution. **Documented source; historical runtime.** [S18] [S19] | Larger onboarding jobs require a real worker lifecycle, not merely an upload form or queue row. | Import owner: downloadable example round trip, validation/dry run, duplicate replay, corrections, message logs, native scheduler and concurrency. |
| JG-21 | Table-mode seed data compiles from live rows; package export excludes its local table map. **Documented source.** [S20] | A source-only reconstruction can silently lose country/currency/reference seeds. | Data/release owners: deliberate Dump source or documented reconstruction; verify fresh install and clean-source rebuild. |
| JG-22 | Fresh-install seeds and version updates are separate; compiler history may be local. **Documented source.** [S21] [S22] | Country rules and financial schemas require retained migrations with recoverable rollout. | Release owner: repeat compile and clean-source upgrade files; existing-data upgrade, failure/retry and post-migration integrity. |
| JG-23 | Package export is a typed graph with parent keys, natural keys and asset pointers; code encoding is field-specific. **Documented source.** [S23] | Blanket UUID replacement or base64 conversion can corrupt the blueprint. | Source owner: native model validators, exact per-model identities, coherent references/assets and fresh acquisition. |
| JG-24 | Push can write to several eligible destinations and is not one atomic graph commit. Read-source selection does not restrict it. **Documented source.** [S24] | Incremental source publication needs destination control and remote reconciliation. | Build controller: all effective write branches audited, intended source diff read back, partial writes resolved before retry. |
| JG-25 | Package Push does not prove export of separate project Power/Field Type/Snippet catalogues. **Documented source.** [S25] | A component blueprint with missing custom services is not maintainable delivery. | Source owner: complete dependency manifest and separately verified owned catalogue publication. |
| JG-26 | Playground automatic persistence, recipe Save and external Complete site are distinct. Historical live export succeeded despite persistence failure; independent restore was not established by that receipt. **Documented source; historical runtime.** [S09] [S26] | Preserve the live owner and useful work; do not treat a Share link or local backup panel as durable delivery. | Build controller: retained archive/hash, isolated Upload, saved relationships and representative rebuild. |
| JG-27 | Same-browser MCP transport and some reads have a test contract; external reachability and native jobs are separate. **Documented source/test contract.** [S27] | MCP is optional; unknown action coverage must not block a working GUI route or be fabricated. | Automation owner: discover/describe actual actions, authorized read then saved write proof; GUI fallback; native job tests where needed. |
| JG-28 | Browser runtime lacks several native host facilities. **Documented source.** [S26] [S27] | Mail, real CLI scheduling, hardware/peripherals and production load need native staging. | Operations owner: exercise intended integrations and failure recovery on declared native environment. |
| JG-29 | Static validators check bounded authoring profiles and can defer transformed source checks. **Documented tooling contract.** [S28] | Successful lint/index validation is not a seven-component release pass. | Verification owner: preserve skipped/deferred checks; require independent runtime/rebuild evidence per release gate. |
| JG-30 | Single entity, scoped farms, atomic ledger integration, outbox, role matrix and mobile daily workspace are ERP-specific. **ERP proposal; unrun.** | They are not features automatically supplied by JCB or inherited from ERPNext/Odoo/Dolibarr. | Product/domain owners: implement each defined workflow and its acceptance scenarios before claiming support. |

## Priority proof backlog

### P0 — resolve before expanding the component count

1. **Two-component build and reconstruction:** Farm Core plus one real satellite, with a field/view/service consumer and clean installation without JCB.
2. **Service ownership and bootstrapping:** one installed owner of each shared implementation; supported caller bridge, actual DI registration and compatible-version enforcement.
3. **Command atomicity:** one real driver/connection, domain plus Ledger effects, forced exceptions, idempotent retries and native concurrent requests.
4. **Identity and API invariants:** stable row GUIDs, immutable posted records, original-payload revision checking and complete route exposure audit.
5. **Source recovery:** complete graph/support models, external artifact retention and independent source reconstruction.

These gates can fail without invalidating the overall product concept. Resolve a failure at the smallest source slice, document the selected native JCB path, and only then repeat that pattern across domains.

### P1 — complete before the pilot uses business data

- Versioned upgrade and rollback/recovery practice, with explicit handling of nontransactional DDL.
- All role/farm-scope permissions through UI, import, API, file download and reporting.
- Reference-data maintenance that preserves local farmer additions and records effective dates.
- Real scheduled jobs/outbox, mail and backup/restore on the target native host.
- Stock/financial reconciliation and audited reversals, including contention and partial external failure.
- Private archive delivery and removal of temporary repository write credentials.

### P2 — expand only after the daily workflows are stable

- Deeper nested editors, richer background imports and more automated third-party integrations.
- Offline capture and synchronization, which need their own operation identity, conflict and authorization design.
- Shared infrastructure extraction into separately versioned libraries only when packaging/ownership tests establish a clear benefit.

## Honest completion statement for this research

The Skills distribution was cloned and read at the pinned commit. Focused current JCB source reads covered the Joomla 6 provider, extension class template and API resource discovery. Git refs established source identities. No ERP JCB definitions, generated extensions, Playground mutations, live imports/exports, native-server tests or application acceptance tests were performed in this documentation task. Historical Skills receipts remain attributed to their original bounded exercises. The planned gates specify what another agent must prove.

## Source map

[S01]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/AGENTS.md
[S02]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/standards/version-policy.md
[S03]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/models/admin-views.md
[S04]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/testing/scenarios/notes-admin-verification.md
[S05]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/application-identities.md
[S06]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/modal-relationships.md
[S07]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/normalized-subforms.md
[S08]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/dynamic-get.md
[S09]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/testing/playground/verification.md
[S10]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/super-powers/workflows/customize-extension.md
[S11]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/testing/playground/power-placement-verification.md
[S12]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/super-powers/settings-reference.md
[S13]: https://github.com/joomengine/Joomla-Component-Builder/blob/037752c7e6599aa4cec900138dfb61af7ee4ba8f/admin/compiler/joomla_6/ADMIN_PROVIDER.php
[S14]: https://github.com/joomengine/Joomla-Component-Builder/blob/037752c7e6599aa4cec900138dfb61af7ee4ba8f/admin/compiler/joomla_6/ADMIN_EXTENSION_COMPONENT.php
[S15]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/models/api-selection.md
[S16]: https://github.com/joomengine/Joomla-Component-Builder/blob/037752c7e6599aa4cec900138dfb61af7ee4ba8f/libraries/vendor_jcb/VDM.Joomla/src/Componentbuilder/Compiler/Architecture/Api/Resources.php
[S17]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/media-files.md
[S18]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/imports.md
[S19]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/evidence/importer-building-blocks.md
[S20]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/initial-data.md
[S21]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/models/component.md
[S22]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/compiler-plugins.md
[S23]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/specification.md
[S24]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/author-in-playground.md
[S25]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/workflows/delivery.md
[S26]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/testing/playground/README.md
[S27]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/workflows/mcp.md
[S28]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/tools/README.md
