# ERP reference comparison and adoption decisions

Research date: **19 November 2026**. Scope: the three repositories supplied for this project. This document records what those sources contribute to a new JCB farm ERP; it does not claim that a Joomla implementation already exists or that it reproduces any upstream product.

## 1. What the three sources actually are

All three repositories are independently maintained ERP specifications under `vast-development-method`. They describe business records, calculations and operating behavior in language-neutral form. They are not the upstream vendors' manuals, and a repository name is not proof of the version, edition, enabled modules or runtime configuration behind every statement. The design should use their business evidence while making its own small, explicit set of product decisions. [D01] [E01] [O01]

| Reference | Exact documentation revision inspected | Commit date | Evidence and limits |
|---|---|---|---|
| `dolibarr-doc` | `640ff739840dca25015a704300b2e78ee7269656` | 2026-11-18 | Concise transaction-oriented blueprint, physical and service catalogues, worked examples and controlled failure/concurrency observations. The scope of an observation varies: some are isolated methods, some database schedules, some simulated collaborators. The reviewed overview does not establish one upstream release/edition for the whole repository. [D02] [D07] |
| `erpnext-doc` | `61a1196824f8df82127627d475599266244b71ce` | 2026-11-19 | Detailed business contracts, optional-extension distinctions, current-binding catalogues, selected committed runtime observations and a qualification register. The committed receipt-to-cash fixture names ERPNext **16.60.0**, Frappe **16.60.1**, ERPNext source `886ab6ae187244e7f1b852393384ab6019d56264` and Frappe source `199a0385c00e572664a099a57a00be6ce7404eeb`. These identify that fixture, not every optional capability in the repository. [E02] [E03] [E04] |
| `odoo-doc` | `81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0` | 2026-09-12 | Large domain-oriented rebuild specification, structural catalogues, detailed calculations and acceptance scenarios. Its evidence report distinguishes structural coverage, authored behavior and arithmetic checking, and says that differential execution against a running reference application has not been performed. The reviewed overview does not establish one upstream version/edition for all domains. [O01] [O02] |

### A source inconsistency that must not become a roadmap claim

The Odoo reference's coverage report says, for example, that repair and maintenance has zero of eleven narrative files and multi-currency has three. The actual tree at the same pinned revision contains all eleven standard files in both directories. Its repair and maintenance and currency introductions also link to those files. Treat the coverage table as a stale checkpoint, not a current completeness measure. Inspect the relevant chapter and any evidence artifact directly. File presence, even when verified, is not proof of implementation completeness or numerical correctness. [O02] [O07] [O08]

### Evidence labels for this project

| Label | Meaning | Use in implementation |
|---|---|---|
| **Source contract** | A rule described in a pinned blueprint chapter | Derive a proposed invariant, then test it in Joomla. |
| **Recorded observation** | The blueprint includes a run record with a stated profile and observed outputs | Reuse the scenario and compare scope; do not silently generalize to all roles or configurations. |
| **Farm design decision** | A choice made for this product | Implement according to this roadmap; do not attribute it to an upstream ERP. |
| **Regional qualification** | A rule whose correct value depends on jurisdiction and effective date | Use the regional research and a qualified release review before activation. |
| **Unproven capability** | A behavior not demonstrated on the target JCB/Joomla/database combination | Schedule a proof before depending on it. |

The ERPNext committed fixture used an Administrator identity and calls within its runtime. Its own description excludes general conclusions about HTTP behavior, role-specific access, concurrent writers and worker recovery. Its selected stock tests likewise qualify their synchronous or controlled orderings. These are useful reference observations, not a passing test result for this farm ERP. [E03] [E05]

## 2. Overall adoption strategy

Use **Dolibarr's clear document chains and operator-oriented workflows**, **ERPNext's stock, production, project and crop contracts**, and **Odoo's domain boundaries, accounting controls and resource models**. Adopt the smallest consistent combination. Do not copy three overlapping master-data systems or expose their combined configuration surface to the farmer.

The target is one product with seven cooperating JCB components:

| Component | Business ownership used in this research |
|---|---|
| `com_farmcore` | Shared identity, farms, parties, product masters, settings, documents, access context and common workspace |
| `com_farmledger` | Procurement, sales, cash, stock movements and valuation, accounting/export, later complete double-entry ledger |
| `com_farmlivestock` | Animal and flock records, reproduction, health, grazing and livestock operations |
| `com_farmcrops` | Land, crop cycles, field work, observations, input use and harvest |
| `com_farmmake` | Recipes, woodworking jobs, processing, production actuals and genealogy |
| `com_farmstay` | Lodging, guests, bookings, hunting-service reservations and resource claims |
| `com_farmwork` | People, time, tasks, equipment, maintenance, water and farm service operations |

These are the farm product's proposed boundaries. They are not an assertion that any reference product uses the same architecture. Stock and accounting effects stay with one owner because a trustworthy commercial transaction depends on their consistency. Other components call that owner's service inside the same outer database transaction. A transaction outbox handles later external delivery; it does not make stock or financial integrity asynchronous.

## 3. Capability comparison

The columns summarize the inspected blueprint evidence, not a competitive rating of the upstream products. “Not established” means this research did not establish that specialist capability from the cited source; it does not mean no extension exists anywhere.

| Capability | Dolibarr reference | ERPNext reference | Odoo reference | Farm product decision |
|---|---|---|---|---|
| Party and document identity | Separates parties, contacts, document headers and quantitative source-line links. [D03] | Keeps shared customer, supplier, item and original child-row identity through handoffs. [E01] [E02] | Shared contacts and company-aware domain model. [O01] | One party master with customer/supplier/guest roles. Do not make a new person for every business role. |
| Procurement and fulfilment | Order, receipt, supplier invoice and payment are distinct. Stock-posting timing is configurable. [D04] [D05] | Received-but-unbilled clearing, receipt rows, stock value and payable settlement are traced end to end. [E06] | Purchasing connects orders, receipts and bill-control policies. [O03] | Receipt changes stock; approved bill changes payable; payment changes cash. Fix this policy initially instead of offering every possible posting event. |
| Sales and collections | Preserves order-line fulfilment, partial shipments, invoice totals and payment allocations. [D04] | Separates delivery, invoice, physical return, commercial credit and allocation. [E03] [E06] | Sales, receivables and payment domains specify related state machines and effects. [O03] | Keep ordered, reserved, delivered, billed, returned and paid quantities/amounts distinct. |
| Double-entry accounting | Describes account binding and later journal transfer; observed concurrency cases demonstrate why balance alone is insufficient. [D06] [D07] | Financial effects are tied to vouchers; qualification remains necessary for the replacement. [E02] [E03] | Strong invariants for balance, company coherence, period locks, posting numbers and protected entries. [O04] | Native accounting is a separate hard-gated release. Before that, operational books and accountant export must be clearly labelled. Posted accounting is immutable and corrected by linked reversal. |
| Inventory and valuation | Signed movements plus warehouse/lot balances and moving-average cost. [D05] | Detailed stock ledger, reservations, cost layers, quantity/value reconciliation, landed costs and reposting. [E07] | Separates physical operations from valuation; cost methods and negative-stock correction branches are explicit. [O05] [O06] | One authoritative movement ledger. Choose and test a limited valuation policy; retain item/location/lot/owner dimensions. Forbid negative stock initially. |
| Lots, serials and recall | Documents the difference between order-level co-occurrence and actual input-to-output genealogy. [D10] | Serial/batch allocations, expiry selection, returns and manufacturing identities. [E05] [E08] | Tracked movement detail, serial uniqueness and manufacturing consumption/output links. [O05] [O09] | Store explicit production-batch inputs and outputs. Where allocation is batch-wide, recall every possibly affected output; never imply finer traceability than recorded. |
| Units and packaging | Recipe quantities distinguish reference batch, line unit and actual production. [D09] | Stock unit, packaging conversion and formula scaling are explicit; dimensional conversion must be valid. [E07] [E09] | Product units, conversion precision and frozen completed-movement units are specified. [O10] | Distinguish head, kg, litre, metre, square metre, cubic metre, hectare, each, crate and bag. Catch weight is a measured second quantity, not a fixed head-to-kg conversion. |
| Crop and garden cycles | Generic projects and stock can carry cost, but specialist agronomy was not established. [D12] | Dedicated crop/cycle/land/observation/project contracts. Creating a cycle does not itself consume inputs or create harvest stock. [E10] | Generic project, inventory and manufacturing patterns; specialist local crop behavior not established. [O01] | Dedicated crop component with plot-season identity; actual inputs, labour and harvest connect to ledger. |
| Cattle, sheep and goats | Specialist herd/flock behavior not established. | Specialist herd/flock behavior not established in the inspected crop/industry material. | Specialist herd/flock behavior not established. | Original domain design required: individual and group tracking, births/deaths, movement, mating, weights, health, treatments, withdrawal and sale. Generic product stock cannot replace the animal record. |
| Bills of materials and work orders | Clear planned-versus-actual lines, partial runs, service costs and disassembly. [D09] | Multilevel recipes, operation costs, loss, secondary outputs, consumption modes and capacity. [E09] | BOM cycles, variants, by-product cost shares, work orders and serial rules. [O09] | Begin with single-level recipes and actual consumption/output. Add multilevel production and advanced scheduling only after the simpler traceable flow passes. |
| Food processing | Generic lots and production supply a foundation. [D09] [D10] | Loss, yield, secondary cost allocation and repacking are explicit. [E09] | Manufacturing and lot behavior support process structure. [O09] | Add recipe revision, allergens, input/output batches, best-before/expiry, quality hold/release, label revision and recall. Product safety rules require separate validation. |
| Subcontracting | Supplier/services and manufacturing links exist; do not infer complete outsourced production from a generic purchase order. [D09] | Distinguishes company-owned supplied material from supplier conversion charges and accepted/rejected outputs. [E11] | Explicit subcontracting constraints and production links. [O09] | Phase later. Preserve ownership and custody; stock sent out is still farm-owned until consumed/disposed by the authorized workflow. |
| Woodworking and made-to-order sales | Project-linked labour and manufacturing actuals fit workshop jobs. [D09] [D12] | Job cost includes consumed material, capitalized freight and labour with currency-aware attribution. [E12] | Make-to-order and manufacturing cross-domain traces. [O03] | One customer job can combine quote, deposit, BOM, production, delivery and margin. Timber dimensions/grade/species and offcuts are explicit. |
| Farmers' market counter | POS and margin contracts exist. [D01] | Receipt/sale/settlement patterns and general POS references. [E01] | Detailed POS sessions, orders and payment effects. [O11] | Simple touch-friendly online sale, cash float, split tender and close. Initial offline capability is limited to authorised observation drafts; offline sales, payments and stock finalisation require a separately approved scope and proof. |
| Lodging | Agenda/resource/event material is adjacent, not proof of a full room-night engine. [D01] | Specific room/package/nightly pricing and occupancy algorithms; documented interval/counter edge cases need deliberate changes. [E13] | Calendar and service patterns; a complete local lodge engine not established. [O01] | Own physical room/night allocation with half-open stays, expiring holds, maintenance blocks, guest/payer separation and folio. |
| Hunting reservations | Specialist permit, quota, guide and trophy-custody workflow not established. | Specialist local hunting workflow not established. | Specialist local hunting workflow not established. | Original booking extension with resource scheduling and separate regulatory gates. A booking is not authorization to hunt or proof of animal availability. |
| Staff and time | Leave, expenses, task time and copied historical labour rates. [D11] [D12] | Effective salary assignments, payroll accrual, employer contributions and payment are separate. [E14] | People, attendance, leave and work-entry domains; country payroll cannot be inferred from these alone. [O01] [O02] | Staff, time, leave and payroll-ready export first. Separate employee payables and employer obligations. No claim of compliant payroll before country-specific qualification. |
| Equipment, maintenance and water | Assets, projects and service records provide useful patterns. [D01] | Asset capitalization and project cost contracts. [E12] [E15] | Distinguishes equipment maintenance from repair stock effects; a maintenance card alone does not post material cost. [O07] | Service jobs explicitly request part issues and labour from ledger/workforce owners. Add meter readings and water-system records, not fabricated automatic integrations. |
| Multi-currency | Documents stored rates, amounts in both currencies and settlement residuals, including unsafe fallback possibilities. [D08] | Retains transaction versus company amounts; project examples show why the distinction matters. [E12] | Separate rate lookup, conversion and settlement calculations. [O08] | Initially NAD, ZAR and BWP. Persist direction, date, source and rate; never substitute rate 1 for a missing foreign rate. Preserve invoice and payment rates separately. |
| Country localization | Country charts/tax dictionaries and export formats are catalogued, not proof of current local compliance. [D02] | Explicitly requires jurisdiction and effective-date rules beyond fixtures. [E14] [E16] | Separate localization domain with country configuration and document rules. [O12] | Three country packs with dated policies and test evidence. A currency selector does not select a tax regime. |
| Permissions and tenant scope | Domain grant plus record/entity scope; UI and direct service can differ. [D03] [D11] | Qualification explicitly covers all entry paths, roles and installed composition. [E02] | Domain rights plus record/company rules. [O01] [O04] | Server-enforced farm scope on every query and mutation, including exports, downloads and selectors. One legal entity per installation initially. |
| External delivery and recovery | Relay acceptance, local send history and recipient evidence can disagree after retry. [D13] | Remote providers, job recovery and concurrency need separate qualification. [E02] [E16] | Transaction hooks and transport contracts supply patterns, not Joomla guarantees. [O13] | Durable outbox with unique intent, attempts and external reference. A successful HTTP result is not automatically a bank settlement or filing acceptance. |

## 4. Specific behaviors to change deliberately

These are bounded statements about the pinned blueprints and stated configurations. They are not claims that every installation of the upstream software behaves the same way.

| Documented behavior | Risk in a farm product | Required farm design |
|---|---|---|
| Dolibarr source-based journal checks can admit overlapping duplicate posting, even while each journal balances. [D06] [D07] | Duplicate invoice, stock or payment value. | Unique posting identity at the database boundary, idempotent command receipt, atomic source state and effects; test with two sessions. |
| Dolibarr stock schedules demonstrate stale absolute balance writes. [D07] | Two storekeepers consume or receive against the same balance incorrectly. | Lock the authoritative balance/cost rows and update under a single transaction; prohibit read-compute-write outside that boundary. |
| Dolibarr partial production uses descriptive movement codes rather than a request-key lookup. [D09] | Retrying a timed-out production action duplicates output. | Globally unique command key scoped to the installation/company; same key and payload returns the prior committed result. |
| Dolibarr transfer movements can commit before header status. [D05] | The screen says “not sent” although stock already left. | Dispatch status and source/transit movements commit together; receipt and transit/destination movements commit together. |
| Dolibarr production actuals show order membership without proving individual serial genealogy. [D10] | Under-recalling food or implying the wrong source lot. | Persist a production batch and its actual input/output membership; use explicit finer allocations only when recorded. |
| Dolibarr currency lookup can fall back to later observations or unresolved-rate behavior. [D08] | Silent foreign-currency misstatement. | Fail with an actionable missing-rate error; permit an authorized, reasoned manual rate with provenance. |
| ERPNext hospitality pricing uses departure-exclusive nights while the described existing occupancy uses the departure day inclusively. [E13] | Refused back-to-back stays and misleading occupancy. | Use one canonical `[arrival, departure)` night definition for quote, availability, claim, report and cancellation. |
| ERPNext hospitality counters differ between repeated package rows and room-type capacity. [E13] | Package aliases can miscount shared rooms. | Allocate against physical room identity or one atomic room-type/night pool, not independently per package. |
| ERPNext's recorded mapped-credit scenario shows correct control-account net balance with misallocated invoice/credit residuals. [E03] | “Customer settled” while the actual invoice remains open. | Recompute server totals before validation and verify source-level settlement as well as net account balance. |
| Reference production paths distinguish actual zero cost from missing cost and sometimes use zero as a fallback trigger. [E09] | A genuinely free input gets an invented historical cost. | Nullable cost state plus explicit zero; use fallbacks only when basis is absent, never solely because arithmetic equals zero. |
| ERPNext project-cost paths can use different currencies and filters under different controllers. [E12] | Farm enterprise margins combine incomparable amounts. | One base-currency reporting contract and explicit cost inclusion rules; show commitments, actuals, cash and operational estimates separately. |
| Odoo's detailed runtime describes a particular database isolation and retry model. [O13] | Copying its assumptions into MariaDB/MySQL without equivalent locks. | Specify and test the actual Joomla connection, engine and isolation behavior; preserve business invariants rather than database implementation assumptions. |

## 5. What to reuse, adapt, postpone and exclude

### Reuse as core patterns

- Shared identities and explicit source-line links across orders, deliveries, invoices, credits and payments. [D03] [E06]
- An immutable stock movement history with current balances that can be reconciled to it. [D05] [E07]
- Separation of commercial agreement, physical fulfilment, accounting recognition and cash settlement. [D04] [O03]
- A recipe snapshot and planned lines that remain separate from actual inputs, outputs, losses and time. [D09] [E09]
- Stable currency/unit meaning and server-side recalculation at the action boundary. [D08] [E12] [O10]
- Per-workflow acceptance cases with exact balances, denied operations, reversal and retry outcomes. [E02] [O14]

### Adapt for this farmer

Add the specialist records that generic ERP lacks: tag history, breeding and herd events; medicine/chemical lots and legal hold periods; water and grazing; plots and harvest lots; room-night claims; hunt permits/quotas and custody; small workshop orders; farmers' market shifts; simple employee task capture. These are original requirements to be validated with the farmer and regional evidence. No generic inventory or calendar feature establishes these specialist rules by itself.

### Postpone until the dependency and evidence gates pass

Full accounting, payroll calculation, automated bank feeds, tax filing, advanced capacity planning, general-purpose workflow builders, multilevel manufacturing, subcontracting, intercompany operations and unrestricted offline financial posting. Postponement means a later roadmap milestone with acceptance criteria, not removal from the eventual ERP scope.

### Exclude from the initial product

Global fiscal localization, a marketplace of arbitrary executable business rules, a replacement for Joomla authentication, an Odoo-style universal ORM/runtime, a Frappe-style general platform rebuild, every-country e-invoicing, complex corporate consolidation, marketing automation and enterprise HR recruitment suites. These would enlarge the maintenance burden without establishing the farmer's daily workflow.

## 6. Farm acceptance coverage derived from the references

| Acceptance family | Minimum evidence the JCB implementation must produce | Primary pattern sources |
|---|---|---|
| Procure to use | Order → lot receipt → supplier bill → payment → feed/seed/material issue; partial and duplicate attempts reconciled. | [D04] [E06] [E07] |
| Make to sell | Recipe revision → actual consumed lots → finished batch → delivery → invoice → payment → return/credit. | [D09] [D10] [E09] [O03] |
| Crop to market | Cycle/plot work → input use/time → harvest lot → graded packs → market sale → waste/recall. | [E10] [E09] [O11] |
| Stay to settlement | Quote → room-night hold → confirmation/deposit → check-in → charge/folio → checkout → allocation/refund. | [E13] plus original farm booking design |
| Worker to cost | Authorized work/time → reviewed rate snapshot → enterprise cost → expense/payroll export → payment evidence. | [D11] [D12] [E14] |
| Historical correction | Approved reversal links to original; stock/finance balances and outstanding items agree; closed periods remain protected. | [D06] [E02] [E03] [O04] |
| Concurrent claims | Two writers cannot both consume the last item, book the same room, issue the same number or apply the same payment remainder. | [D07] [E02] [O13] |
| Partial failure | Interrupted posting leaves either complete durable effects or none; queued external delivery can resume safely. | [D13] [E02] [O13] |
| Scope enforcement | Role and farm restrictions hold in UI, service calls, filtered lists, selectors, documents and exports. | [D03] [E02] [O04] |

The numerical and failure scenarios in [ERP_WORKFLOW_PATTERNS.md](ERP_WORKFLOW_PATTERNS.md) turn these patterns into farm-specific acceptance cases. They are proposed product fixtures, not observations from a running farm ERP.

## 7. Attribution, licensing and maintenance

Each inspected documentation repository contains an Apache 2.0 `LICENSE`. That is an observed property of these repositories. It is not evidence that every referenced upstream source file, third-party integration, image, trademark, sample or commercial extension has the same license. This roadmap uses paraphrased behavior and links. Before importing implementation code or redistributing another artifact, record its own provenance and terms in the implementation repository; preserve required attribution and notices. [D14] [E17] [O15]

At each implementation milestone, record the JCB, Joomla, database and skill revisions actually used; retain this research snapshot for reproducibility. If a later source changes, compare the affected behavior and update the owning requirement and fixture together. Do not automatically import a new default just because an upstream branch advances.

## Source register

All links below are immutable documentation snapshots inspected for this research.

[D01]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/README.md
[D02]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/coverage/checkpoint.md
[D03]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/platform/rebuild-contract.md
[D04]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/trade/worked-cycle.md
[D05]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/supply/stock.md
[D06]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/finance/bookkeeping.md
[D07]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/concurrent-posting/README.md
[D08]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/international/currency-from-quotation-to-settlement.md
[D09]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/operations/manufacturing.md
[D10]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/production-control/lot-reconciliation.md
[D11]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/people-services/expenses.md
[D12]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/operations/project-time.md
[D13]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/delivery-evidence/README.md
[D14]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/LICENSE
[E01]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/README.md
[E02]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/rebuild/qualification.json
[E03]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/rebuild/live/README.md
[E04]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/rebuild/live/observed.json
[E05]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/rebuild/stock-live/README.md
[E06]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/transactions/receipt-to-cash.md
[E07]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/inventory-and-valuation.md
[E08]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/traceable-stock-and-service.md
[E09]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/manufacturing-and-subcontracting.md
[E10]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/agriculture.md
[E11]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/subcontract-cost.md
[E12]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/transactions/project-costing.md
[E13]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/hospitality.md
[E14]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/people-and-services/payroll-posting.md
[E15]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/transactions/assets-and-depreciation.md
[E16]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/references/coverage-and-evidence.md
[E17]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/LICENSE
[O01]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/README.md
[O02]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/reimplementation/coverage-and-evidence.md
[O03]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/cross-domain-transactions.md
[O04]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/general-ledger/business-rules.md
[O05]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/inventory-operations/business-rules.md
[O06]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/inventory-valuation-and-costing/README.md
[O07]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/repair-and-maintenance/README.md
[O08]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/multi-currency/README.md
[O09]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/manufacturing/business-rules.md
[O10]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/units-of-measure-and-packaging/business-rules.md
[O11]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/point-of-sale/README.md
[O12]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/fiscal-localizations/README.md
[O13]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/runtime/transactions-and-concurrency.md
[O14]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/reimplementation/conformance-profiles.md
[O15]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/LICENSE
