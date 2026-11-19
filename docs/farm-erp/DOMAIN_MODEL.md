# Domain model and data dictionary

## 1. How to author this model in JCB

This is a **logical application schema**. It is not a SQL migration, a JCB export, or a set of fabricated definition GUIDs. Author concrete Fields and one attached Admin View for each persisted table using the current native contracts, then inspect the compiled SQL. Child lines that need querying, permissions, reconciliation or independent lifecycle must be real entities, not opaque JSON subforms.

The [structured entity registry](contracts/domain-entities.json) lists the same owners and minimum fields. This document defines their meaning and cross-entity rules. Additional compiler-generated Joomla columns are permitted; their presence does not implement business invariants.

## 2. Common contracts

| Field / convention | Meaning and rule |
| --- | --- |
| `id` | Local Joomla numeric PK; not a public cross-installation identity |
| `guid` | Immutable unique application UUID; preserve through export/import |
| `organisation_guid` | Installation's one legal entity; explicitly scoped even where the current installation has one row |
| `farm_guid`, `enterprise_guid` | Required where activity belongs to a farm/enterprise; organisation-wide records have an explicit scope classification |
| `version` | Positive integer on mutable aggregates; compare-and-increment under the command transaction |
| `created_at`, `created_by`, `modified_at`, `modified_by` | UTC instants and Joomla actor identity; external import provenance retained separately |
| `occurred_on`, `occurred_at`, `posted_at` | Distinguish business date, real event instant where known, and posting instant; do not manufacture precision |
| `status` | Domain state with named transitions; not interchangeable with Joomla's published/trashed state |
| `source_type`, `source_guid`, `source_line_guid` | Whitelisted owner/type and stable originating records; enforce source resolution, never dynamic user-selected SQL tables |
| `reversal_of_guid` | Link to original immutable effect; reversing is a new effect, not deleting the original |
| `external_reference` | Provider, external type/ID, first/last seen, evidence and sync state; unique by provider/type/ID where appropriate |
| `currency_code` | NAD, ZAR or BWP; persist on monetary records even if equal to functional currency |
| `quantity`, `uom_guid`, `base_quantity` | Exact decimal plus measured/count unit and snapshotted conversion; count-based products reject fractions |
| `access` / `asset_id` | Joomla-generated access/asset metadata where the selected JCB model supports it; not a substitute for farm/record scope |

All GUID references are indexed. A relation is either enforced by a compatible generated FK or by owner validation plus an integrity audit; the implementing agent must prove the chosen JCB upgrade path. Use `RESTRICT` semantics for historical references. Cross-component uninstall must not cascade-delete them. Unique-key widths, collation, case normalisation and actual SQL types are part of the compiled-schema check.

Natural identifiers are explicit: animal tags are strings (preserve leading zeroes), product codes are scoped, room codes identify physical resources, document numbers are unique by organisation/kind/series. Changing a displayed code does not change its GUID.

## 3. Core masters and infrastructure

| Entity | Minimum domain fields / relations | Constraints and lifecycle |
| --- | --- | --- |
| `organisation` | legal/display name, registration and tax reference, country, functional currency, timezone, financial mode | Exactly one active legal entity; changing currency after postings requires migration |
| `farm` | organisation, name/code, country, location/address, timezone | Unique code; archive only after open activity is resolved |
| `location` | farm, parent, code, kind, coordinates, area and unit | Tree cannot cycle; kinds include paddock, field, yard, building and water point; warehouse/room details stay with their owners |
| `enterprise` | farm, code, name, type, active dates | Reporting dimension for cattle, sheep, vegetables, wood, food, hunts, stays and shared services |
| `party` | person/organisation discriminator, names, registration where relevant, preferred language, active flag | One identity may be supplier, customer and contractor; restricted identity fields separated from general selectors |
| `party_role` | party, role, validity dates | Unique overlapping active role; role does not grant a Joomla login |
| `party_contact` | party, kind, value, preference, purpose/consent state | Validate normalised contact without losing original display; private by scope |
| `party_address` | party, address kind, country, locality, postal/physical fields, validity | Physical event/delivery addresses differ from billing and postal address |
| `uom` | code, label, dimension, decimal scale | Dimensions such as count, mass, volume, length, area, time; no implicit cross-dimension conversion |
| `product` | SKU, name, kind, base unit, stock/lot/expiry flags, sale/purchase eligibility | Stock, service and non-stock distinguishable; activate only with complete stock/tax/account policy for enabled mode |
| `product_conversion` | product, from/to units, numerator/denominator or exact factor, effective dates | Unique active conversion; package sizes may differ by product; transaction snapshots survive edits |
| `vocabulary` / `vocabulary_item` | managed vocabulary kind; code/label, parent item, validity and external reference | Typed sets for species/breed, crop/variety, grades and task/incident types; child parent must be in the compatible set; archive referenced items rather than deleting them |
| `currency` | code, precision, enabled | Only initial three supported codes; display symbols are never the identity |
| `exchange_rate` | from/to codes, rate, rate date, source, approved_by | Positive; explicit direction; no rate inferred from symbol or country |
| `country_pack` | country, version, effective dates, evidence, approval/status, capabilities | Draft/approved/superseded; no activation of unapproved regulated capabilities |
| `file` / `file_type` | Reused JCB managed-file feature plus entity/target, MIME, size, hash, storage reference, access policy | Retain reference table conventions or adapt the complete feature graph; sensitive originals private and immutable where evidentiary |
| `document_link` | managed file, owner type/GUID, purpose, effective/expiry dates | Many records can reference one protected file; owner authorisation enforced at download |
| `user_scope` | Joomla user, farm, enterprise restriction, delegated validity | Role action permission and scope are both required; revoked access applies server-side immediately |
| `external_reference` | provider, type, external ID, owner record, observed version | Reconcile rather than duplicate; never claim a government integration exists without a supported contract |
| `number_series` | document kind, series, period, next sequence, allocation policy | Lock on allocation; numbers not reused after issued/cancelled documents; auditable gaps |
| `command_receipt` | command type, request key, canonical payload hash, result, correlation ID, actor | Unique command key; transactionally durable with effects |
| `audit_event` | actor, command, owner reference, time, outcome, reason, approved diff | Append-only; redact secrets and sensitive values; actor deletion preserves historical pseudonymous identity |
| `outbox_message` | event ID/type/version, payload, committed time, attempt/lease state | Same transaction as source; unique event ID; no pre-commit external delivery |
| `import_batch` / `import_row` | file hash, source, mapping version, dry-run results, row key, status | Staging separate from live posting; row-level error export and deduplicated rerun |
| `approval` | action/owner, requested/decided actor and time, scope, evidence/reason | Required threshold cannot be bypassed by editing document status; no self-approval where separation is configured |

## 4. Ledger, trade and stock

| Entity | Minimum domain fields / relations | Constraints and lifecycle |
| --- | --- | --- |
| `warehouse` / `bin` | farm, location, code, type; bin parent warehouse | Include owned transit/quarantine where needed; unique scope codes |
| `lot` | product, supplier/manufacturing source, lot code, production/expiry dates, quality state | Lot identifies traceability, not quantity; quantities come from entries; expiry unknown stays unknown |
| `stock_hold` | lot/product/location scope, reason/source, whole-lot or identified quantity scope, effective interval, active/released status, release actor/evidence | Independent quality/recall/legal/other holds; every applicable active hold enforced; releasing one never clears another; overlapping holds/reservations do not subtract the same unavailable units twice |
| `stock_transaction` | kind, farm, business date, source, status, posting/reversal | Draft → posted; posted effects immutable; approved corrections are new transactions |
| `stock_entry` | transaction, line GUID, product, lot, warehouse/bin, signed quantity, unit/conversion | Immutable; ownership and scope match; balanced transfer pairs in one transaction |
| `stock_balance` | canonical non-null balance_key, product/lot/warehouse/bin/ownership dimensions, on_hand, reserved, version | Unique balance_key; canonical absent lot/bin marker cannot be a valid GUID; do not rely on nullable composite uniqueness; locked on changes and reconciled to entries |
| `stock_reservation` | demand source/line, product/lot/location, quantity, expiry, state | Availability subtracts active reservations exactly once; conversion to dispatch atomic |
| `valuation_entry` | stock source line, valuation pool, quantity, unit cost, value, functional currency | Immutable cost effects; chronological posting sequence; no historical silent average rewrites |
| `trade_document` | explicit kind, party, addresses snapshot, currency/rate, dates, series/number, status, totals, references | Kinds quote, sales_order, purchase_order, sales_invoice, purchase_bill, customer_credit, supplier_credit; per-kind transitions and controls |
| `trade_line` | parent, source-line link, product/description snapshot, qty/unit, price, discount, tax/account mapping, farm/enterprise | Real child Admin View; preserve ordered/received/invoiced relationships; never replace posted children via generic subform |
| `tax_detail` | trade line, approved rule/version, rate/base, inclusive flag, amount, jurisdiction | Exact tax snapshot; multi-tax combinations explicitly ordered or rejected |
| `payment` | party, method, date, currency/rate, amount, bank/cash source, status, external reference | Receipt/refund disjoint types; duplicate bank/provider references reviewed |
| `payment_allocation` | exactly one payment_guid or source_credit_guid, target trade_document_guid, allocated transaction and functional amounts, FX difference | Same party and compatible receivable/payable direction; allocation cannot exceed source availability or target outstanding; applying a credit creates no invented cash movement |
| `account` / `period` | account code/type/control status; fiscal dates/open state | Posting only to leaf active accounts; period lock enforced under transaction |
| `journal` / `journal_line` | source, date, currency context, status; account/debit/credit/dimensions/counterparty | Balanced functional debits/credits; append-only after post; unique source effects |
| `bank_account` / `bank_statement_line` | own account identity/currency; import batch, bank row reference, amount/date | Restrict full bank details; immutable imported evidence, no duplicates on rerun |
| `reconciliation` / `reconciliation_match` | statement period/status; statement line and ledger payment split | No double matching; explicit bank charges/FX/partial matches |
| `cash_session` / `cash_count` | market/till/user/date/opening/closing; denominations/method totals | Cash due, cash counted and variance separate; approved variance journal |
| `budget` / `budget_line` | year/version/approval; enterprise/account/month and amount | Approved revisions retained; actuals from ledger, not editable dashboard values |
| `financial_asset` / `depreciation_entry` | operations asset reference, basis, policy, useful life/residual; dated depreciation | Accountant-approved policy; impairment/disposal separate commands; prevent duplicate depreciation periods |

Stock receipts and dispatches are stock transactions with line links to purchasing/sales documents. Do not create a second inventory table called goods receipt. The workflow retains supplier delivery references and proof; invoices do not automatically prove goods moved.

## 5. Livestock and wildlife distinctions

| Entity | Minimum fields / relations | Required controls |
| --- | --- | --- |
| `animal` | species/breed/sex, birth/date precision, dam/sire, owner, acquisition, farm/status, optional ledger_lot_guid | Individual identity survives tag replacement; no negative age or impossible parent cycle; an inventory-tracked individual has its own unique quantity-one Ledger lot |
| `animal_identifier` | animal, scheme, tag/brand/chip, issue/end dates, evidence | Enforce scheme uniqueness where valid; record tag history and external system IDs |
| `animal_group` | farm, species, purpose, managed-count mode | Group is a management/stock policy, not a second count of its individual members |
| `group_membership` | individual animal, group, from/to | No overlapping membership in mutually exclusive groups |
| `animal_event` | individual or group target, type, effective date, evidence, actor | Append-only confirmed events; amendments link originals |
| `group_count_event` | group, signed count, reason/source, valuation association | Only for unindividualised counts; reconcile births/purchases/transfers/deaths/sales |
| `weight_observation` | target, date, kg, equipment, sample size | Positive values; sample mean distinct from individual weight |
| `breeding_record` | dam/group, sire/service, service date, expected/actual result | Offspring registration not duplicated by recording outcome twice |
| `treatment` / `treatment_target` | product/lot, authorised instruction reference, actual date/dose/unit, derived restriction summary; affected animals/groups | Link consumed medicine stock; snapshot applicable rules and affected identities; per-output restrictions reside in animal_restriction; no automatic treatment advice |
| `animal_restriction` | treatment/other source, snapshotted individual/group targets, inherited_from_guid, output/action scope, effective_from/until, status, review/release evidence | Separate meat/milk/breeding/movement or configured scope; enforce union of overlapping intervals; restriction ancestry survives split/transfer/individualisation; expiry/release evaluated per scope |
| `livestock_movement` / `movement_line` | origin/destination, managed purpose_guid, carrier, permit evidence, requested/dispatched/received dates; targets/counts | Purpose must match reviewed sale/permit evidence and is frozen at dispatch; sale is not physical dispatch; apply relevant output/action restrictions without a caller-selected bypass |
| `livestock_cost_link` | operational source, animal/group/enterprise, allocation rule | Cost allocation never creates a duplicate expense; ownership belongs to Ledger |
| `wildlife_observation` | farm/species, date, survey method, count estimate/range | Observation is not domestic stock, approved quota, or guaranteed hunting availability |

An inventory-tracked individual cow links to one dedicated quantity-one Ledger lot; the optional `ledger_lot_guid` is unique, and that lot cannot represent another animal or a counted flock. The animal register supplies biology/identity and Ledger supplies stock quantity/value, with a reconciliation between them. Operational-only animals need no invented stock-unit table. A birth/event does not automatically recognise statutory biological-asset fair value. Livestock financial treatment is an accountant-approved policy. Domestic herd counts and wildlife estimates are kept distinct; hunting quota is owned by Stay.

For an unindividualised treated group, every split, transfer, merger or conversion to individual identities propagates applicable restrictions to the affected descendants in the same transaction, linking `inherited_from_guid` to their source restriction. If unaffected animals cannot be identified reliably, apply the conservative restriction to the entire potentially affected descendant group until an authorised documented resolution. Changing a group GUID or tag never clears eligibility rules. Ledger rechecks owner-provided eligibility for inventory-linked animals and their affected outputs on every relevant issue, transfer, adjustment, sale/delivery or production path; a missing required Livestock capability fails closed.

## 6. Crops and gardening

| Entity | Minimum fields / relations | Required controls |
| --- | --- | --- |
| `plot` | farm/location, area/unit, soil/irrigation context | Support beds and orchards; overlapping geometry does not automatically create more land |
| `crop_cycle` | plot(s), crop/variety/product, start/expected harvest/end, enterprise, status | Multiple plantings require explicit area allocation; perennials use season/cycle under orchard identity |
| `crop_cycle_plot` | cycle, plot, allocated area/unit, from/to dates, exclusive/intercropping policy reference | Real association entity; exclusive allocations cannot overlap beyond plot capacity; intercropping requires an explicit reviewed area/cost allocation method |
| `crop_activity` | cycle, type, date, worker/task, area, notes | Plant, weed, inspect, prune, irrigate and terminate as explicit event types |
| `input_application` | activity, input product/lot, qty/unit, area, operator, instruction/evidence, re-entry/harvest restriction | Ledger consumption and activity atomic; hold harvest when applicable approved restrictions are active |
| `field_observation` | cycle/plot, kind, observation time, value/unit or structured result, provenance | Weather, soil and pest observations distinguish measured, estimated and imported values |
| `irrigation_event` | plot/cycle, water point/meter, start/end, quantity/unit | Meter observation is not automatically water entitlement or chemical application |
| `harvest` / `harvest_line` | cycle/date/status; product/grade/quantity/unit, destination lot/store, loss | Ledger output and harvest completion atomic; reject double completion; retain grade splits and waste |

## 7. Woodwork, food and production

| Entity | Minimum fields / relations | Required controls |
| --- | --- | --- |
| `bom` / `bom_revision` / `bom_line` | output product; revision/validity/approval/base yield; materials/packaging/qty/unit, permitted substitutions | Production locks the approved revision; revisions immutable once used |
| `work_centre` | farm/location, capacity unit, costing policy | Capacity/calendars can be simple initially; no invented machine telemetry |
| `production_order` | output, target qty, revision, source order, dates, enterprise, state | Draft → released → in_progress → quality_hold/completed; cancellation follows material state |
| `production_operation` | order, sequence, worker/work centre, duration, completion | Labour observations feed cost allocation; no double charge from payroll and operation entry |
| `material_use` | order, input product/lot, actual qty/unit, stock source | Immutable after completion; actual use can differ from BOM with approval |
| `production_output` | order, main/byproduct/scrap discriminator, product/lot, qty/unit, cost share | Outputs conserve chosen cost-allocation policy; no negative recipe yield |
| `quality_check` | order/lot, test/specification revision, result, actor, hold/release decision | Failed checks restrict sale/consumption according to product rules; no fake lab certification |
| `quality_specification` | product/process, version, approved criteria, method, effective dates, approver | Immutable revision after use; checks reference the exact approved revision; approval does not substitute for required external certification |
| `genealogy_link` | input lot, output lot, producing event, consumed/contributed quantity | Directed trace without cycles; trace upstream and downstream across rework |
| `recall` / `recall_target` | trigger lot/reason/state; affected lots/deliveries/parties, notification/outcome | Freeze affected stock; identify customers and remaining balances; release only by authorised action |

Timber dimensions/grade/moisture are lot/product attributes; linear metres, cubic metres and item counts require real product conversion rules. A recovered offcut is an output only when its identity/unit/value policy is defined. Food packaging and allergens are controlled recipe/product attributes; expiry and label data are snapshotted on a batch, not retroactively changed by recipe edits.

## 8. Lodging, hunting and capacity

| Entity | Minimum fields / relations | Required controls |
| --- | --- | --- |
| `resource` | farm/location, physical type, code, capacity, active dates | Room/campsite, guide, vehicle or facility; products/packages reference resources, never duplicate capacity |
| `rate_plan` / `rate_rule` | offer/currency, validity, persons/nights, charge basis, tax treatment reference | Version/snapshot accepted quotation; no recalculation of a confirmed price from today's settings |
| `reservation` / `reservation_item` | party/contact, arrival/departure local dates, state, quote/deposit refs; resource/service allocation | Enquiry → hold → confirmed → checked_in/completed; expiry/no-show/cancel states explicit |
| `resource_claim` | resource, local night or discrete slot, reservation, quantity, hold expiry/status | Lock existing physical resource row then inspect overlapping claims; half-open intervals; expiry releases once; no assumed SQL partial/exclusion index or unmodelled capacity table |
| `guest` | reservation, party or minimal visitor data, required document references | Collect identity details only for a documented need; staff sees minimum necessary |
| `hunt` | reservation/farm, guide/resource, dates, participants, approval state | A confirmed bed does not prove hunting eligibility |
| `quota` / `quota_allocation` | species/farm/season, official approval ref, ceiling; hunt/count/state | Authoritative approved ceiling; locks prevent over-allocation; expired approval cannot confirm |
| `permit_check` | jurisdiction/type, subject, reference, validity, evidence, reviewer/status | Separate guest/guide/operator/firearm/species/trophy requirements; human review explicitly recorded |
| `hunt_outcome` | hunt/species, actual outcome/date, authorised count, evidence | Outcomes consume approved allocation; cancellation does not erase an actual outcome |
| `trophy_record` | outcome, identifier, preparer/dispatch details, external permit refs | Chain of custody; permits not issued by ERP; no unsupported export approval |

Use interval `[arrival_date, departure_date)` for room nights: departure day can be another guest's arrival. Timed guide/vehicle slots use `[start, end)` plus explicit preparation buffers. A group package may claim several resource types; all claims commit or none do.

## 9. Work, staff and infrastructure

| Entity | Minimum fields / relations | Required controls |
| --- | --- | --- |
| `worker` / `engagement` | party, optional Joomla user, restricted personnel data; employment/contract dates, approved terms reference | No login required for every worker; private HR data absent from ordinary task lists |
| `skill_record` | worker, capability/certificate, issuer, validity, evidence | Expired qualification blocks designated assignments where configured |
| `task` / `task_assignment` | farm/enterprise/location/source, due/priority/state; workers/crew/quantity | Plain-language work queue; task completion is not automatic stock or pay approval |
| `crew` / `crew_member` | farm, name, supervisor; crew/worker, from/to dates | Managed crew membership; task captures assigned individuals or a dated membership snapshot; later membership changes do not rewrite history |
| `time_entry` / `attendance` | worker/date/task, duration or start/end, approver | Detect overlaps, overnight shifts and corrections; approved payroll export revision retained |
| `leave_request` | worker, local dates/type, approval, balance reference | Country policy configurable; do not infer statutory accruals without approved pack |
| `payroll_export` | period, approved rows/hash, format/version, destination/ref, status | Exported amounts trace to approved inputs; rerun deduplicates; no false statutory calculation claim |
| `operating_asset` | asset code/product/serial, location, custodian, acquisition/ledger ref, meter unit | Physical life and financial depreciation distinct; lifecycle active/service/out_of_use/disposed |
| `maintenance_plan` / `maintenance_job` | asset, date/meter triggers; job/cost/task/outcome/next due | Meter rollover/replacement explicit; parts issue through Ledger |
| `meter_reading` | asset/water point, timestamp, reading/unit, reason | Detect resets/decreases; manual exception requires evidence |
| `fuel_issue` | asset/task, product/lot/qty, meter/operator, stock source | One Ledger issue; observations cannot create a second fuel reduction |
| `water_point` / `water_observation` | location/type/capacity/unit; level/flow/quality/reading source | Track boreholes/tanks/troughs; no claim to automate regulatory abstraction rights |
| `rain_observation` | farm/station/date, rainfall mm, instrument/source | No rain differs from missing measurement |
| `inspection` / `incident` | farm/location/asset, type/date, findings/severity/actions/evidence | Fence, fire, theft, injury and environmental events; restricted medical/HR details |

## 10. Derived records and integrity checks

Daily cards, herd totals, availability summaries, costing totals and stock balances are projections. Define their source and rebuild process. Stock balances also coordinate concurrent writes: quiesce writers for rebuild or prove a versioned snapshot/delta cutover; never replace live balances underneath posting commands. Do not permit manual edits to a dashboard total. Integrity reports must detect orphan GUIDs, duplicate external identities, invalid scope, unsupported unit conversions, inconsistent head counts, journal imbalance, stock-to-valuation mismatch, overlapping active capacity claims and stale projections.

Relations between optional satellites (for example financial assets referencing operational assets, or crop tasks referencing workers) are optional typed references with capability checks. They do not add an installation dependency or permit cross-owner writes. Ledger can retain a financial asset without Work installed; a missing optional integration must not invalidate historical evidence.

Retention differs by record class and country; configure it with the approved pack. Archived masters remain resolvable. Deletion of test data is separate from deletion of live business records. Runtime soft deletion, Joomla trash and reversible business cancellation are three different operations.
