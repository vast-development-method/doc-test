# Decisions, risk register and farmer discovery

## 1. Accepted design decisions for this roadmap

These decisions make the build concrete. They can be revised with evidence, but changes must update the schema, affected contracts, milestone dependencies and acceptance cases together.

| ID | Decision | Reason / consequence |
| --- | --- | --- |
| ADR-01 | Native JCB source from the first record | Preserves repeatable compilation; no new scaffold followed by Extrusion |
| ADR-02 | Seven components with one owning table/service boundary each | Clear responsibility without one component per minor farm feature |
| ADR-03 | One legal entity and transactional database per installation; multiple farms/enterprises | Avoids unproven multi-tenant isolation and intercompany accounting in the first product |
| ADR-04 | Core owns common masters; Ledger owns trade/stock/financial effects | Prevents duplicated parties/products and inconsistent money/stock posting |
| ADR-05 | One outer transaction and same driver for critical owner calls | Domain completion cannot survive without its stock/accounting effects |
| ADR-06 | Transactional outbox for external delivery | Email/API outages do not corrupt business records; retries remain visible and deduplicated |
| ADR-07 | Numeric Joomla PK plus portable application GUID | Preserves Joomla conventions and import identity; neither equals a JCB definition GUID |
| ADR-08 | Normalised child entities and managed vocabularies | Queryable, scoped, auditable rows; no reliance on display-only subform XML |
| ADR-09 | Commands for posting/confirmation; native CRUD for appropriate drafts/masters | Prevents generic routes bypassing finance, stock, capacity and restriction rules |
| ADR-10 | Operational/export mode is independently useful; native books are gated | Farmer value can arrive before statutory accounting activation; no misleading financial claims |
| ADR-11 | M06–M10 can follow M04 while native books proceed | Workshop/lodging/livestock need not wait behind the accounting track |
| ADR-12 | Perpetual moving-average pools, no negative availability initially | One explicit valuation policy is testable; FIFO/retroactive recosting are later separate decisions |
| ADR-13 | NAD, ZAR, BWP; one functional currency per installation | Regional focus; exchange identity/rates/fees preserved even where parity applies |
| ADR-14 | Country packs are dated and capability-specific | Stale summaries or another country's rules cannot silently become production configuration |
| ADR-15 | One physical room/resource capacity model, half-open stays | Packages cannot double-sell the same room or count departure as another occupied night |
| ADR-16 | Wildlife observation, approved hunting quota and booking are separate | Commercial acceptance does not grant legal permission or manufacture wildlife inventory |
| ADR-17 | Independent stock holds and output-specific animal restrictions | Releasing one condition cannot clear another; conservative traceability when finer identity is absent |
| ADR-18 | Frontend Farm Desk for normal users | Farmers operate tasks and records without learning compiler/admin internals |
| ADR-19 | Responsive online/LAN first, bounded offline drafts later | Prevents disconnected overselling, financial conflicts and false confirmations |
| ADR-20 | Payroll export first; optional statutory payroll later | Staff management is delivered without inventing country wage/deduction logic |
| ADR-21 | Shared runtime/Power ownership is a proof, not an assumption | Current JCB templates do not promise an arbitrary public service container |
| ADR-22 | Rebuild, restore, upgrade and local sign-off are release evidence | A large schema or successful compile is not a stable product |

## 2. Technical and operating risks

| Risk | Priority | Mitigation / gate | Owner |
| --- | --- | --- | --- |
| Cross-component bridge or shared namespace cannot be maintained natively | P0 | M01 actual two-component bridge, then three-owner transaction; retain source and repeatability evidence | JCB lead |
| Hidden Joomla Table/asset commit breaks rollback | P0 | Inspect actual path; fault-inject every write stage on same driver; avoid unsafe writes inside posting UoW | Architecture/Ledger |
| API auto-discovery exposes confidential reads or generic writes | P0 | Generated route inventory; per-action/scope tests including anonymous and Registered users | Security lead |
| Subform replacement purges or rewrites posted children | P0 | Command-owned immutable lines; strict shape validation; normalised child views; malformed-input test | JCB/Ledger |
| Duplicate stock/GL effects after timeout/retry | P0 | Receipt and source-effect uniqueness; atomic results; independent readback | Ledger |
| Nullable balance key or capacity creation race bypasses locks | P0 | Non-null canonical identity; unique index and absent-row race tests; stable resource locks | Ledger/Stay |
| Conflicting/stale tax, wage or permit guidance | P1 | Approved effective-date country pack with instrument/commencement evidence; disable unsupported capability | Regional reviewer |
| One release clears another hold/restriction | P1 | Independent records and union eligibility; tests across every issue/dispatch route | Ledger/Livestock/Make |
| Farmer UI becomes a large ERP administration panel | P1 | Task-led frontend, optional menus, observed pilot usability | Product/frontend |
| Source export misses Powers, initial-data dependencies or assets | P1 | Closure manifest and independent JCB reacquisition/rebuild | Build lead |
| Backup exists but restore fails or resends external messages | P1 | Isolated restore, key/file/database reconciliation, outbound disable/dedup | Operations |
| Import duplicates history and opening balances | P1 | Explicit cutover boundary, staged keys, reconcile opening vs historic events | Migration/accountant |
| Source/Playground concurrency overwrites work | P1 | One controller per workspace; source owners; serial integration | Lead agent |
| Medicine/food/hunting data is interpreted as expert authorisation | P1 | Store reviewed evidence; explicit scope/status; no auto-prescribing or permit issuance | Domain owner |
| Partial offline capture mistaken for completed business action | P1 | Draft-only bounded scope and visible per-item sync results | Frontend/Core |
| Unsupported native server/library differs from browser runtime | P1 | Same supported target family; native decimal/concurrency/cron/transport tests | Build/operations |
| Full feature catalogue overwhelms budget | P1 | Complete vertical pilot, measured estimates, optional module rollout; protect integrity gates | Product owner |

P0 blocks dependent architecture expansion. P1 blocks the affected release/capability. A risk is closed by recorded evidence, not by changing its label.

## 3. Questions for the first farm

The user requested research, so these are recorded for M00 instead of interrupting this work. The implementing agent can proceed with labelled synthetic fixtures while arranging the relevant answers.

| Decision needed | Why it matters | When needed / responsible person |
| --- | --- | --- |
| Which legal entity, country and farms are in the first deployment? | Functional currency, tax/permit scope, privacy and opening balances | M00; farmer/accountant |
| Which two or three daily workflows save the most time first? | Chooses pilot scope without dropping the complete roadmap | M00/M04; farmer and capture staff |
| Is the existing accountant using a particular product/file format? | Determines export schema, account mapping and native-book cutover | Before M03 export completion; accountant |
| How many cattle/sheep/goats are individually tagged vs counted groups? | Identity, movement, count and treatment-target model | Before real Livestock import; farmer/veterinary adviser |
| Which animals/products are inventory vs biological/long-lived assets? | Avoids invented valuation/depreciation treatment | Before native financial activation; accountant |
| Are medicines/chemical restrictions currently recorded, and who approves them? | Required source/evidence and eligibility checks | Before regulated movement/harvest capture; authorised adviser |
| What stores, package sizes, market tills and timber/food units are actually used? | Unit conversions, stock migration, costing and cash close | M02–M03; stock/production users |
| Which rooms/camps, guide/vehicle resources, packages and hunting jurisdictions apply? | Physical capacity, pricing, documents and quota | Before M09 live use; operator/local reviewer |
| Are there actual food/feed production permits, quality plans and label obligations? | Product-specific quality/traceability configuration | Before M08 live production; responsible producer/local reviewer |
| Which roles may see pay, bank and guest documents? | Least privilege and field-level access | Before live user access; owner/privacy lead |
| Where do users have connectivity, and what devices/scanners/printers exist? | Online/LAN deployment and meaningful offline scope | M00/M04; actual capture users |
| Who maintains hosting, backups, upgrades and incident response? | Determines achievable recovery and operating cost | Before pilot business data; host/support owner |
| What data should migrate and at what cutover date? | Opening balances vs history and reconciliation | Before M14 rehearsal; farmer/accountant |
| What final branding/languages/document terms are required? | User-facing labels, translations and commercial documents | Before production-facing templates; owner |

No answer is invented. A missing decision only blocks the dependent live capability; it does not stop research, synthetic tests or unrelated component work.

## 4. Change control

When altering a decision, state the old/new rule, evidence, affected owners/entities/commands/reports and migration/test consequences. Preserve earlier source provenance. A new component boundary requires a dependency-cycle and transaction review. A new country/currency requires a pack/rounding/privacy review. A new generated API requires an exposure review.

Keep small unresolved product details in the implementation backlog. Do not turn routine native JCB implementation choices into repeated permission questions when the user's scope already authorises them. Ask only for missing consequential business decisions, credentials/access or external effects that the current instruction does not authorise.
