# Farmer experience and daily workflows

## 1. One workspace, progressive detail

The normal farmer enters a responsive **Farm Desk** Site View hosted by Core. JCB and the Joomla administrator remain authoring/administration tools. The workspace uses task names, the selected farm and date, large touch targets and visible save state. Optional enterprise menus appear only when installed and permitted.

Primary navigation: **Today, Animals, Fields, Stock & Sales, Workshop, Bookings, Team & Equipment, Money, Reports**. Collapse unused areas. Show functional currency with explicit ISO code whenever another currency is present; N$/R/P symbols alone can be ambiguous.

First setup asks only what is needed now: legal entity/country, functional currency, timezone, farms, enabled enterprises, stores, bookkeeper role and opening-data source. Use a guided checklist for units/products and country approvals. Do not ask the farmer to choose a database connection, Power GUID or compiler option.

## 2. Today screen

| Section | Useful content | Action |
| --- | --- | --- |
| Needs attention | Water/fence incidents, withdrawal/permit expiry, overdue balances, low/held stock, unresolved sync or posting failures | Open the underlying record and its next permitted action |
| Today's work | Assigned tasks, staff availability, deliveries, maintenance, harvest and guest arrivals/departures | Mark progress or record the actual event |
| Farm snapshot | Herd/group counts, feed days where a valid consumption basis exists, available stock, bookings, cash due | Drill into dated source data; show missing inputs and freshness |
| Quick capture | Expense, purchase receipt, animal event, weight, harvest, sale, fuel, rainfall and task | Contextual form with selected farm and explicit unit/date |

Avoid a dashboard wall of decorative charts. Each card needs a user decision, an owner, a source query and a stale/empty state. Missing rainfall is displayed as “No reading”, not zero.

## 3. High-frequency screens

| Screen | Minimum form | Completion feedback |
| --- | --- | --- |
| Weigh animals | Scan/search tag, date, kg, scale/estimated; rapid next-animal capture | Saved animal/tag, weight and event time; undo becomes an auditable correction |
| Receive feed | Supplier/delivery ref, product, lot/expiry, bags and package size, store, cost evidence | Received base quantity and linked purchase status; warn on duplicate delivery ref |
| Record expense | Supplier/payee, date, amount/currency, category/enterprise, tax treatment if enabled, receipt | Draft/approved/posted clearly distinguished; no false “paid” from uploading receipt |
| Crop activity | Plot/cycle, task, input lot/qty/unit, worker and observation | Event and stock effect shown together; required restriction dates visible |
| Production batch | Recipe revision, planned output, actual inputs, yield, quality check, packaging | Lot numbers, costs and hold/release state; confirmation includes deviations |
| Farmer-market sale | Scan/search item, qty, price/discount within role limits, payment method | Receipt number, payment status and stock change; cash session remains visible |
| Reservation | Guest contact, stay dates, people, room/camp, hunt/extras, quote/deposit | Hold expiry or confirmed state; separate missing permit checklist |
| Work and maintenance | Asset/task, worker, time/reading, parts/fuel, completion findings | Next service due, cost source and unresolved defect |

Show common fields first and advanced fields only when relevant. Hide inactive controls accessibly; never leave a hidden field mandatory. Validate on both client and server. Keep typed content after a validation error, network failure or modal close. Reopening a saved record must display the actual persisted values.

## 4. Animal interface

Support barcode/QR or keyboard-wedge scanners where the physical tags allow it; manual search always works. Display tag aliases, species, sex, age precision, current group/location and prominent active restrictions. Timeline shows births, weights, treatments, movement and ownership changes.

Batch entry can target a reviewed set of animals or a counted group. Show exactly which identities/count are affected before confirmation. Never apply a herd treatment silently to animals that joined after the event date. Tag replacement is an identifier-history action, not a new animal.

Keep biological status separate from invoice/payment status. Selling an animal, invoicing it and physically dispatching it are visible connected steps. An owner sees why a movement is blocked and what evidence needs review.

## 5. Bookings and hunting interface

Use a physical-resource calendar: room/camp rows and local dates. Arrive on 10th, depart on 12th means two nights. Holds have an expiry countdown and owner; confirmed allocations have clear deposit and documentation status. Show time buffers for guides/vehicles separately.

A package form can include beds, meals, guide, vehicle, approved hunt allocation and extras, but should explain their availability and price separately. A room being available does not make a hunt lawful or a quota available. Keep documents collected, reviewed, valid and missing as separate statuses.

Cancellation preview shows released resources, retained fees, deposit treatment and proposed credit/refund before the action. Record no-shows and actual outcomes truthfully. A cancellation never erases a completed hunt or occupancy history.

## 6. Money without accounting overload

Farmer views use familiar terms: money owed to us, bills to pay, cash received, expenses, stock value and enterprise result. Accounting users can drill into account/journal/tax details. Distinguish profit, cash and unpaid invoices with labels and source explanations.

In operational/export mode, display “Prepared for accountant” and the export status; do not label estimates as a closed financial statement. Pending approvals and missing cost inputs are visible. An accountant can reproduce a number from its contributing source lines and allocation rules.

Print/PDF documents include company identity, document number/date, currency, customer details, line units, tax details where applicable, totals, terms and source version. The renderer uses snapshotted posted data. Draft watermark and issued version are unambiguous.

## 7. Low-connectivity behaviour

First make the live application reliable on low bandwidth and a farm LAN: modest JS/assets, paginated lists, bounded photos, cache static assets and show progress. Use a stable sticky action area on mobile and avoid full-screen refreshes that discard forms.

Later offline observation drafts have four visible states: saved on this device, awaiting upload, accepted by server, needs review. A local draft is never labelled as committed stock or a confirmed reservation. Show last successful sync and explicit per-item errors. Reconnect does not duplicate events.

Provide printed daily work sheets and controlled import where connectivity makes them more reliable. A paper entry has a provenance marker and reviewer; staff must not independently enter the same event twice without duplicate detection.

## 8. Roles and privacy

| Role | Default workspace | Restricted information |
| --- | --- | --- |
| Owner/manager | Exceptions, work, bookings, inventory and enterprise results | Security administration only when separately granted |
| Bookkeeper/accountant | Transactions, reconciliation, tax settings, close, exports | HR/guest identity details only when needed |
| Stock/market clerk | Receipts, issues, counts, sale and cash session | Payroll, full bank details, broad financial statements |
| Supervisor | Assigned farms/crews, livestock/crop activity, equipment | Unassigned farms, pay terms and guest documents |
| Worker | Assigned tasks, basic observations and own approved time view | Costs, salary records, customer database and administrative exports |
| Reservations clerk | Availability, quotations, guest tasks and deposit status | Farm payroll and unrelated bank data |
| Adviser/veterinary user | Time-limited selected records | Broad stock/finance/personnel access unless explicitly granted |

These are role templates, not hardcoded Joomla group IDs. Every role is tested through the real frontend, modal selectors, API and document download. The owner can approve exceptions; ordinary workers do not need Super User access.

## 9. Usability acceptance

Observe the farmer and at least one actual capture user performing the pilot scenarios with synthetic or authorised data. Record time, errors and requests for help. Proposed targets: a familiar single animal weight or rainfall reading in under 30 seconds, a simple cash expense in under 60 seconds, and an ordinary saved page response within the measured deployment target. These are goals to verify, not completed measurements.

Test keyboard navigation, focus after modal close, readable contrast, screen magnification, touch controls, labels, validation summaries and translated-string expansion. Use colour plus text/icons for warnings. An inaccessible control or lost draft is a functional defect.
