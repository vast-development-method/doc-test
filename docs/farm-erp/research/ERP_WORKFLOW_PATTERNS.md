# Farm workflow contracts derived from the ERP research

Research date: **19 November 2026**. These are proposed farm-product requirements and acceptance fixtures. They have not been executed against a JCB implementation. The source comparison and its provenance limits are in [ERP_REFERENCE_COMPARISON.md](ERP_REFERENCE_COMPARISON.md).

## 1. How to use this document

Build a complete, small workflow through JCB, compile it, install it, perform it under the intended user role, and read back the durable records. A form that saves one table is only part of a workflow. Orders, movements, invoices, allocations, journals and external acknowledgments own different facts; the ERP references repeatedly demonstrate why one status badge cannot substitute for all of them. [W01] [W02] [W03]

The accounting effects below define the eventual **full-accounting acceptance contract**. The early operational pilot may use approved accountant exports instead. It must not display “posted to general ledger” when it only exported data, and it must not claim complete accounting before its separate release gate passes. Activating native accounting later requires an approved cutover date, reconciled opening balances and prevention of duplicate historical imports.

Each implemented command needs a short, concrete contract containing:

| Contract element | Required content |
|---|---|
| Actor and scope | Required Joomla permission, company context, permitted farm(s), access to every referenced record |
| Inputs | Stable source/child identifiers, expected record version, business date, quantities/units, monetary currency, request key |
| Preconditions | Valid state, capacity/balance availability, policy revision, complete reference data and required evidence |
| Authoritative calculations | Ordered server-side calculations, rounding points, rate direction, unit conversion and residual handling |
| Atomic changes | Source transition, movements, allocations, accounting effects where enabled, audit event and outbox intent |
| Result | Durable action identity, final record/version, linked movement/posting IDs and any remaining quantity or balance |
| Failure | What was rejected, whether anything committed, and the safe next action |
| Retry | Reuse of the same request key returns the committed result; changed payload with that key is rejected |
| Correction | Explicit reversal or amendment, its link to the original and its effect on subsequent records |
| Evidence | UI result plus independently queried records, balances and denied-case results |

### Transaction boundary

Within one Joomla installation and database, the initiating service owns one outer unit of work. Owner services participate on the same database connection and do not commit nested partial results. `com_farmledger` owns stock, valuation, trade and accounting effects. Livestock, crops, making, stays and work services own their domain state and call the ledger service where needed. If any required synchronous effect fails, the entire business command rolls back.

The outbox is for external or rebuildable after-commit work: an email, a notification, a document-delivery request or a reporting refresh. The stock deduction, booking claim, invoice allocation or journal may not be deferred to an eventually consistent queue merely to avoid a transaction. The references' failure and concurrency examples motivate this decision; their exact framework transaction behavior is not automatically available in Joomla. [W04] [W05] [W06]

## 2. Shared invariants

| ID | Invariant | Observable acceptance |
|---|---|---|
| INV-01 | Every record has one business owner and a stable identity; document children have their own identities. | Two lines with the same product remain distinguishable through partial receipt, production or invoice conversion. |
| INV-02 | A posted effect has one unique source-operation identity. | Simultaneous identical submissions produce one set of effects; an unacknowledged success is recoverable by request key. |
| INV-03 | Current stock equals opening stock plus signed posted movements for the exact company, farm/location, item, lot/serial and ownership dimensions. | Ledger recomputation matches the balance table after each normal, reversal and failure case. |
| INV-04 | Reserved stock is a claim against eligible available stock, not another quantity of physical stock. | Reserving ten reduces availability by ten without reducing on-hand. |
| INV-05 | A company-owned transfer conserves quantity and value across source, transit and destination. | Dispatch and receipt can be separate events, but goods do not disappear from company-wide stock while in transit. |
| INV-06 | Initial releases do not allow negative stock, consumption of another order's reserved stock, or unrestricted issue of quarantined/expired lots. | Competing issues cannot both spend the final available quantity. |
| INV-07 | Quantity conversion is dimensionally valid and its historical factor is retained. | A 25 kg bag can convert to kg; a live animal cannot convert to kg through a generic fixed factor. |
| INV-08 | Currency amount, base amount and exchange-rate snapshot remain distinguishable. | A later exchange-rate edit does not rewrite an issued invoice or settled payment. |
| INV-09 | Every posted journal balances in base currency, belongs to one company, uses valid accounts and has a unique source posting. | A balanced duplicate is rejected as well as an unbalanced entry. |
| INV-10 | Draft calculations are recomputed before transition guards are evaluated. | Editing a mapped return quantity cannot leave old totals that change credit allocation. |
| INV-11 | Payment allocation cannot exceed either the available payment/credit or the current invoice remainder. | Two simultaneous allocations against one remainder have a serializable outcome. |
| INV-12 | Posted movements and financial entries are corrected by linked compensating actions, not silent overwrite or deletion. | Original and correction remain inspectable and independently reconcile. |
| INV-13 | Recipe, price, tax, unit conversion and labour-rate snapshots explain historical actuals. | Editing a master affects future drafts according to policy, not posted history. |
| INV-14 | Availability uses a single interval convention for quotes, claims, actual occupancy and reports. | Checkout and another check-in on the same date do not consume the same overnight slot. |
| INV-15 | Authentication, role and farm scope apply to every interface. | Hiding a button cannot be the only protection; direct calls, exports and file access are also denied. |
| INV-16 | Unknown, zero and not applicable are distinct. | A zero-cost input does not get an invented fallback; an absent lab result is not interpreted as a passing test. |
| INV-17 | An internal success does not prove an external outcome. | Email submission, bank settlement and permit approval retain their own evidence and states. |
| INV-18 | Reports state population, currency, valuation basis and date boundary. | “Profit”, “cash”, “stock value”, “committed purchases” and “amount outstanding” cannot be substituted for one another. |
| INV-19 | Specialized animal, crop and legal eligibility decisions remain in their owning domains. | An available item balance alone cannot authorize an animal movement, treatment-sensitive sale or hunt. |

These are farm design decisions informed by source contracts for document ownership, inventory, currencies, accounting and qualification. They deliberately tighten some reference behaviors. [W01] [W02] [W04] [W07] [W08] [W09]

## 3. Procurement, receipt, stock use and payment

### FARM-FLOW-01 — Buy feed and use part of it

**Actors:** buyer, receiving/store worker, approver/bookkeeper and authorized payer. **Owners:** `com_farmledger`, with feed consumption attributed to `com_farmlivestock`.

**Records:** supplier, product, purchase order/line, receipt/line, supplier lot, warehouse, stock movement, supplier bill/line, payment/allocation, bank evidence, herd feeding event and enterprise dimension.

**Sequence:** request/approve purchase → order → receive actual quantity into a named lot → approve supplier bill matched to receipt → pay → issue actual feed against a herd feeding event. A purchase order is a commitment. A received supplier invoice is a payable. A feeding record only changes stock when its explicit material-use action posts. This separates the reference patterns for buying, receiving, bill recognition and use. [W01] [W02] [W07]

**Numerical fixture:** all amounts NAD; taxes disabled for this arithmetic fixture. Buy ten 25 kg bags at NAD 250 per bag. Receive all ten: **250 kg** at **NAD 10/kg**, inventory value **NAD 2,500**. Issue **40 kg** to the cattle enterprise: remaining **210 kg**, value **NAD 2,100**, cattle feed cost **NAD 400**. Pay the supplier **NAD 2,500**.

| Full-accounting event | Debit | Credit |
|---|---|---|
| Feed receipt | Feed inventory 2,500 | Received-not-billed clearing 2,500 |
| Matched supplier bill | Received-not-billed clearing 2,500 | Supplier payable 2,500 |
| Payment | Supplier payable 2,500 | Bank 2,500 |
| Feed consumption | Cattle feed expense or approved cost destination 400 | Feed inventory 400 |

**Acceptance and failure:** partial receipt of eight bags leaves two outstanding; no payable is created merely by editing the order status. Repeating the posted receipt command returns its original receipt. A second user attempting to consume 220 kg after the 40 kg issue is refused. A damaged bag can enter a quarantine location and must not count as available feed. Supplier price variance and freight have an explicit approved adjustment path rather than silently rewriting the receipt.

**Correction:** return unused feed against its original receipt/lot; reverse the corresponding payable through an appropriate supplier credit. A physical supplier return and a commercial credit may occur on different dates and must have separate identities. Do not restore consumed feed simply by cancelling a bill.

## 4. Livestock acquisition, movement, health and sale

### FARM-FLOW-02 — Buy five cattle and preserve their identity

**Actors:** livestock manager, store/transport recorder and bookkeeper. **Owners:** `com_farmlivestock` and `com_farmledger`.

**Records:** animal identity, tag/identifier history, source party/farm, species/breed, sex, date precision, ownership/custody, movement document/evidence, quarantine state, purchase line, commercial allocation, scale reading and inspection attachments.

**Numerical fixture:** buy five individually identified animals for **NAD 8,000 each**. The commercial purchase total is **NAD 40,000**. Their measured weights are **280, 295, 310, 300 and 315 kg**, total **1,500 kg**. The farm now has **five head**, not 1,500 interchangeable stock units. A weight observation does not create another animal or change the head count. Each animal has one identity even if its tag is replaced.

**Acquisition boundary:** create or match the five identities, custody/movement record and linked purchase allocations atomically when acquisition is finalized. Do not create the animal twice because the invoice and the physical movement arrived separately. Where external official identifiers are unavailable, record a farm identifier and the missing evidence state; never manufacture an official identifier.

**Policy boundary:** breeding stock, animals held for sale and biological-asset valuations need an approved accounting policy. The product records operational head count, actual purchase cost and measurement history independently. It must not automatically depreciate every cow like a tractor, or equate a predicted sale price with recognized accounting value. This is a specialist farm decision beyond the generic ERP inventory references.

**Acceptance:** a flock/group may be used where individual identity is impractical, but births, deaths, purchases, sales and group splits/merges conserve head count and preserve event provenance. Individual animals must not remain counted in a flock that has already been split into individual records. A farm transfer changes location/custody, not company-wide ownership or revenue. Missing movement authority keeps the controlled operation pending.

### FARM-FLOW-03 — Record treatment and enforce a sale hold

**Actors:** authorized livestock recorder/veterinary role and livestock manager. **Owners:** `com_farmlivestock` and `com_farmledger`.

**Records:** treatment event, actual animal/group membership at treatment time, product and medicine lot, quantity used, route/dose as professionally supplied, responsible person, evidence/instruction reference, withdrawal rule version, calculated hold end and correction reason. This is a recording/control workflow, not a medication recommendation.

**Synthetic acceptance fixture:** animal A receives a recorded treatment at **2027-01-10 10:00 local time**. The fixture's independently approved rule says sale-for-slaughter eligibility begins **2027-01-17 10:00 local time**. At 09:59 that day, release is refused; at 10:00 it may proceed if all other holds are clear. These dates test the boundary only; they assert no actual product's withdrawal period.

**Atomicity:** the finalized treatment and actual medicine consumption post together. Failure to consume a valid lot rolls back finalization. A saved draft can exist before treatment entry is finalized. Adding a treatment to a group uses an explicit membership snapshot, so later herd rearrangement does not rewrite who was treated.

**Acceptance:** missing expiry or withdrawal instruction is a review state, not zero days. Several active treatments use the latest applicable release time per purpose. Restrictions for meat, milk or movement are not collapsed into one generic checkbox. The sales screen may prepare a draft while a hold exists, but dispatch eligibility is checked again at the action boundary.

**Correction:** corrected treatment data produces an auditable amendment and recalculated eligibility; it never deletes the earlier event. If a sale already occurred, an alert and investigation are created, not a fabricated reversal of real-world transport. The reference lot/recall patterns support traceable stock, while treatment rules require local veterinary validation. [W10] [W11]

## 5. Crop and garden cycle through harvest

### FARM-FLOW-04 — Grow vegetables for the market and lodge

**Actors:** crop manager, field worker, harvest receiver and store worker. **Owners:** `com_farmcrops`, `com_farmwork` and `com_farmledger`.

**Records:** land/plot, crop variety, season/cycle, planting event, task template, actual field work, seed/chemical/fertilizer input lots, water meter observations, harvest lot, grading, labour and enterprise attribution. Crop plans and observations do not automatically create stock movements. This follows the dedicated crop reference's distinction between schedule, measured observation and economic transaction. [W12]

**Numerical fixture:** crop cycle C on plot P consumes **NAD 300 seed**, **NAD 200 fertilizer** and **NAD 600 approved labour**, total operational cost **NAD 1,100** before overhead. Harvest yields **100 kg**. Grade **80 kg** saleable and **20 kg** waste. The operational cost per saleable kg is **NAD 13.75**, provided all 1,100 is allocated to saleable yield under the fixture policy. This is a management-cost calculation; recognition of growing crops and harvest value in statutory books is separately approved.

**Physical handling:** harvest receives 100 kg to a grading/quality location. Grading transfers 80 kg to saleable stock and disposes/reclassifies 20 kg with reason. Alternatively a validated direct-harvest mode can receive only the 80 saleable kg and record the 20 loss separately, but the chosen mode must not book both paths. Record actual yield, not the expected template yield.

**Integration:** transfer 10 kg to the lodge kitchen with enterprise attribution, leaving 70 kg for sales. The internal transfer is not external revenue. A sale of 15 kg at NAD 30/kg has **NAD 450** net sales and leaves **55 kg** available market stock, subject to separate stock reservations/holds.

**Acceptance:** a changed crop template affects future cycles, not already completed tasks. Chemical use records exact plot, treated area, product lot, application date and approved restriction interval. Harvest checks eligibility again. Water usage units and reading intervals are explicit; a meter reset is a separate event rather than negative consumption. Field/laboratory observations preserve sample identity, collection/test/result times and units. Do not automatically prescribe chemical treatment from a measurement.

**Failure:** repeated synchronization of one field observation must not create two sample identities or two cost postings. A closed crop cycle can receive an authorized late cost adjustment without silently changing its historical crop area or harvest quantity. Data recorded for one farm must not populate another farm's crop report.

## 6. Woodworking production and sale

### FARM-FLOW-05 — Make a small batch of wooden products

**Actors:** workshop lead, store worker, craftsperson, salesperson and bookkeeper. **Owners:** `com_farmmake`, `com_farmwork`, `com_farmledger`.

**Records:** customer job, quote/order, approved recipe revision, material specifications, planned input lines, actual issues, output batch/serials, offcuts, labour, quality release, delivery and invoice. Preserve the plan-line identity even when two lines use the same timber product at different stages. [W13] [W14]

**Numerical fixture:** one batch produces **10 toy vehicles**. Actual timber costs **NAD 500**, bought-in parts **NAD 100**, and approved conversion labour **NAD 200**. Total cost **NAD 800**, with no valued by-products or extra overhead in this fixture. Receive ten finished units at **NAD 80** each. Sell six at **NAD 150** each: sales **NAD 900**, cost of goods **NAD 480**, gross margin **NAD 420**, remaining finished inventory **four units worth NAD 320**.

**Full-accounting boundary:** material transfer to workshop inventory is a location change. Consumption and finished receipt move cost through approved work-in-progress clearing; eligible conversion cost is capitalized once. Delivery recognizes the chosen inventory cost; invoice recognizes revenue/receivable; payment recognizes bank settlement. The accounting policy must prevent counting workshop labour both as an already recognized expense and a second expense inside cost of goods without the appropriate capitalization/clearing entry.

**Partial production:** posting four outputs after consuming only the materials used for those four leaves the work order open. The remaining six can be received later. If all material was consumed up front, its remaining attributable work-in-progress value persists until completion, approved loss or cancellation. The word “complete” cannot be inferred from one output row while input quantities remain unresolved.

**Physical specification:** timber uses an explicit stock unit and commercial unit; width, thickness, length, grade and species are product/lot specifications. A calculated cubic-metre estimate must not silently replace measured piece counts. Reusable offcuts have their own measured receipt and approved valuation; sawdust or waste is not assigned saleable value merely to balance a quantity equation.

**Acceptance:** duplicate command cannot receive a second batch; cyclic recipes are refused; replacing a recipe after issue requires a controlled revision/amendment; actual zero-cost material remains zero where legitimately recorded. Reversing output after six units have sold must fail unless the required physical return/credit/adjustment path first restores eligibility. [W13] [W14]

## 7. Food processing, yield and recall

### FARM-FLOW-06 — Produce a traceable jarred-food batch

**Actors:** production operator, quality releaser, store worker and market/lodge salesperson. **Owners:** `com_farmmake`, `com_farmledger`.

**Records:** recipe revision, process batch, actual ingredient lots, packaging lots, declared allergens, approved process instructions, measurement/check records, output lot, date markings, quality state, genealogy, waste and distribution records. A recipe is neither a food-safety approval nor proof that the product is safe.

**Numerical fixture:** consume **20 kg fruit costing NAD 400**, **10 kg sugar costing NAD 200**, packaging costing **NAD 120**, and eligible conversion cost **NAD 180**. Total assigned batch cost **NAD 900**. The process yields **27 kg** product in **54 jars of 500 g**; record **3 kg process mass loss**. Receive **54 jars at an aggregate value of NAD 900**. The per-jar display estimate is approximately **NAD 16.666667** before the configured unit-cost precision; the ledger retains exact aggregate value and allocates rounding residuals deterministically.

**Rounding acceptance:** this fixture starts with an empty moving-average valuation pool and has no other receipts. Issue 20 jars from that pool. Using value-proportional allocation rounded to two decimals, issue value is **NAD 333.33**, leaving **34 jars and NAD 566.67**. Issuing the final 34 clears the entire remaining **NAD 566.67**. Rounding each original jar to 16.67 and multiplying all 54 would invent 0.18 of value and must not be used as the stock-value algorithm.

**Yield control:** planned output and actual sellable output are separate. Process loss produces no fictitious finished inventory. If a by-product is recovered, classify and value it under an explicit policy; assign its cost share once, then allocate the residual pool to the main output. Percentage composition, output cost share and yield loss are different concepts. The production references provide these distinctions. [W14]

**Quality/recall:** output starts held until required checks pass. A later recall of fruit lot F identifies every production batch that consumed F, every output lot in those batches, stock still held, and known delivery/POS destinations. Where the data only proves batch membership, all its output is potentially affected. The system must not claim jar-level allocation from an input lot unless that finer relationship was actually recorded. [W10] [W11]

**Acceptance:** held/expired lots cannot be sold by a direct endpoint; changing label wording produces a new label revision; ingredient substitution requires approval and preserves the original plan and actual ingredient; returned jars enter hold rather than immediately becoming saleable. A recall notice is an external delivery with recorded attempts and acknowledgment status.

## 8. Farmers' market sales and cash control

### FARM-FLOW-07 — Sell stock during one market shift

**Actors:** market cashier, stock supervisor and reviewing owner. **Owners:** `com_farmledger`, with batch provenance from `com_farmmake`/`com_farmcrops`.

**Records:** market event/location, till shift, opening float, stock transfer, sale/lines, payment tenders, cash movements, refunds, closing count and difference approval. Do not make a separate ledger per enterprise. Use the same product and stock ownership.

**Numerical fixture:** opening cash **NAD 200**. Sales: **NAD 500 cash** and **NAD 300 electronic tender**, with a later cash refund of **NAD 50**. Expected cash before any cash removal is **NAD 650**. Actual cash count **NAD 640** leaves a **NAD 10 shortage**, requiring a separate reasoned adjustment. Electronic proceeds remain an electronic settlement/clearing balance until bank evidence arrives; they are not in the cash drawer.

**Stock:** transfer 40 jars into the market location, sell 20, return 19 unsold and record one damaged jar. Company stock reconciles with one damage issue; ending stock in the market location is zero. A sale return and cash refund may be related but must not automatically assume both occurred.

**Low-connectivity policy:** initial releases can retain locally captured **unsubmitted drafts** with clear pending status. They may not promise finalized inventory, official invoice numbering or confirmed electronic payment offline. A later offline-posting release needs device command identities, numbering policy, stale-price/tax handling, duplicate detection, competing-stock resolution, encrypted storage, logout cleanup and a proven recovery procedure. The generic POS source is an inspiration, not proof that those capabilities already work in JCB. [W15]

**Acceptance:** split tenders sum to the sale total; a receipt cannot be printed as finalized until posting succeeds; the same device request retried twice creates one sale; voided drafts consume no stock; refunds link to original lines/tenders; shift closure flags unsubmitted sales and unresolved electronic tenders.

## 9. Lodging reservations, deposits and folios

### FARM-FLOW-08 — Reserve two rooms for two nights

**Actors:** booking clerk, lodge manager, guest-facing operator and bookkeeper. **Owners:** `com_farmstay`, `com_farmledger`.

**Records:** payer party, guest(s), room/type, package/rate revision, booking/lines, per-night claim, expiring hold, deposit request/payment/allocation, check-in, folio charge, room block, housekeeping state and cancellation policy snapshot.

**Interval rule:** a stay is `[arrival date, departure date)`. Arrival on **2027-06-10**, departure on **2027-06-12** consumes the nights of 10 and 11 June. It is a two-night stay. Rate per room is **NAD 900** for the first night and **NAD 1,100** for the second. Two rooms cost **NAD 4,000** before any taxes/levies in this fixture. A guest arriving on 12 June can use the same room once its operational turnaround requirement is satisfied.

The ERPNext hospitality chapter exposes why tariff intervals and occupancy intervals must be made consistent and why package aliases must share capacity. This product deliberately uses one canonical night rule for all computations. [W16]

**Claims and concurrency:** a quote is not a claim. A live hold reserves physical room/night slots until its server expiry. Confirmation converts the same claims, rather than creating a second set. Different package names for the same room draw from the same slots. The full action locks/checks all affected room-night resources in stable order. A database uniqueness rule or equivalent atomic capacity guard prevents two confirmed claims for the same room/night. Public availability is advisory; confirmation rechecks it.

**Deposit fixture:** receive **NAD 1,000** against the booking. Under the fixture's approved accounting policy, it is a customer deposit liability, not automatically earned accommodation revenue. At the chosen invoicing/recognition point, a **NAD 4,000** accommodation invoice applies that 1,000, leaving **NAD 3,000** due. A lodge meal of **NAD 200** produces a separate folio charge and invoice allocation according to the configured invoicing policy. No nightly charge is created twice by a repeated checkout.

**State separation:** booking confirmation, room occupied, room clean, payment received and invoice settled are distinct facts. A company can pay for several guests. A maintenance block can prevent sale while leaving prior financial documents intact. A cancellation releases unconsumed claims and separately computes any fee/refund using the policy version accepted by the customer.

**Acceptance:** two clerks compete for the final room; exactly one claim succeeds. Repeated package rows cannot multiply capacity. A stale hold cannot confirm without reacquisition. Moving a confirmed stay acquires replacement slots and releases old slots in one transaction. Failed room acquisition preserves the existing booking. A cancellation after bank settlement records a refund liability/payment path, not a deletion of the deposit.

## 10. Hunting-service booking and resource coordination

### FARM-FLOW-09 — Add a guided hunt to a lodge stay

**Actors:** booking clerk, authorized hunt manager/guide and bookkeeper. **Owners:** `com_farmstay` owns the guide/vehicle reservation claims; `com_farmwork` can optionally expose equipment and qualification availability through a capability contract. Livestock/wildlife records remain with their own domain where applicable. An optional integration must not create a second capacity authority or a mandatory satellite-to-satellite installation dependency.

**Records:** service reservation, hunter/guest identity, agreed species/package, guide and vehicle intervals, land permission, permit/evidence references, quota allocation where applicable, conditions, equipment checklist, outcome, trophy/meat custody record, applicable charges and deposit allocation.

**Boundary:** a booking reserves service capacity. It does not grant a permit, prove legal eligibility, allocate a wild animal as if it were warehouse stock, or authorize harvesting. Regulatory approval, country/province rules, species and land status require their own dated evidence. This is original specialist farm scope; no cited generic ERP establishes the local rules.

**Numerical resource fixture:** one guide G and one vehicle V are available for **2027-06-11 06:00–12:00 local time**. Booking H1 claims both. Booking H2 for **09:00–13:00** fails on overlap even if lodge rooms are free. A non-overlapping booking starting at 12:00 is only available if the resource turnaround rule permits it. Availability for guide, vehicle, room and any quota all remain separate inputs.

**Commercial fixture:** a **NAD 2,000** guide-service charge is separate from accommodation and any legally authorized outcome-dependent charge. No automatic wildlife stock decrement or trophy invoice occurs merely because the reservation becomes confirmed. A cancelled excursion may release guide/vehicle claims while the guest still stays at the lodge.

**Acceptance:** required documents are checked for the actual date, person, species, location and authorized scope; attachments alone do not mark them approved. Quota, where used, has available, reserved and consumed quantities and an atomic claim. The actual event records the applicable outcome and professional confirmation. Any trophy/meat transfer retains chain of custody and evidence. The application must not infer completed harvest from a paid service invoice.

## 11. Staff, time, expenses and payroll handoff

### FARM-FLOW-10 — Allocate staff costs without claiming premature payroll compliance

**Actors:** employee/time recorder, supervisor, payroll reviewer and payer. **Owners:** `com_farmwork`, `com_farmledger`.

**Records:** employee, effective employment/role, work calendar, attendance, task time, leave request, approved rate snapshot, expense claim, period export, external payroll run/reference, payable and payment allocation. Employee personal data requires restricted access distinct from ordinary staff scheduling.

**Numerical operational fixture:** one employee records **6 hours cattle work** and **2 hours workshop work**. Approved costing rate is **NAD 50/hour**. Management costs are **NAD 300 cattle**, **NAD 100 workshop**, total **NAD 400**. This is an internal cost allocation, not proof that the employee's legally payable wage is 400. Overtime, leave, deductions, benefits and statutory contributions require the qualified payroll policy.

Historical time entries retain the applicable cost-rate snapshot. Changing tomorrow's rate must not change yesterday's already reviewed cost. Employee billing, internal costing and payroll entitlement remain different amounts, following the reference distinctions. [W17] [W18]

**Expense fixture:** approved reimbursement **NAD 230**; first payment **NAD 100** leaves **NAD 130**. A second request for 130.01 is refused. Approval, journal/export, actual payment and bank reconciliation are separate operations. A supervisor who approves an expense does not automatically acquire permission to edit the employee's bank details.

**Payroll release path:** export a closed, versioned period of attendance/time/leave and approved adjustments. Record export identity, hash, source records and the external payroll receipt/reference. Import the approved payable totals with duplicate prevention. Full native payroll is later and must be tested per country, effective year, employee category and rounding rule. Employer contributions remain separate from employee take-home; the ERPNext payroll contract explicitly distinguishes their accrual and payment. [W19]

**Acceptance:** overlapping incompatible attendance entries are flagged; one shift is not paid twice because it appears on two tasks; a self-approving user is handled by the chosen approval policy; ordinary staff cannot export salary/bank data. Re-export of the same approved period produces a version-identifiable artifact, not another payable. A correction creates an adjustment period or approved amendment with a clear external handoff.

## 12. Equipment maintenance, fuel and water

### FARM-FLOW-11 — Repair a borehole pump and record the cost

**Actors:** maintenance coordinator, technician, store worker and reviewer. **Owners:** `com_farmwork`, `com_farmledger`.

**Records:** equipment identity, location, meter/operating-hour reading, maintenance plan, work request/order, spare-part issue, actual labour, contractor invoice, result/checklist, downtime and next due date.

**Numerical fixture:** issue one replacement part costing **NAD 600**, record **2 hours at NAD 100/hour**, and approve a contractor service of **NAD 400**. Operational job cost is **NAD 1,200**. Closing the maintenance task alone must not make three additional copies of those costs. Recurrent maintenance creates one next occurrence keyed to the completed occurrence, even if the closing action is retried.

The Odoo maintenance/repair distinction is instructive: maintaining an equipment record and completing an internal maintenance card does not automatically establish stock consumption. This product makes the requested part issue explicit and attributable. [W20]

**Asset policy:** routine repair cost and capital improvement have different approved accounting treatment. The technician records the facts; only the authorized accounting path selects capitalization. Meter readings use a known unit and ordered observation identity. Replacement/reset is explicit, so a reset from 10,000 to zero does not become negative water use.

**Acceptance:** a vehicle cannot be simultaneously assigned to a blocking repair and a hunt under the applicable resource policy; due-hour and due-date triggers are independent; repeated scheduled execution creates one task; fuel issue records equipment, quantity, lot/location and actual reading rather than inferring litres from money spent.

## 13. Three-currency transactions and reconciliation

### FARM-FLOW-12 — Buy in BWP and settle later from a NAD account

**Actors:** buyer, authorized rate maintainer, bookkeeper and payer. **Owner:** `com_farmledger`.

**Supported transaction currencies:** NAD, ZAR and BWP. A company has one base currency. Bank accounts and documents have explicit currencies. A country, a tax regime and a currency are separate configuration choices. Rate-provider integration is optional; a permitted manual rate records its author, source and effective date.

**Synthetic exchange fixture:** the base currency is NAD. An invoice is **BWP 1,000**. Its approved rate is **1 BWP = 1.35 NAD**, so initial payable is **NAD 1,350**. Later settlement uses **1 BWP = 1.40 NAD**, with **no bank fee** in this fixture. Bank pays **NAD 1,400**; extinguish the **NAD 1,350** payable and recognize **NAD 50 exchange loss**. These rates are invented test inputs, not current market rates.

| Event | Debit | Credit |
|---|---|---|
| Supplier bill | Approved purchase/asset account 1,350 NAD | Payable 1,350 NAD, with BWP 1,000 source amount |
| Payment | Payable 1,350 NAD; exchange loss 50 NAD | NAD bank 1,400 |

The invoice's BWP amount, base carrying amount and historical rate stay unchanged. Settlement stores its own conversion. If a bank fee exists, it is a separate charge, not hidden inside an unexplained exchange rate. If paying from a BWP bank account, the bank's currency amount and its own base carrying value have a different reconciliation path and need another fixture.

**Acceptance:** missing or nonpositive foreign rate prevents posting; no silent default of 1. Reversing the invoice uses its original carrying basis. Partial settlement preserves both document-currency and base residuals with an explicit final-cent policy. A historical rate edit cannot change prior invoices. NAD/ZAR policy must be represented explicitly; a parity convention does not mean the currency identities can be merged. Currency contracts and company-currency reporting motivate these requirements. [W08] [W18] [W21]

## 14. Returns, cancellation, period close and cutover

### FARM-FLOW-13 — Return one sold item and credit the correct invoice

**Actors:** receiving/cashier, approver and bookkeeper. **Owner:** `com_farmledger`.

**Numerical fixture:** three items were sold at **NAD 100 net each**, tax disabled. Customer paid **NAD 200**, leaving **NAD 100** due. One item physically returns. A commercial credit of **NAD 100**, explicitly allocated to that original invoice, clears the remaining balance. If the credit is intentionally left unallocated, show **NAD 100 invoice due and NAD 100 unapplied credit** even though the net customer balance is zero.

Recompute the server's credit totals after any quantity edit, before allocation guards. The ERPNext recorded credit case demonstrates that correct aggregate ledger totals do not prove correct invoice settlement. [W03]

**Stock and money:** a physical return records the original delivered line, original lot/serial if known, returned quantity and condition. It enters the chosen inspection location. A credit can exist without physical return, and a return can await commercial credit. The action must distinguish those cases. A refund uses an available credit and a real payment event; it does not merely mark the invoice “cancelled”.

**Period controls:** a posted document in a closed accounting period cannot be edited. Corrections follow an authorized open-period reversal/adjustment with original business date and correction reason preserved. Closing requires stock/financial reconciliation, unresolved suspense review and completion of any permitted valuation-adjustment work. If the initial release does not support backdated valuation replay, it must refuse a stock date that would require it, rather than accept and leave incorrect later costs. [W07] [W09]

**Pilot-to-ledger cutover:** choose a reconciled cutover boundary. Import opening stock, open supplier/customer items, cash/bank and other approved balances through controlled opening commands. Record the prior accountant/export references and reject duplicate imports. Do not both repost historical invoices and import their aggregate outstanding balances. Prove the opening trial balance and reconcile stock valuation to its control account before enabling native accounting.

## 15. Standard failure and concurrency fixtures

These tests are required because the cited ERP evidence shows that successful UI messages, transaction wrappers and balanced journals do not by themselves establish correct results. They must use the actual target database and separate concurrent connections where stated. Browser-only sequential checks cannot substitute. [W04] [W05] [W06]

| ID | Controlled experiment | Only acceptable outcome |
|---|---|---|
| FAIL-01 | Submit the same receipt concurrently with identical request key/payload. | One committed receipt and effect set; both callers recover that result or one receives a retryable in-progress outcome. |
| FAIL-02 | Reuse a committed request key with a changed quantity. | Reject the conflict; original result unchanged. |
| FAIL-03 | Two different commands each issue 6 kg from the same 10 kg eligible balance. | At most one succeeds in full; rejected command leaves no movement, invoice or task-finalization residue. |
| FAIL-04 | Two commands allocate the last NAD 100 on an invoice. | Total allocation at most 100; each payment's unallocated remainder remains accurate. |
| FAIL-05 | Two clerks confirm the same final room/night. | Exactly one active claim; no orphan deposit allocation or second room claim. |
| FAIL-06 | Failure after inserting the source document but before its stock movement. | Entire required command rolls back. No finalized header without required movement. |
| FAIL-07 | Failure after stock mutation but before accounting/source state. | Entire required command rolls back. Independent read matches pre-attempt stock and journal counts. |
| FAIL-08 | Commit succeeds, response is lost, client retries. | Prior result returned without new business effects. |
| FAIL-09 | Outbox worker sends a message, loses acknowledgment and restarts. | Stable delivery identity; uncertain external outcome visible; no promise of impossible exactly-once email delivery. |
| FAIL-10 | A writer edits version 5 after another commits version 6. | Reject stale edit with current version; no silent overwriting of the other user's quantities or rates. |
| FAIL-11 | A farm-scoped user guesses another farm's document/download identifier. | Denial without confidential payload; audit according to policy. |
| FAIL-12 | Recompile/install generated code from preserved JCB records. | The same workflow still runs; no dependency on hand-edited generated output. |
| FAIL-13 | Restore a backup and replay only documented pending external jobs. | Stock and finance stay unchanged; duplicate durable jobs are suppressed or reconciled. |
| FAIL-14 | Restart during a bulk import after some bounded batches committed. | Resume from durable row keys/checkpoints; completed rows are not created twice. |
| FAIL-15 | Execute correction while another user is posting against the same original remainder. | Both operations serialize against the current state; aggregate returned/credited quantity cannot exceed eligible quantity. |

## 16. Reporting contracts

Every report needs an owner, a population filter, time boundary, unit/currency basis, correction treatment and drill-through identity. The references distinguish operational profit, posted profit, cash, stock and source-level outstanding items; the farm workspace should do the same in plain language. [W01] [W18]

| Report | Calculation/population contract | Misleading shortcut to prohibit |
|---|---|---|
| Farm enterprise result | Signed approved revenue and eligible costs in base currency, by farm/enterprise and chosen recognition period | Adding invoice amounts, stock purchases and internal transfers as if all are current profit effects |
| Cash position | Recorded cash/bank movements, reconciliation status and separate pending external settlement | Calling unpaid invoices “cash” |
| Stock on hand | Signed movement balance by product/location/lot/owner at cutoff, with hold and expiry states | Treating reserved or quarantined quantity as freely available |
| Inventory value | Approved valuation method and adjustment state at cutoff; base currency | Current selling price multiplied by historical quantity |
| Herd/flock reconciliation | Opening head + births + purchases + transfers in − deaths − sales − transfers out, respecting group splits | Counting animal master rows without lifecycle/custody state |
| Crop margin | Attributed actual inputs/labour/approved overhead and recognized harvest/sales under stated policy | Forecast yield × current market price presented as realized profit |
| Workshop job margin | Signed job revenue and consumed material/conversion cost, with work in progress separate | Counting the same material on purchase, production and sale three times |
| Lodge occupancy | Occupied/confirmed room-nights divided by sellable room-nights under a stated inclusion policy | Counting departure days inconsistently or including blocked rooms in the denominator without disclosure |
| Receivables/payables ageing | Original document residuals after explicit allocations as of cutoff | Netting an unrelated unapplied credit to hide an overdue invoice |
| Staff cost | Approved time-cost snapshot and allocation basis; distinguish actual payroll | Repricing historical time with today's rate |
| Water/fuel use | Valid sequential meter observations plus reset/replacement events, stated unit and period | Subtracting unrelated meters or interpreting missing readings as zero use |
| Compliance/evidence queue | Required evidence, expiry and approval state for the exact activity/date | Treating an uploaded file or a reminder as legal approval |

## 17. Required review artifact per workflow

For each completed build slice, preserve the JCB source/export revision, compiled extension checksum, install/version information, sample input, acting role/farm, record IDs returned, before/after movement and balance extracts, failure-case result, screenshot of the operator outcome, and the clean rebuild result. This is an implementation receipt, not merely a test checklist. The roadmap's JCB guide owns the exact tool procedure.

Completion means the authorized actor can perform the normal case, an unauthorized actor cannot, a retry does not duplicate effects, a correction preserves history, and the next component sees the correct committed result. A full ERP release also requires the independent accounting and regional qualification gates; completion of an operational pilot is valuable but does not satisfy those later gates.

## Pinned sources

[W01]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/trade/worked-cycle.md
[W02]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/transactions/receipt-to-cash.md
[W03]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/rebuild/live/README.md
[W04]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/concurrent-posting/README.md
[W05]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/rebuild/qualification.json
[W06]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/runtime/transactions-and-concurrency.md
[W07]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/inventory-and-valuation.md
[W08]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/international/currency-from-quotation-to-settlement.md
[W09]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/general-ledger/business-rules.md
[W10]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/production-control/lot-reconciliation.md
[W11]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/traceable-stock-and-service.md
[W12]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/agriculture.md
[W13]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/operations/manufacturing.md
[W14]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/manufacturing-and-subcontracting.md
[W15]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/point-of-sale/README.md
[W16]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/operations/hospitality.md
[W17]: https://github.com/vast-development-method/dolibarr-doc/blob/640ff739840dca25015a704300b2e78ee7269656/docs/operations/project-time.md
[W18]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/transactions/project-costing.md
[W19]: https://github.com/vast-development-method/erpnext-doc/blob/61a1196824f8df82127627d475599266244b71ce/docs/people-and-services/payroll-posting.md
[W20]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/repair-and-maintenance/accounting-effects.md
[W21]: https://github.com/vast-development-method/odoo-doc/blob/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0/docs/domains/multi-currency/README.md
