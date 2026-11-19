# Acceptance, fixtures and evidence

## 1. What has and has not been tested

This research PR validates documentation structure and source references. It does **not** contain an ERP build or ERP runtime test results. All structured implementation cases start as `not_run`. The implementing agent must execute and retain results against its exact JCB/source/runtime revisions.

Use [acceptance-cases.json](contracts/acceptance-cases.json) as the case backlog, [farm operating scenarios](research/FARM_OPERATING_SCENARIOS.md) for farmer narratives and [ERP workflow patterns](research/ERP_WORKFLOW_PATTERNS.md) for accounting/stock examples. Similar-looking fixtures are independent datasets; do not combine their quantities/prices into a single unbalanced test farm.

A case's primary milestone is the planned introduction point, not an exemption for early feature activation. If the pilot enables counted flocks, treatments, production or lodging before its nominal later phase, promote and pass all relevant domain/financial-mode cases before live use. R1's minimal individually tagged animal example does not certify untested group or treatment behaviour.

## 2. Test layers and their meaning

| Layer | Proves | Does not prove |
| --- | --- | --- |
| Source/static | Native schema/identity/index/link shape, PHP syntax, dependency closure, known policy checks | Correct JCB import or installed behaviour |
| JCB persisted graph | Imported/authored values and associations survive reopen; intended candidate loaded | Successful compilation or transaction safety |
| Compilation inspection | Expected PHP/SQL/XML/routes/assets emitted and packaged | Authorised runtime behaviour |
| Playground installed slice | Real forms/callers, saved data, known failure cases on selected browser runtime | Native cron, real mail delivery, concurrent database load or production recovery |
| Native server integration | Same-driver rollback, concurrent requests, scheduler/leases, transport and server behaviour | Farmer usability or legal configuration correctness |
| Farmer acceptance | Actual users can complete agreed scenarios and interpret states/errors | Correctness of untested features/countries |
| Country/accountant review | Recorded settings/outputs fit the reviewed jurisdiction, period and capability | Universal future compliance |
| Independent rebuild/restore | Source graph and retained artifacts reproduce/recover the tested release | Recovery from missing/unprotected production keys or untested backups |

Select meaningful tests for each change. Do not add dozens of tests that simply mirror field setters; protect the business invariants and risky integration boundaries.

## 3. Synthetic fixture design

Build a named synthetic legal entity, two farm scopes, two stores, several bins, one transit/quarantine location, and separate roles. Use non-real addresses/contacts and no live email recipients. Create distinct datasets for NAD, ZAR and BWP functional-currency tests; the one-entity installation does not change functional currency mid-test without migration.

Baseline products: bulk feed, veterinary consumable with an externally supplied synthetic restriction rule, seeds/fertiliser, vegetables by grade, timber, screws, packaging, preserves, lodging services and hunting extras. Units include head/each, kg, litre, metre, hectare, hour and night, with explicit product conversions. Do not supply therapeutic dosing or food-safety parameters as if they were approved practice.

Animal fixtures include an individually tagged cow, a counted sheep group, a replacement tag, birth, death and movement discrepancy. Crop fixtures include exclusive and deliberately intercropped allocations. Production fixtures contain an input lot, main output, by-product/waste, quality hold and rework. Stay fixtures include one last room, one guide/vehicle slot and one remaining synthetic quota allocation.

## 4. Critical invariant groups

### A. Source and native JCB reproduction

- Saved/reopened Fields/Admin Views/children match definitions; every persisted child is attached to exactly one owning component.
- Native import preserves application GUIDs through its approved boundary and rejects duplicate or malformed IDs.
- A custom Power has a real caller, correct namespace/loader and one installation owner.
- API route inventory includes auto-discovered reads and write modes; anonymous/public access is deliberate.
- Fresh export/import/compile/install reproduces the feature without manual generated-file edits.

### B. Access and immutability

- Test permitted and denied roles, unauthenticated user, revoked actor and another-farm actor.
- Test frontend, administrator, API GET/POST/PATCH/DELETE, modal selectors, generic save/trash/copy/bulk actions, import, reports, export and direct document retrieval.
- Immutable posted records reject all editing paths. A form field being hidden is not evidence.
- Confidential payroll/bank/guest data is absent from list JSON, error bodies, exports and cached offline drafts.

### C. Transaction and replay

- Fail after source write, stock write, valuation, journal, audit and outbox stages; independently read database state after rollback.
- Retry identical command after response loss: original result/effects once. Same key with different payload/actor: conflict, no mutation.
- Execute separate requests concurrently against stock, period locks and capacity. Assert outcomes and final sums; sequential calls are not concurrency tests.
- Force worker crash before/after external delivery acknowledgement; verify duplicate-safe retry and visible dead-letter handling.
- Test creation of a previously absent stock-balance key with null logical dimensions; exactly one canonical row survives.

### D. Accounting and stock

- Moving-average receipt/issue/transfer math, zero-balance rounding residue and unit conversions.
- Partial receipt/bill, overbilling tolerance, delivery/invoice/payment separation, deposit liability and cancellation/refund.
- Double-entry, AR/AP allocation, bank/cash close, tax snapshot/rounding, BWP settlement and fees.
- Closed-period write races, late current-period corrections, credits/reversals and retained original evidence.
- Animal count vs inventory identity, harvest/production output vs valuation, stock control vs GL reconciliation.

### E. Domain controls

- Individual/group counts without duplication; treatment restrictions separated by output/action and overlapping intervals; harvest restrictions applied to affected identities and dates.
- Plot allocation, measured vs missing readings, actual input consumption and graded harvest.
- Recipe revision frozen, actual yield/by-products, independent quality/recall holds, traceable rework and conservative recall scope; releasing one hold cannot clear another or double-subtract unavailable stock.
- Half-open room nights, all-or-nothing package resources, expiring holds, guide qualifications, quota exhaustion and real hunt outcome retention.
- Private personnel records, time overlaps, approval/export revisions, meter rollover, maintenance parts and fuel counted once.

## 5. Failure-injection method

Implement test seams in the JCB-maintained service graph, scoped to a test environment, for throwing at named transaction stages. Never leave a public fault-injection parameter enabled in production. Assert counts, versions, quantities, values, statuses and outbox rows before and after a failing command.

For native concurrency, start independent processes/HTTP requests with a barrier so they reach the contention point together. Repeat enough to demonstrate the actual race. Avoid asserting only which caller “won”; assert the invariant regardless of ordering. Retain both response/correlation IDs and the committed state.

For restore, use a genuinely isolated destination. Disable outward delivery and preserve the test's original archive checksum. Test reads and writes after restoration, not only the login page.

## 6. Nonfunctional targets

These are proposed release targets to measure on the agreed hardware/network and synthetic volume from [scope](PRODUCT_SCOPE.md); they are not current measurements.

| Area | Initial target / acceptance |
| --- | --- |
| Common reads | p95 server response under 2 seconds at 20 concurrent active users on the agreed native target |
| Normal business command | p95 under 3 seconds excluding queued document/email work; no integrity loss under contention |
| Large exports | Background/streamed bounded processing with progress, cancellation and scope preservation |
| Lists | Pagination and indexed filters; no unbounded eager load of animal/stock histories |
| Mobile | Usable representative small-screen flow; visible save state; no lost form after validation |
| Accessibility | Keyboard completion, label/focus/error checks, readable magnification/contrast and non-colour-only status |
| Recovery | Demonstrated RPO ≤24h and RTO ≤4h for first supported deployment, or explicitly revised agreed target |
| Availability monitoring | Worker/backup age and critical failures detected by configured alerts; measured operating target decided with host owner |
| Data correctness | Zero unexplained reconciliation differences; no duplicate effects, unbalanced journals or over-capacity confirmations |

Record workload, hardware, cache state, dataset size and network conditions. A warm single-user page load cannot prove the concurrent target. Tune based on measured queries; do not add caches that bypass scope or become a second stock authority.

## 7. Evidence receipt

For each executed case retain: case ID and version, source/tool/runtime SHAs/versions, seed manifest, environment, actor/scope, preconditions, command/request key, expected vs observed result, database/readback evidence, screenshots when presentation matters, logs/correlation IDs, result and reviewer. Mark `passed`, `failed`, `blocked` or `not_run`; never infer passed from no error message.

Sensitive receipts belong in a restricted artifact destination. The public source can include synthetic fixtures, redacted outputs and checksums. Update the handoff with exact unrun stages and limitations. A source citation and a historic Skills test are not this product's test receipt.

## 8. Release gates

| Release | Required coverage |
| --- | --- |
| R0 | Actual JCB source-to-runtime loop, owner service bridge, same-driver atomicity, route audit, source rebuild and restore |
| R1 | Core/stock/trade/pilot flows, role isolation, accountant export, basic recovery and usable farmer capture |
| R2 | Native books, opening balances, complete control reconciliation, FX/tax/period locks and accountant approval |
| R3 | Required livestock/crop/make/stay/work scenarios with ledger effects and domain negatives |
| R4 | Enabled country capability tests, external adapters, bounded offline, native security/concurrency/performance, migration, recovery and independent handoff |

No release with an unresolved critical/high integrity or unauthorised-access defect. Defer an optional capability as a whole when its gate fails; retain working records and clearly disable unsupported actions. A reviewed accepted limitation must describe user impact and safe operation, not redefine a failed invariant as optional.
