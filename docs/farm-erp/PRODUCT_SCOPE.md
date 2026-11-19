# Product scope and release boundaries

## 1. Outcome

Give a Southern African farmer one dependable place to answer: **What needs attention today? What do I own and owe? What did each enterprise cost and earn? Who is doing the work? What commitments have I made?** Capture an event once and reuse it in stock, costing, calendars and accounting through explicit owner services.

The initial market is Namibia, South Africa and Botswana. Initial currency codes are NAD, ZAR and BWP. Country, functional currency and language are independent settings: a Namibian farm may trade in ZAR without being treated as a South African legal entity. Country-specific facts and uncertainties are in the [regional requirements](research/SOUTHERN_AFRICA_REQUIREMENTS.md).

The working product name is **Farm ERP**. Component identifiers in this specification are technical working names, not a decided customer brand.

## 2. Assumed operating envelope

These are product design choices to validate during discovery, not facts supplied about the friend's farm.

| Area | Initial design boundary |
| --- | --- |
| Ownership | One legal entity per Joomla installation; one or several farms, enterprises and stores within it |
| Deployment | Managed Joomla server or a maintained farm LAN server; the browser Playground is a development/validation environment |
| Users | Owner, manager, bookkeeper, stock clerk, supervisor, workers, reservations clerk and restricted advisers |
| Enterprise mix | Enable only enterprises used by the farm; cattle, small stock, crops, manufacture, lodging and hunting are optional |
| Scale target for pilot testing | 1–5 farms; 20 concurrent active users; 10,000 individual animals; 100,000 operational events; 25,000 stock lines per year; 20 accommodation resources |
| Larger scale | A benchmark target can be increased after measuring a representative deployment; these numbers are not measured capacity claims |
| Financial scope | Operational pilot with accountant export; later tested double-entry books, reconciliation and period close |
| Countries | Three separately versioned country packs; no automatic assumption that national or provincial rules match |
| Connectivity | Responsive online/LAN capture first; explicitly bounded offline draft capture later |
| Languages | English initial interface; all interface strings translatable; Afrikaans and locally selected languages follow actual user demand |

Separate companies, franchises, public multi-tenant SaaS, automatic cross-border tax decisions, and consolidated group accounts are outside the first product. They require a later architecture decision, not a hidden `company_id` added to otherwise unisolated tables.

## 3. Functional coverage

| Area | Required capabilities | Deliberate limits |
| --- | --- | --- |
| Livestock | Individual cattle and breeding stock; grouped sheep/goats where appropriate; identifiers, purchases, births, parentage, weights, breeding, treatments, withdrawal blocks, feed, paddock changes, mortality, sales and movement documents | No automatic veterinary diagnosis or treatment prescription; official livestock systems remain authoritative |
| Crops / gardens | Fields and beds, growing cycles, crop/variety, planting, soil observations, irrigation, labour/input cost, pest observations, harvest grades, lot creation, waste and market allocation | No automatic pesticide legality or application recommendation; agronomic settings require competent approval |
| Stock and trade | Products, units, lots, stores, transfers, reservations, procurement, receipts, purchase bills, quotes, orders, delivery, invoices, returns, payments, petty cash and farmer-market cash close | No uncontrolled negative stock; no anonymous changes to final documents |
| Accounting | Chart of accounts, journals, receivables/payables, tax snapshots, FX, bank reconciliation, cost centres, budgets, assets/depreciation, period lock and accountant exports | Statutory filing and tax/payroll calculations remain disabled until the applicable pack is verified |
| Woodwork / manufacturing | Timber sources and grades, cut/assembly jobs, BOM revisions, batch/job production, tools/labour/overhead, yield, offcuts, by-products, rework and sale | No broad engineering CAD or unrestricted manufacturing configurator in the first version |
| Food / preserved products | Recipes, ingredient and packaging lots, processing records, expiry, quality hold/release, actual yield, costing, labels and recall trace | No inferred food-safety certification; quality requirements depend on product and jurisdiction |
| Hunting and lodging | Enquiries, quotations, deposits, resource holds, accommodation nights, guides/vehicles, hunting eligibility, season/species/quota checks, permit evidence, package allocation, check-in/out and final invoice | Wildlife populations, hunting quotas and lodging capacity are different resources; no generic worldwide booking engine |
| Staff and daily work | Employee/contractor records, tasks, crews, attendance, leave, timesheets, skills/certification expiries, accommodation/equipment allocation and approved payroll export | No statutory wage, deduction or benefits engine in pilot; no biometric tracking by default |
| Farm infrastructure | Boreholes, water points, tanks, rainfall, fuel, meters, fences, vehicles, service schedules, breakdowns, fire/drought plans, inspections and incident follow-up | No autonomous machine, pump, gate or weapon operation; sensor integration is advisory initially |
| Management | Cash due, exceptions, task list, booking calendar, head counts, stock and input availability, enterprise margins, production/harvest performance, water/fuel trends | Dashboards show freshness and provisional figures; no false precision from incomplete allocations |

## 4. Progressive releases

### R0 — feasibility and architecture proof

Produce two native JCB components with working master/detail records, a protected command, cross-component service use, a real rollback, an export/rebuild, and an independent environment restore. Resolve shared Power loading and route exposure before scaling. R0 uses synthetic data.

### R1 — farmer pilot

Core setup, private documents, basic livestock and tasks, stores and lots, purchase/receipt and sale/payment recording, manual expense capture, cash close, simple dashboard and accountant export. Country identity and reference-data choices are reviewed. The farm can use the pilot while keeping established statutory books externally. Provisional stock costing must reconcile to its own operational valuation report.

### R2 — controlled ERP foundation

Activate native double-entry accounting only after account mappings, opening balances, stock-to-GL reconciliation, tax settings and period-close tests pass. Add receivables/payables, bank reconciliation, credits/refunds, budgets, assets/depreciation and controlled approvals. The accountant signs off representative statements; no module silently writes to a closed period.

### R3 — diversified farm operations

Add full herd/group management, crop cycles and harvest, wood/food production, traceability and recall, lodging/hunting bookings, workforce, infrastructure and asset maintenance. Each enterprise ships as a tested vertical slice with its ledger effects and farmer workflow.

Selected operational enterprise slices can follow the R1 foundation while R2 native accounting proceeds in parallel. This lets the first farmer use woodwork or basic lodging with accountant exports; it does not postpone his main enterprises behind every native-accounting feature. The complete ERP release still requires the accounting and regional gates.

### R4 — regional hardening and general release

Validate all three country packs with local reviewers, field connectivity, recovery, import/export, security, performance and staff usability. Add bounded offline draft capture and selected integrations only after their own tests. A deployment enables only the packs and advanced features that passed their gate.

The [delivery roadmap](DELIVERY_ROADMAP.md) decomposes these releases into ordered work packets. R1 is not the end of the roadmap.

## 5. Success criteria

1. The farmer records routine work in a task-oriented frontend without navigating JCB or a technical Joomla administration form.
2. One physical event creates one authoritative operational record. Stock and financial effects are attributable, atomic and retry-safe.
3. A worker cannot discover another farm's confidential records through selectors, URLs, downloads, reports or APIs.
4. A booking cannot oversell a room, guide/vehicle slot or approved hunting allocation under simultaneous requests.
5. Purchased and produced lots can be traced to consumption, outputs and customers, including returns and recalls.
6. Head counts, inventory quantities, stock values, receivables/payables and GL control accounts reconcile under documented rules.
7. A second agent can import the maintained JCB sources, compile, install and reproduce the tested workflow without manually fixing generated files.
8. A tested backup can restore business service and prove its recovery point, not merely download a ZIP.

Detailed thresholds, fixtures and evidence requirements are specified in the [acceptance plan](ACCEPTANCE_AND_TEST_PLAN.md).

## 6. Scope discipline

Do not build a second user directory, a second file manager or independent product/customer masters in each component. Reuse suitable Joomla/JCB capabilities. Do not add message brokers, separate microservices, Kubernetes, AI decision automation or a general workflow language to solve the first farm's requirements.

Keep additions tied to a named farmer scenario, an owning entity, a state transition, an accountable user and a test. An optional feature stays optional in installation and navigation. An unknown operational detail becomes a visible decision with a safe default or a blocked activation, never an invented fact about the farm.
