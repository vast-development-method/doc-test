# Farm operating scenarios and acceptance fixtures

Prepared **19 November 2026**. Companion: [Southern African requirements](SOUTHERN_AFRICA_REQUIREMENTS.md).

These scenarios are **proposed acceptance tests**, not test results. They deliberately span the seven components so that an implementation can prove a coherent working product. All people, farms, identifiers, quantities, prices, rates and permit records below are synthetic. No example is a livestock, food-processing, legal, payroll or accounting instruction for an actual farm.

The agent should first implement a small complete path, then extend it. A component with many CRUD screens but no completed cross-component scenario has not passed acceptance.

## 1. Common fixture and test conventions

### 1.1 Synthetic installation

| Fixture | Definition |
| --- | --- |
| Legal entity | `Example Mixed Farm CC`, synthetic Namibia entity, functional currency NAD |
| Farms/sites | `North Farm` with cattle/sheep, garden and workshop; `River Lodge` accommodation site |
| Enterprises | Cattle, Sheep, Garden, Workshop, Food, Lodge, Hunting, General Farm |
| Stock locations | Main Store, Medicine Store, Workshop, Food Store, Quarantine, Market Stall, In Transit |
| People | Owner, Supervisor, Stockperson, Garden Lead, Workshop Lead, Food Lead, Lodge Coordinator, Cashier, Bookkeeper and External Accountant |
| Currency fixtures | NAD, ZAR, BWP; scenario-only rates are explicitly approved test records |
| Tax fixture | `TEST-NO-TAX`: synthetic arithmetic mode, no assertion of exemption, zero rating or non-registration |
| Time zones | Site-local dates plus UTC instants; synthetic Namibia site uses `Africa/Windhoek` |
| Rule packs | `TEST-NA-1`, `TEST-ZA-1`, `TEST-BW-1`; all marked test-only and prohibited from production activation |
| Tracking | Every command has an operation UUID, actor, entity, source reference and captured/received timestamps |
| Evidence | Uploaded synthetic documents carry an obvious `TEST ONLY — NOT AN AUTHORISATION` marking |

Run country-isolation tests on separate South African and Botswana installations. Do not place three legal entities in one installation merely to satisfy these fixtures. A foreign customer on the Namibia installation is not a second legal entity.

### 1.2 Evidence to retain per scenario

Retain the scenario ID, build/version, JCB source/export version, installed component versions, environment, user role, input fixture, expected result, observed result, pass/fail and links to relevant screenshots/API responses. Include source record IDs and a reconciliation export where the scenario affects stock, money, animals or availability. Redact tokens, real identities and secrets.

Record a failure as a failure. A screenshot of a success message is insufficient if the underlying ledger, stock or capacity is wrong. Production deployment remains gated by the broader roadmap's operational, security and recovery checks.

### 1.3 Execution order

| Stage | Scenarios | Purpose |
| --- | --- | --- |
| Foundation | F01, F02, F03 | Identity, access, controlled imports and dependable purchase/stock records |
| Livestock and daily work | F04–F09 | Complete common farm workflows with counts, restrictions, tasks and expenses |
| Garden and production | F10–F14 | Harvest, manufacturing, market reconciliation and traceability |
| Stay and hunting | F15–F18 | Concurrent capacity, money, permission evidence and cancellation |
| Money and management | F19–F22 | Currency, labour, enterprise costs and month-end handoff |
| Reliability and rollout | F23–F27 | Interruptions, corrections, restore, country packs and farmer usability |

The pilot need not enable all optional enterprises. It must pass every scenario relevant to enabled workflows and all foundation/security/recovery scenarios. Later phases add full accounting, payroll and authority integrations without rewriting established operational identities.

## 2. Foundation and first useful work

### F01 — Set up a farm without exposing irrelevant modules

**Owners:** Core and all component entry points. **Actors:** Owner, implementation agent, Bookkeeper. **Priority:** Pilot blocker.

Given a fresh installation, the owner selects one legal entity, Namibia, NAD, two sites and the enterprises actually used. The owner records the farm name/number, directions and location without a street number. Staff are invited into specific roles. The owner initially enables cattle, sheep, workshop and lodging; crops and food remain disabled.

Expected outcomes:

1. One shared customer/supplier/person directory and one item/unit catalogue exist; components do not create divergent copies of the same party.
2. The owner sees only active work areas, with clear onboarding tasks for missing opening information.
3. A disabled component rejects new ordinary capture through direct URL/API routes. Authorised historical reads, corrections, recalls, reversals and closure of existing obligations remain available through their guarded owner commands; generic writes stay disabled.
4. Site country and functional currency remain separate fields. Changing a customer's currency does not change the farm's regulatory pack.
5. A rural address is accepted; a clear phone/contact record can be stored without forcing a national-ID number.
6. Newly activated crops later use the same farms, stock locations and people.

Counter-case: an attempt to change functional currency after posted records exist is refused with a controlled migration explanation. It is not treated as an ordinary display preference.

Evidence: onboarding record, roles matrix and one screen per active role. This tests REG-001 and REG-017.

### F02 — A supervisor can work without accessing private records

**Owners:** Core, Work, Stay and document delivery. **Actors:** Supervisor, Lodge Coordinator, Bookkeeper. **Priority:** Pilot blocker.

Create synthetic staff bank details, a private staff document, a guest identity attachment, a general water-pump manual and a supplier invoice. Give the Supervisor access to farm tasks and the pump manual, the Lodge Coordinator access to the guest document needed for that booking, and the Bookkeeper access to the supplier invoice.

Try ordinary navigation, direct record URLs, guessed IDs, exports, batch endpoints, API requests and attachment download URLs for each role. All unauthorised attempts must fail without leaking the file name, preview or data through a list/count. The server must enforce the restriction even if a client sends a different farm ID.

Expected: authorised work continues, unauthorised data is denied, access events are recorded without copying secrets into logs, and report totals do not disclose hidden payroll or guest details. Changing a staff role takes effect for new requests and invalidates any appropriate access cache.

Counter-case: a shared stockperson device is signed out, then another user signs in. The previous user's cached private attachments and draft identity fields are not visible. A public booking confirmation cannot access an internal guest document.

This tests REG-014, REG-019 and the security of all subsequent workflows.

### F03 — Buy feed, partially receive it and pay the actual supplier bill

**Owners:** Ledger, Core. **Actors:** Supervisor, Owner, Storekeeper, Bookkeeper. **Priority:** Pilot blocker.

Fixture: order **20 bags × 50 kg** of feed at **NAD 300 per bag**. The purchase order is NAD 6,000 in `TEST-NO-TAX` mode. A first delivery contains 15 bags, a later delivery contains 5 bags. Record supplier batch and expiry if applicable.

Steps:

1. Supervisor submits request; Owner approves according to the farm's threshold.
2. Purchase order is sent/recorded; a stock receipt accepts 15 bags = 750 kg.
3. A second receipt accepts 5 bags = 250 kg.
4. Bookkeeper records the supplier invoice and a NAD 6,000 payment after matching quantity/price; the bank reference is independent of the invoice number.

Expected: total received is exactly 20 bags/1,000 kg. A posted receipt is the only source of its stock increase. Retrying either receipt command returns the same result. Ordered, received, invoiced and paid quantities/amounts remain independently visible. The item retains a versioned 50 kg pack conversion; another feed item with 40 kg bags cannot reuse it accidentally.

Counter-cases: short delivery stays outstanding; an overdelivery requires approval; a different supplier lot becomes a separate batch; a stock-negative issue is blocked according to the policy; no second payment is created by a repeated network callback. If full GL is disabled, export the records without pretending a statutory journal was produced.

## 3. Livestock and daily farm operations

### F04 — Acquire cattle while keeping official identity and costs separate

**Owners:** Livestock and Ledger. **Actors:** Stockperson, Supervisor, Bookkeeper. **Priority:** Pilot blocker.

Create 12 purchased cattle with synthetic internal IDs and external tag strings, including an ID with leading zeroes. The agreed purchase cost is NAD 96,000 and transport cost NAD 2,400. Both costs are assigned to the Cattle enterprise; any per-animal allocation is explicitly recorded as an operational allocation.

Steps: create purchase/arrival plan, attach synthetic transfer/movement evidence, verify the animal list, record actual arrival, reconcile official and local identifiers, and link the bills. Import the same animal CSV twice.

Expected: 12 animals exist, all external identifiers retain their exact string form, the second import produces no duplicates, and operational acquisition costs total NAD 98,400. The selected accounting policy, when approved later, determines financial classification and valuation. No universal biological-asset accounting policy is implied by the register.

Counter-cases: duplicate official tag on a different animal is quarantined for review; unknown date of birth is recorded with its precision; two animals cannot share an active unique official identifier in the same scheme. A purchase invoice alone does not confirm animal arrival.

### F05 — Move cattle and resolve a short arrival

**Owners:** Livestock, Work, shared documents. **Actors:** Supervisor, transporter, receiving Stockperson. **Priority:** Pilot blocker where external movements are enabled.

Plan a movement of the 12 cattle from one establishment to another. Record origin/destination, purpose, transporter, planned time and synthetic authority document. The responsible person verifies document scope and current restrictions before authorising the internal dispatch action.

Dispatch 12 animals. The receiving count is 11. Expected: 11 become received, one remains in a visible in-transit/exception state, and the system does not create a phantom receipt. The exception links to the transporter record and follow-up task. When the missing animal is found and its actual arrival is recorded, the movement reconciles to 12.

Counter-cases:

- A permit with the wrong origin, expired date or insufficient animal quantity does not satisfy the checklist.
- A newly recorded applicable restriction stops a previously planned but undispatched movement pending review.
- A dispatched animal cannot be dispatched again in another movement.
- Changing an animal's displayed camp does not silently close an external movement.
- A receiver cannot approve a document outside their role.

Traceability evidence must identify both the real movement times and later administrative recording. This is not a substitute for reporting to the relevant government system; the authority reconciliation status remains visible.

### F06 — Replace an ear tag without replacing the animal

**Owner:** Livestock. **Actors:** Stockperson, authorised reviewer. **Priority:** Pilot blocker.

For one animal, retire a damaged tag and assign a replacement after recording the required official reference. Preserve the old tag's active period and the reason. Search by either old or new tag.

Expected: both searches resolve to the same animal, with the historical identifier clearly marked. Birth, weights, treatments, movements, purchase and any later sale remain attached. An import containing the old tag is matched according to date and scheme or sent for review, not blindly creating a second animal. Printing a new tag label cannot create official authority to replace it.

Counter-case: the replacement identifier is already active on another animal. The server rejects it; the user can save an exception record without completing an invalid reassignment.

### F07 — Split a sheep flock and reconcile its changing headcount

**Owner:** Livestock. **Actors:** Stockperson, Supervisor. **Priority:** Pilot blocker.

Begin with 120 sheep. Split into Flock A = 80 and Flock B = 40. Record 12 births and 2 deaths in A; buy 5 and sell 15 in B. Expected closing counts are A = 90, B = 30, whole farm = 120.

The control equation is `120 + 12 + 5 − 2 − 15 = 120`. An internal split does not change whole-farm numbers. Deaths carry date/reason/evidence and link to required official reporting status. A sale reduces the flock through a single authorised exit event, not again through an invoice.

Promote 10 sheep in Flock A to individual tracking. Expected: 10 individuals plus 80 remaining batch-only members still equal 90 in A. The UI must explain the tracking transition. If a whole flock is represented by individually tracked members, the system derives the count from membership rather than independently editable totals.

Counter-case: a late count correction in a closed period becomes an approved adjustment with the original observation retained. It must not fabricate deaths or overwrite a historic count.

### F08 — Record a treatment and block a conflicting dispatch

**Owners:** Livestock, Ledger, shared rule/evidence records. **Actors:** Stockperson, Supervisor, veterinarian/reviewer. **Priority:** Pilot blocker where treatments are used.

Use a synthetic treatment instruction and medicine lot. Its fixture restriction ends at an explicitly supplied test timestamp. The scenario does not define a real drug, dose or withdrawal period.

Record actual administration to three animals, medicine use, person administering, source instruction and required follow-up. Attempt to include one restricted animal in a sale/dispatch before the fixture restriction ends.

Expected: the affected dispatch is blocked with the relevant evidence/restriction, while unrelated animals remain eligible. The medicine lot decreases exactly once. Future eligibility is derived from verified restrictions and actual event time, not the planned treatment date. A bulk treatment can handle one animal not actually treated without marking it treated.

Counter-cases: expired medicine stock is unavailable under the configured policy; a later correction to treatment time recalculates dependent status and alerts affected plans; a user cannot remove a restriction by editing a display status. A stale offline screen cannot override a newer server-side hold.

### F09 — A pump failure becomes a repair, cost and follow-up

**Owners:** Work and Ledger. **Actors:** field worker, Supervisor, technician, Bookkeeper. **Priority:** Pilot useful path.

A worker records a trough/pump fault with location, time and optional compressed photo. Supervisor assigns a repair work order. The technician issues one spare part and records two labour hours; a supplier repair invoice may be attached separately. Link the affected asset and water point.

Expected: the task progresses reported → assessed → assigned → repaired → verified/closed. Part issue changes stock once; labour/cost allocation goes to the selected enterprise or shared infrastructure. The next preventive service task is calculated from the selected interval and last actual service, with meter-based and calendar-based triggers distinguished.

Meter fixture: reading 10,000 litres is followed by a replaced meter reading 25. The record must identify a reset/replacement and not report negative consumption. A missing daily reading is shown as missing. A water-right record is separate from evidence that a pump works.

Counter-case: the network is unavailable during the fault. The worker uses the agreed local/paper contact procedure; the ERP later records what happened. No emergency response depends on a successful sync.

## 4. Garden, production and market operations

### F10 — Harvest a garden crop into three useful destinations

**Owners:** Crops and Ledger. **Actors:** Garden Lead, Storekeeper. **Priority:** Required when crops enabled.

For one synthetic crop cycle, record a harvest of 120 kg from a named bed/plot. Assign the harvest lot `HARV-01`. Move 50 kg to fresh-sale stock, 50 kg to Food Store for later processing, and 20 kg to an explicitly recorded spoilage/disposal flow.

Expected: available harvested stock is 100 kg; the 20 kg loss remains in the crop yield report. Total harvested quantity is still 120 kg. Enterprise costs and grade/destination reports reconcile. The crop cycle can stay open for a second harvest. A linked applicable crop-application hold prevents release until reviewed.

Counter-cases: estimated weight is labelled; actual scale reading replaces the estimate through a revision, not a hidden overwrite; a crate quantity without a pack conversion cannot silently become kilograms. Transferring stock to Food Store does not yet consume it in production.

### F11 — Manufacture a wood product with remnants and actual labour

**Owners:** Make, Ledger, Work. **Actors:** Workshop Lead, workshop worker, Bookkeeper. **Priority:** Required for the friend's woodwork enterprise.

Fixture: an approved BOM for a small bench requires 6 pieces of a specified timber grade and dimensions, fasteners and finish. A job for two benches freezes that BOM version. The workshop actually issues 13 timber pieces, producing two benches and a usable remnant; the extra piece and remnant treatment follow a recorded variation.

Record material source/lots, operations, actual labour and outputs. Expected: inputs are consumed only by the production-posting service, output stock increases by two, usable remnant stock is separately identifiable, and waste is explicit. Planned cost and actual cost remain distinguishable. Changing the master BOM tomorrow does not change today's job history.

Counter-cases: a custom engraved name is preserved from order to work instruction; a rejected bench goes to rework/hold, not saleable stock; a partial completion can produce one bench while the other remains work in progress. Any harvested-wood evidence travels with the source record; no document is invented by the ERP.

### F12 — Produce a food batch with measurable yield and traceability

**Owners:** Make, Ledger, Crops. **Actors:** Food Lead, approved quality reviewer. **Priority:** Required when food manufacturing enabled.

This is an arithmetic/traceability fixture, **not a recipe or canning instruction**. The authorised test process issues 50 kg of harvest lot `HARV-01`, 25 kg of ingredient lot `ING-01` and 10 kg of another approved input. It records 80 kg finished food plus 5 kg process loss. Packaging consists of 160 containers with a nominal 500 g net fill, separately tracked from food mass.

Expected: input food mass is 85 kg and the recorded food output/loss reconciles to 85 kg. Container count is not added to food mass. The manufacturing batch links every input and packaging lot to output lot `FOOD-01`. The output is quarantined until required quality checks and release are recorded by an authorised reviewer.

Costs for this fixture are deliberately defined for the test: input costs total NAD 1,000; packaging NAD 320; approved direct labour NAD 280. Total assigned batch cost is NAD 1,600, or NAD 10 per released container if all 160 are released and the approved costing policy uses that allocation. The finished-product valuation pool starts empty with no other receipts for this assertion; existing stock would require a separately calculated blended moving average. No claim about statutory inventory valuation follows from this fixture.

Counter-cases: releasing only 150 containers requires explicit disposition of the remaining 10 and recalculation under the approved policy; a raw lot already on hold blocks issue; entering a production completion twice creates no duplicate output; a missing validated process record cannot be replaced by a tick-box asserting food safety.

### F13 — Reconcile a market stall in stock and cash

**Owners:** Ledger and Make. **Actors:** Cashier, Supervisor, Bookkeeper. **Priority:** Required when market sales enabled.

Transfer 100 released containers of `FOOD-01` to Market Stall. Sell 70 at NAD 25, give 5 as approved samples, record 2 damaged, and return 23 to Food Store. Expected stock equation: `100 = 70 + 5 + 2 + 23`. Sales are NAD 1,750 in the test tax mode.

Receive NAD 1,250 cash and NAD 500 by a recorded external electronic payment. An opening float of NAD 300 produces expected closing cash NAD 1,550 before any withdrawals. Count actual cash NAD 1,540 and record a NAD 10 variance for review. Do not reduce sales to hide the variance.

Expected: the stall closes only when stock and tender variances are documented. Cash deposit is a separate transfer, not another sale. Samples and damage have different reason codes and cost destinations. Returns preserve the original batch. Electronic payment remains pending reconciliation until confirmed by appropriate evidence.

Counter-cases: a refund links the original receipt and restores stock only if the goods are physically accepted as saleable; expired/held stock cannot return to available stock automatically; ZAR cash uses its own currency count and receipt records.

### F14 — Recall one ingredient lot and find affected recipients

**Owners:** Make, Ledger, Stay if food was used by the lodge. **Actors:** Food Lead, Owner, authorised customer-contact staff. **Priority:** Food-production release gate.

Mark ingredient lot `ING-01` for investigation/recall after `FOOD-01` was produced and some containers sold. The system traces upstream to the supplier and downstream to output lots, remaining stock locations, market receipts and any lodge kitchen transfer. It does not guess that only current on-hand stock is affected.

Expected: all affected available stock becomes unavailable; the recall report reconciles made, on hand, sold, sampled, damaged, transferred and returned quantities. Known business customers can be identified; anonymous market customers remain anonymous, with event/date/receipt ranges supporting the approved public-notice process. The ERP stores who performed communications and when; it does not automatically email customers without authorised action.

When F12 and F13 run exactly as written and no other movements occur, the expected reconciliation is **160 produced = 83 on hand + 70 sold + 5 sampled + 2 damaged**. The 83 on hand comprises 60 never sent to market plus 23 returned. This numerical check catches double-counted transfers and returns.

Counter-cases: reworked or blended products preserve genealogy; a recalled lot used in a second batch also finds that batch; an unrelated supplier lot remains available. Closing the recall requires disposition and approval, not simply deleting the hold.

## 5. Lodging and hunting

### F15 — Two people attempt to book the last accommodation unit

**Owner:** Stay. **Actors:** two Lodge Coordinators or one coordinator and a public booking channel. **Priority:** Release blocker before confirmed bookings.

There is one available unit for a two-night interval. Submit two independent confirmation attempts simultaneously. Expected: exactly one succeeds; the other receives a clear conflict and no payment/deposit allocation is falsely attached to a confirmed booking. The test must run concurrent requests, not sequential clicks alone.

A provisional hold has a configurable expiry. When it expires, availability returns only once. A delayed payment notification after expiry cannot confirm the unit without rechecking availability and the agreed refund/reallocation workflow.

Counter-cases: a maintenance block consumes availability; an existing group's unit allocation is counted; a date range crossing month/year end works; departure on the next guest's arrival date is handled using the site's half-open-night convention. A housekeeping task affects readiness without incorrectly adding an extra billed night.

### F16 — Combine lodging and a hunting enquiry without confusing clearance

**Owners:** Stay and Ledger. **Actors:** Lodge Coordinator, hunting manager, Bookkeeper. **Priority:** Required for hunting business.

Create a package enquiry for one hunting client and two accompanying guests. The package requests accommodation, guide time, vehicle time and a species allocation. Reserve each resource explicitly. Issue a quote and receive a deposit with a bank reference.

Expected: customer/payer/hunter/guests are separate roles, the accommodation can be commercially confirmed, and the hunting activity remains awaiting compliance review until the exact permit, property, client, guide and quota conditions are satisfied. A deposit does not mark the hunt cleared. Each line retains its tax/levy treatment once locally approved.

Counter-cases: guide qualification expires before the planned activity; permit covers another site/species; accommodation is available but the guide is not; one guest cancels while the hunting client remains. The package can be revised without deleting its original quote, deposit or resource history.

### F17 — Prevent two reservations consuming the final hunting allocation

**Owner:** Stay. **Actors:** hunting manager and two coordinators. **Priority:** Hunting release blocker.

Use a synthetic quota document with one remaining reservable allocation for a specified species/site/period. Submit two simultaneous reservations. Expected: one reserves it and the other fails without making remaining capacity negative. The allocation record distinguishes authorised quantity, reservations, actual utilisation and corrections.

Record an actual outcome under the synthetic permit's configured rules. Expected: actual utilisation is an explicit authorised event. Cancellation of a commercial invoice cannot return a consumed allocation. A wounded/lost/otherwise reportable outcome uses the authority-specific rule and evidence; the system must not assume that only a recovered trophy consumes quota.

Counter-cases: cancelling an unused reservation releases it only if the current policy permits; a revised authority quota is recorded as a new effective version with review of outstanding reservations; an invalid document never creates capacity.

### F18 — Close a stay, settle money and retain the document trail

**Owners:** Stay and Ledger. **Actors:** Lodge Coordinator, housekeeper, Bookkeeper. **Priority:** Stay pilot blocker.

Record actual arrival, occupancy, approved extras and departure. Produce the final invoice using the approved country pack, allocate the deposit, receive the balance, and reconcile the payment. Create housekeeping work and mark the unit ready only after verification.

Expected: occupancy statistics derive from actual stay/guest-night data, not simply invoice counts. A no-show, shortened stay or room move updates the appropriate operational records while preserving history. Tourism reporting and levy calculations are distinct from ordinary VAT and require the correct local category.

For a cancellation, retain the booking, reason, approved charges and refund decision. A refund is a separate payment event linked to the original tender and invoice/credit where applicable. A hunt's outstanding trophy/export paperwork can remain open after accommodation and payment are complete.

Counter-case: external payment reversal after check-out opens a receivable/reconciliation exception; it does not reopen the room or erase occupied nights.

## 6. Money, people and management

### F19 — Pay a BWP supplier from an NAD business

**Owner:** Ledger. **Actors:** Bookkeeper, approver. **Priority:** Three-currency release gate.

Synthetic rates, used solely for arithmetic: purchase invoice **BWP 1,000** at **1.35 NAD per BWP** gives functional amount **NAD 1,350**. Later settlement is **NAD 1,370**, with a separately recorded **NAD 20** bank fee. The fixture therefore identifies **NAD 20** settlement exchange difference plus **NAD 20** fee; total cash outflow is **NAD 1,390**.

Expected: the original BWP invoice is unchanged; the rate direction is visible; the operational export contains original and functional amounts, settlement, FX difference and fee separately. If full accounting is enabled, the accountant-approved posting rule handles these amounts. A daily rate-table refresh cannot rewrite the original invoice.

Counter-cases: the user enters the inverse rate by mistake and receives a direction-aware preview; a missing approved rate blocks posting, not saving a draft; refund/credit uses its own date/rate policy; a report never adds BWP 1,000 directly to NAD 1,350.

Repeat with a ZAR transaction under a synthetic approved NAD/ZAR parity rule, including a nonzero bank fee. Equal currency value must not erase the fee or the actual currency.

### F20 — Split a worker's day across enterprises without duplicating pay

**Owners:** Work and Ledger export. **Actors:** worker, Supervisor, payroll clerk. **Priority:** Staff pilot blocker.

A worker submits eight actual hours: three cattle, two garden and three workshop. Supervisor approves with one correction accompanied by a reason. A scenario-only internal cost rate of NAD 50 per hour produces NAD 150, NAD 100 and NAD 150 allocations, total NAD 400. This is a costing fixture, not a minimum-wage or payroll instruction.

Expected: total approved hours remain eight, the allocation totals reconcile and the payroll export references the approved source version. The worker sees their own time; workshop lead sees relevant hours but not private bank details or other workers' pay. A clock-in/out interval spanning midnight uses the actual site time zone and does not become two full shifts.

Counter-cases: overlapping time claims are flagged; leave and work are not both counted for the same period without an approved reason; a late correction after export creates an adjustment/version, not a silent replacement. Re-exporting the same run is idempotent and clearly labelled.

### F21 — Allocate a shared pump expense without hiding the basis

**Owners:** Work, Ledger. **Actors:** Owner, Bookkeeper. **Priority:** Management reporting gate.

A NAD 3,000 repair benefits cattle and garden. The owner approves a 60/40 allocation for this fixture, with the basis recorded. Expected allocations: Cattle NAD 1,800, Garden NAD 1,200; whole-farm expense remains NAD 3,000. The original supplier bill is posted once.

The enterprise report shows direct costs separately from allocated shared costs, with the allocation period and method. Changing next month's method does not rewrite the approved earlier period. A manager can see both unallocated and allocated views without counting both together.

Counter-case: no evidence exists for a meaningful allocation. Keep it in General Farm and show it as unallocated rather than inventing exact enterprise margins. An operational contribution report must disclose excluded depreciation, stock revaluation, finance cost or unpaid documents where those are not yet included.

### F22 — End the month with a reconciled accountant handoff

**Owners:** Ledger, Livestock, Crops, Make, Stay, Work. **Actors:** Bookkeeper, Owner, External Accountant. **Priority:** Pilot blocker.

Reconcile bank/cash, unpaid supplier/customer documents, inventory quantities, animal opening/closing numbers, production work in progress, deposits, booking balances and approved labour exports. Produce a bounded export with stable record IDs, original currencies, rates, tax-rule references, source documents and reversal/correction links.

Expected: exported totals match the application for the same filters and cut-off; draft and posted documents are distinguished; imports into the accountant's system cannot duplicate a prior export silently. Outstanding exceptions are listed. A locked operational period prevents ordinary backdating while allowing approved adjustments.

The accountant signs off the mappings and opening balances before full statutory books become authoritative. Until then the application clearly identifies the accountant's system as the authoritative statutory ledger and labels operational reports accordingly.

Counter-cases: an invoice is recorded after the cut-off for an earlier service date; a late animal event changes operational history; a bank transaction is duplicated in a file. Each gets a documented reconciliation treatment rather than an unexplained balancing entry.

## 7. Reliability, corrections and country activation

### F23 — An interrupted field submission does not duplicate an event

**Owners:** all command handlers and optional offline capture. **Actors:** Stockperson, field worker, server. **Priority:** Pilot blocker for request retry; later gate for offline mode.

Submit an animal birth, stock-use request or time entry. Simulate the server committing successfully while the response is lost. Retry the identical operation UUID. Expected: one result exists and the retry returns its reference. Reusing that UUID with a different payload is rejected and investigated, not treated as a new request.

For an optional offline queue, make a conflicting edit on the server before the queued change arrives. Expected: the sync result states conflict, shows enough relevant current information for an authorised review, and preserves the queued observation. It does not silently overwrite the server's current stock, animal location or booking state.

Counter-cases: device clock is wrong; token has expired; role was revoked; upload partially completed; attachments arrive after the record. Server authorisation and validation are reapplied. The user sees unsent, submitted, accepted, rejected or conflict states distinctly.

### F24 — Correct a posted production or sale through a controlled reversal

**Owners:** Ledger, Make, dependent domains. **Actors:** Bookkeeper, authorised reviewer. **Priority:** Release blocker.

Post a stock/production transaction, then discover a quantity error. Ordinary edit is refused. The authorised reversal references the original and creates compensating ledger effects, preserving the original evidence and reason. Where stock has already been consumed downstream, the system refuses a simplistic reversal and directs an approved adjustment/rework path that preserves genealogy.

Expected: stock quantity, cost, source state and event/outbox status remain consistent after either full success or rollback. A simulated failure between document update and stock posting cannot leave half the operation committed. The audit identifies who authorised the correction.

Counter-cases: concurrent correction, duplicate reversal, closed-period correction, refund after sale, and cancellation with part of an order already delivered. Each has a defined policy and a visible result. Do not permit deleting rows to make reports look right.

### F25 — Restore the farm and prove that permissions still hold

**Owners:** deployment/operations, all components. **Actors:** operator, Owner, Bookkeeper. **Priority:** Pilot go-live blocker.

Take a backup including the database, controlled attachments, required configuration and encryption/key recovery procedure. Restore into an isolated environment with outbound notifications/integrations disabled. Verify counts, ledger totals, animal histories, open bookings, pending commands, file availability and the roles tested in F02.

Expected: the restored system is consistent at its documented recovery point, does not send real messages or replay payments, and identifies any lost interval. Record measured recovery time and data-loss window; compare them with the farm's agreed objectives. A backup file that has never been restored is not sufficient evidence.

Counter-case: an attachment is missing or encrypted data cannot be decrypted. The restore fails acceptance and produces an actionable gap. It must not be described as successful because login works.

### F26 — Activate a second country without reusing the first country's rules

**Owners:** Core, Ledger, relevant domain components. **Actors:** implementer, local reviewer, pilot users. **Priority:** Country rollout gate.

Create separate synthetic South African and Botswana installations. Load their own legal entity, functional currency, country pack, local identification schemes, applicable subjurisdictions, document templates and time-zone settings. Reuse domain workflows and software, not Namibia's legal values.

Expected: a South African animal identifier is not validated as a NamLITS tag; a Botswana livestock permit reference is not labelled a Namibian permit; a Botswana accommodation business uses its applicable category; South African province-specific hunting requirements remain expressible. A currency change alone never selects these rules.

Rule-version test: approve a synthetic rate/rule effective next month; issue one transaction before and one after the change. Each retains the correct version. Deactivate an unapproved pack and prove that ordinary operational recordkeeping still works while gated statutory/clearance actions remain unavailable.

Source-conflict test: present the implementer with the old BURS VAT explainer and the newer 2026 Act identified in the companion source register. Acceptance requires recording the conflict and using reviewed effective legislation, not whichever search result appears first. This tests the maintenance process as well as the schema.

### F27 — The farmer completes a real-looking day on a phone

**Owners:** product/UI and all enabled components. **Actors:** actual pilot farmer and at least one staff member. **Priority:** Pilot acceptance.

Ask users to complete, without the developer driving: check today's work; find an animal by tag; record a count or weight; report a water fault; record a small expense with receipt; see a guest arrival; locate an unpaid invoice; and find tomorrow's tasks. Use synthetic data first, then approved pilot data.

Measure completion, errors, questions, network payload, interrupted-request recovery and which labels users misunderstand. Agree practical targets from the real devices and working environment rather than inventing universal response-time promises. The user must be able to recover from a mistake and recognise whether an entry was saved.

Expected: no SQL, internal GUID, compiler setting, technical component name or unexplained accounting abbreviation is required in the farmer's normal work. Advanced configuration stays with authorised administrators. Keyboard access and clear contrast work; touch controls do not depend on colour alone; key documents are readable when printed.

Fail acceptance if the farmer needs a developer to complete routine work, if the app hides unsaved data after a connection failure, or if a report cannot explain its totals. Feed the observed issues into the next JCB source change and repeat only the affected path plus its material dependencies.

## 8. Cross-component reconciliation checklist

| Business fact | Authoritative source | Derived views that must agree |
| --- | --- | --- |
| Animal exists and its status/location | Livestock events and identity history | Herd view, movement report, sale eligibility, enterprise counts |
| Stock is physically available | Ledger movements, holds and reservations | Store view, production availability, sales/dispatch, market reconciliation |
| Harvest origin and operations | Crops cycle/harvest records | Lot genealogy, crop yield, input use, enterprise costs |
| Production happened | Make order/completion with Ledger postings | Finished stock, material use, work in progress, quality/recall |
| Unit/guide/vehicle is reserved | Stay capacity allocations | Booking calendar, package availability, Work assignments |
| Customer has paid | Ledger payment and allocation records | Invoice balance, booking deposit/balance, cash/bank reconciliation |
| Worker time is approved | Work approved time version | Payroll export, enterprise labour allocation, worker self-view |
| A permit is usable for a defined action | Issued external evidence plus authorised scope review | Clearance checklist, movement/hunt workflow, expiry dashboard |
| A regulatory rule applied | Approved effective-dated pack version | Document snapshot, reporting, later audit/reversal |

An event notification or cached summary is not a second source of truth. If a downstream projection lags, it must show that condition and recover without duplicating the underlying business event. The architecture must specify exactly which operations commit atomically and which use a reliable outbox/retry workflow.

## 9. Definition of a successful pilot week

A successful pilot is a whole reconciled week of the farmer's enabled activities: opening records are approved, staff use the daily screens, transactions complete, physical counts and money reconcile, exceptions have owners, and the accountant can consume the export. At least one deliberate error, interrupted request and restore is demonstrated safely.

Optional modules are judged by complete operating cycles: a crop harvest reaches sale or production; a workshop job reaches delivery; a lodge booking reaches settlement and housekeeping; a hunting reservation retains separate clearance and outcomes. More menus, more generated tables or a successful compiler run do not replace those outcomes.

Acceptance remains owned by the farmer for usability, the relevant operator for operational correctness, the accountant/payroll reviewer for their regulated functions, and the implementing agent for reproducibility and technical evidence. The roadmap should retain each decision and outstanding condition for the next agent.

