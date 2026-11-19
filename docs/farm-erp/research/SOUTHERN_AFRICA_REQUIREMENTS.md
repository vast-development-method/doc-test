# Southern African farm ERP: regional and operating requirements

Research snapshot: **19 November 2026**. Target markets: **Namibia, South Africa and Botswana**. Initial currencies: **NAD, ZAR and BWP**. This is a researched product specification, not an assertion that statutory functions have been implemented, certified or approved.

## 1. Product boundary and evidence conventions

The proposed product serves a diversified owner-operated farm: livestock, crops and gardens, woodwork and small production, paid hunting and lodging, staff, equipment, water, purchasing and sales. It must also work for a farm that uses only two of those activities. A farmer should not need to learn a separate accounting vocabulary for each enterprise.

The architecture used in this document has seven components:

| Component | Ownership relevant to this document |
| --- | --- |
| Core | Legal entity, farms, enterprises, people/organisations, units, currencies, country packs, documents and shared permissions |
| Ledger | Stock, purchasing, selling, payments, costs and the eventual general ledger |
| Livestock | Individual animals, flocks, breeding, husbandry observations, livestock movements and external traceability references |
| Crops | Fields/beds, seasons, crop cycles, applications, harvests and crop-specific records |
| Make | Woodwork, food production and other manufacturing orders, recipes/BOMs, yields and production quality |
| Stay | Accommodation, hunting enquiries/reservations, resource calendars, guest administration and hunting evidence |
| Work | Staff, tasks, equipment, maintenance, water infrastructure and general farm operations |

Use **one legal entity per installation** initially. Multiple farms, camps, accommodation sites and enterprises may belong to that entity. Trading between entities is a real customer/supplier transaction. Consolidated multi-company statutory accounting is outside the first release.

Throughout this document:

- **Verified** means a specific fact or published process was observed in a primary source linked below. It does not establish every exception or later amendment.
- **Product requirement** is the proposed software behaviour, derived from the user's stated scope and the practical implications of the evidence.
- **Activation gate** identifies information required before a particular regulated function is used in production. It does not block building the ordinary operational functions.
- **Unresolved** means research did not establish an authoritative current answer or integration contract. Do not turn it into a default business rule.

Official portals can contain stale summaries. The examples in section 4 show why a recent crawl date is not an effective date. Legal packs must track the underlying instrument, scope and commencement, not just a web page title.

## 2. The farmer's working day

The initial home screen should answer six questions: what needs attention today; what money is due in or out; where the animals are; what stock is running low; who or what is booked; and which jobs or permits are overdue. All totals must drill down to their source records. Missing or stale data must be visible instead of silently showing a misleading zero.

### 2.1 Roles and practical access

| Role | Main actions | Information excluded by default |
| --- | --- | --- |
| Owner/manager | Approve spend, review stock and animal exceptions, view enterprise results, resolve conflicts | Business access within assigned scope; security administration and restricted personal records require separately granted permissions; high-risk changes remain audited |
| Farm supervisor | Plan crew work, record stock use, inspect camps/water, submit animal events | Staff bank details, payslips, unrestricted journals and private guest identity documents |
| Stockperson | Scan/search animals, record counts, weights, births and treatments already instructed by an authorised professional | Sales margins, payroll, unrelated farms and guest data |
| Garden/crop lead | Plan beds, record inputs and harvests, release work for review | Payroll and finance configuration |
| Workshop/food production lead | Issue production materials, record output, losses and quality checks | Unrelated staff and guest information |
| Lodge/hunting coordinator | Enquiries, deposits, bookings, arrivals, housekeeping and permit checklist | Employee pay and animal health records unrelated to the booking |
| Bookkeeper/accountant | Supplier bills, customer invoices, payments, reconciliations and exports | Personal health details and unnecessary passport images |
| Seasonal worker/contractor | Assigned work, own time submissions, relevant instructions | Whole-farm reports, wages of others, bulk contact export |
| External veterinarian/technician | Time-limited access to explicitly assigned records, or a reviewed export | Unrelated customer and financial records |

User groups are not sufficient isolation by themselves. Every request must check entity, farm, permitted enterprise, action and record status. Hiding a menu item is not authorisation. Attachments, exports, reports and API reads require the same checks as ordinary forms.

### 2.2 Mobile and connectivity requirements

Treat patchy field connectivity as a design constraint to validate with the pilot farmer. Do not claim that every farm has the same connectivity profile. Botswana's published livestock permit service explicitly provides an assisted route for users without internet access [R06].

The first practical version is a responsive Joomla application with fast small forms, large touch targets, a low-bandwidth list view, optional image uploads and printable daily sheets. An independently deployed farm LAN server may be evaluated where a local network exists. A browser Playground is a development/test environment and is not proof of a durable production offline server.

A later offline field-capture mode may queue observations, count sheets, time entries and draft stock-use requests. Each queued item needs an operation UUID, device/user identity, captured time, server-received time, source record version and visible sync state. The server remains authoritative for stock availability, booking capacity, posted money, regulated movement clearance and hunting quota. Conflicts go to a review queue; they do not become silent last-write-wins updates.

Offline users may record an event that happened; the application must not represent an unverified event as an authorised movement, confirmed booking or posted transaction. Show both the real-world event date and the administrative approval date.

## 3. Country packs and the three-currency boundary

### 3.1 Configuration belongs to the correct scope

| Scope | Examples | Rule |
| --- | --- | --- |
| Installation | Legal entity, enabled country/currencies, reporting currency, supported modules | Set during onboarding; changes require a controlled migration where they affect posted data |
| Farm/site | Country, province/region/district, establishment numbers, time zone, physical directions | Never infer country from the currency or phone number |
| Enterprise | Cattle, sheep, garden, workshop, food, lodge, hunting | Own budgets and reporting dimensions; shared people and items remain shared |
| Regulatory rule pack | Tax, wage category, permit type, retention rule, tourism reporting | Versioned and effective-dated; inactive until approved for the exact jurisdiction and activity |
| Transaction | Country of supply, currency, price, tax/levy treatment, source-document snapshot | Freeze the applicable rule version when approved/posted |
| External evidence | Authority, document number, issued/valid dates, status, scope, attachment | Uploading a file alone must not set an approval to valid |

A country pack record needs an identifier and version, country and subjurisdiction, activity and species/product scope, authority, source URL and instrument/version, retrieved date, effective-from/to dates, known exceptions, owner, reviewer, approved date, fixtures and supersession link. Keep the approved configuration used for an old transaction even after a newer pack becomes active.

Separate **government-issued status**, **the farm's verification status**, and **ERP workflow status**. For example, an uploaded permit can be issued by the authority, awaiting scope review internally, while the movement remains planned.

### 3.2 Currency behaviour

Bank of Namibia states that NAD is pegged at parity to ZAR and that the rand is legal tender in Namibia [R01]. Bank of Botswana describes the pula's peg to a trade-weighted currency basket rather than a one-to-one peg to the rand [R02]. These facts justify different exchange handling; they do not mean bank conversion fees are zero.

| Currency | User-facing display | Initial use | Required behaviour |
| --- | --- | --- | --- |
| NAD | `N$` and the explicit `NAD` code on documents | Namibia functional currency or transaction currency | Support a dated NAD/ZAR parity policy; keep the actual transaction currency and payment instrument |
| ZAR | `R` and the explicit `ZAR` code | South Africa functional currency; regional transactions | Do not treat an invoice denominated in ZAR as a South African tax transaction automatically |
| BWP | `P` and the explicit `BWP` code | Botswana functional currency or transaction currency | Require an approved dated exchange rate for conversion into another functional currency |

Product requirements:

1. Store amounts as fixed-decimal values or integer minor units with explicit scale; never binary floating-point money. The schema must also preserve quantity, unit price, exchange-rate and tax-calculation precision.
2. Store the rate direction unambiguously: for example, functional-currency units per one transaction-currency unit. Record the source, timestamp/effective date and any manual override reason.
3. Keep transaction amount, functional amount, rounding adjustment and conversion rate together. Reports display their currency in headings and totals; they never sum unconverted currencies.
4. Invoices, deposits, receipts, refunds, supplier credits, bank fees and settlement differences must be distinct records. A deposit is not automatically earned revenue.
5. A BWP invoice settled on another date may generate realised FX differences. Accounting treatment is enabled only in the approved accounting phase; the operational pilot exports the original amounts and rates to the accountant.
6. Do not change historical invoices when the reference exchange-rate table is updated. Revaluation is a separate approved process.
7. Accept only NAD, ZAR and BWP in the first release. An international hunting client can receive a quote in one of those currencies. A later USD/EUR request is a scoped extension, not hidden automatic conversion.
8. Do not assume a Namibia-dollar cash payment will be accepted by a South African business merely because NAD and ZAR have parity.
9. If multiple cash currencies are accepted at a Namibia market stall, count each cash drawer by currency and reconcile separate receipts. A single combined nominal total is insufficient.

South African SARS guidance addresses the currency and exchange-rate treatment of certain VAT invoices [R12]. That is a reason to keep tax-reporting currency separate from the customer's presentation currency. It must not be copied as a rule for Namibia or Botswana.

### 3.3 Dates, language, units and addresses

Proposed site time-zone identifiers are `Africa/Windhoek`, `Africa/Johannesburg` and `Africa/Gaborone`. Resolve them through the runtime time-zone database; do not hardcode a permanent UTC offset. Store instants in UTC with their origin context. Store civil dates such as birthdays, crop dates and accommodation night dates as dates, not midnight UTC conversions.

Use ISO machine dates and an unambiguous human format such as `19 Nov 2026`. Store guest arrival/departure in the accommodation site's local time. Date-only reservations use a half-open interval: arrival night is included; departure date is excluded. A field observation's recorded date is not silently replaced by its upload date.

English is the proposed first maintained UI. All labels, status names, validation and documents must use Joomla translation strings from the start. The next translations are selected with actual pilot users; Afrikaans, Setswana and particular Namibian languages are candidates, not assumptions about every worker. Allow farm-specific common names alongside stable animal/crop species codes.

Support kg, g, tonnes, litres, millilitres, m, m², m³, hectares, each, crates/bags with explicit pack size, hours and accommodation nights. Never convert a bag to kg without the item-specific pack definition. Never convert liveweight to carcass weight using an unapproved universal factor. Wood length, volume and count are independent measurements unless a validated item-specific conversion exists.

Addresses need country, province/region, district, locality, farm/property name and number, postal address, GPS location, gate/access directions and optional street address. Do not make a street number mandatory for a rural farm. Keep coordinates for sensitive wildlife, residences and restricted infrastructure behind permissions.

## 4. Tax and accounting localisation: evidenced risks and bounded scope

### 4.1 What this research established

| Country | Primary evidence observed | Consequence for the product |
| --- | --- | --- |
| Namibia | NamRA's hosted amended VAT Act includes a N$1,000,000 mandatory-registration threshold; the ITAS summary still displays N$500,000 [R09, R10]. | Treat the generic summary as potentially stale. Confirm the enacted text, commencement and the farm's registration before activation. Do not infer registration from turnover alone. |
| South Africa | SARS' 25 February 2026 tax-rates page states a 15% standard VAT rate. Its invoice guidance describes required invoice details [R11, R13]. | Implement effective-dated rates and invoice templates. Keep zero-rated, exempt, outside-scope and non-registered cases distinct. |
| Botswana | BURS' legacy explainer displays 12%; its 2026 Act states 14%. The same official download contains a 1 July 2026 partial-commencement order with exceptions affecting some tourism provisions [R14, R15]. | Use the 2026 legislation and exact commencement analysis for the approved pack. The differing portal pages must not be averaged or treated as interchangeable. |

These are **research observations, not production seed data**. No automatic VAT registration, tax filing, tax deduction, tourism levy or payroll rule should be activated solely from this table. A diversified farm may have different treatments for raw produce, processed foods, accommodation, hunting, timber and imported equipment, and may not be registered for VAT at all.

### 4.2 Pilot versus statutory accounting

The pilot must record customers, suppliers, quotes, orders, receipts, expenses, invoices where legally configured, payments, stock movements, enterprise cost dimensions and document attachments. It must export consistent source records for the farm's accountant and reconcile operational cash/bank movements.

Full general ledger, statutory statements, tax returns, agricultural valuation policy, depreciation, lease accounting and local payroll calculations require their own acceptance gates. Do not ship a dashboard labelled net profit if it omits stock valuation, depreciation, unpaid bills or other material costs. An operational contribution report must clearly identify its basis and exclusions.

Before enabling full books, obtain an approved chart of accounts, reporting basis, opening trial balance, tax registration details, financial year, stock valuation policy, agricultural asset treatment, document numbering, closing-period policy, bank opening balances and accountant-approved examples. A biological animal register and a financial valuation register are related but are not the same ledger. No automatic recognition of a birth as taxable revenue is implied.

The tax engine needs dated rules by legal entity, place/type of supply and item/service classification. Support overrides only with permission, reason and retained original calculation. Reversals and credits retain links to original documents; editing a posted amount in place is prohibited.

## 5. Livestock: individual animals and practical flock management

### 5.1 Species and identity model

Seed optional templates for cattle, sheep and goats first. Later templates can cover poultry, pigs, horses and farmed wildlife if the pilot needs them. Candidate breed names are editable reference data rather than hardcoded program branches. Do not imply that a list is an official national breed register.

Keep internal immutable animal identity separate from official identifier(s), replacement tags, farm nickname, brand, herd/flock identity, establishment and owner. Tags can be replaced; the animal's history must remain intact. Preserve leading zeroes in all external identifiers and treat them as strings. Validate formats only against a confirmed country/schema version.

Each animal can have species, breed, sex, birth-date precision, dam/sire relationships, acquisition, legal owner, keeper, locations over time and exit reason. Support unknown parentage and approximate birth dates honestly. Do not invent a full birth date where only a year is known.

Flocks require membership or count ledgers with dated splits, merges, births, purchases, deaths, transfers and sales. A batch-only record is allowed only where the operation and local requirements allow it. The software must be able to promote an animal into individual tracking without double-counting flock stock. A farm's animals physically held elsewhere and another owner's animals on this farm must be distinguishable.

### 5.2 Country traceability differences

| Country | Verified authority/process | Required records | Initial integration approach |
| --- | --- | --- | --- |
| Namibia | DVS administers NamLITS [R03]. LLPB's published functions include animal and tag registration, movement permits/notices, statements and reconciliation [R04]. | Official animal/tag IDs, stock brand, keeper/herd ID, establishment ID, permit and movement-notice references, current restriction evidence, reconciliation exceptions | Reviewed imports/exports and links to authoritative records. No undocumented API or automatic permit-issuance claim. |
| South Africa | Government guidance requires registered identification marks for cattle, sheep, goats and pigs [R05]. Published FMD controls change over time and introduce movement restrictions [R07]. | Ownership/identification evidence, originating and destination holdings, owner declarations, transport documents and permits applicable to current disease/location rules | Configurable document checklist reviewed by the responsible person. Do not transplant NamLITS identifiers or assume one static national movement rule. |
| Botswana | BAITS covers animal registration, ownership transfers, arrivals, treatments and exits; the government provides a livestock movement permit process [R06, R08]. | BAITS/keeper/animal identifiers, ownership change, departure/arrival status, permit evidence, deaths/losses and drug-treatment references | Reconciliation with authorised BAITS records; assisted/manual routes supported. An online request is not necessarily the final collected international permit. |

No reviewed source established a supported public API contract for these systems. The agent must obtain an official API or data-exchange specification and authority before implementing direct integration. Avoid scraping a signed-in government portal as the default integration strategy.

### 5.3 Movement is a workflow, not a location edit

Use planned → awaiting approvals → authorised for the defined movement → dispatched → received/reconciled, with cancellation and exception branches. This is the ERP's internal workflow; its labels must not impersonate the government's decision.

A movement includes animals or count lines; origin and destination establishments; owner and keeper; purpose; departure/arrival; vehicle/transporter; relevant documents; authority; and the person who verified validity, species, quantities, dates and scope. An internal paddock move is a different movement type from a change of establishment or country. Whether it requires an external permit is a rule-pack decision, not a universal assumption.

Prevent an animal being dispatched twice, sold after a recorded death, or counted at both origin and destination. In-transit status must have its own reconciliation. Handle shortages, tag discrepancies and partial receipts explicitly. A transaction cannot be marked complete merely because a transport PDF was uploaded.

Disease restrictions are effective-dated constraints by site, route, species and authority, with evidence and expiry/review dates. A stale downloaded restriction list cannot certify safety. External movement clearance requires current human verification until a validated official integration exists.

### 5.4 Health, reproduction, feed and performance

Record observations, authorised treatment plans, actual treatments, medicine stock lot, administrator, professional reference, treatment time, withholding/withdrawal restrictions and follow-up. The system records veterinary instructions and product-label information; it does not diagnose, prescribe a dose or invent a universal withdrawal period.

Restrictions may differ for meat, milk and other outputs. Model a restriction interval with source and approval, and block affected dispatch/harvest workflows according to the approved configuration. Correcting treatment history must leave an audit trail. Medicine stock expiry, lot traceability and storage records link to Ledger and Work.

Breeding records include mating/exposure windows, sire/dam where known, examination results, expected-date ranges, births, fostering, weaning and culling decisions. Sheep workflows include flock joining/lambing and optional wool production; goats can use adapted templates. Do not use one species' gestation or classification schedule as universal code.

Weights retain measurement unit, device, date, method and estimated/actual flag. Growth metrics need paired observations and valid intervals; show no-data rather than an invented rate. Feeding and grazing allocate actual feed issues and labour to animals/flocks or enterprises without double-posting the same stock use.

Core management reports: animals by location/status, missing IDs, births and exits, reconciled opening/closing numbers, upcoming follow-ups, restricted animals, feed use, weight changes, breeding outcomes and cost per enterprise. Each metric must define its denominator and date window.

## 6. Crops, gardens, grazing and water

### 6.1 Crop scope

Support small irrigated vegetable beds as well as fields, orchards and forage. Illustrative selectable crops include maize, sorghum, pearl millet/mahangu, beans, tomatoes, onions, cabbage, pumpkins, leafy greens and fodder crops. This is a product seed suggestion, not an agronomic suitability recommendation for every region or farm.

The minimum crop cycle has site/field/bed, area and unit, season, crop/variety, planting material lot, planting date, expected operations, input applications, labour, irrigation, observations, harvests and closure. Multiple crops or repeated harvests from a bed must be representable without overwriting previous history.

Record pesticide/fertiliser applications as approved instructions plus actual use: product/lot, quantity, area, operator, relevant weather observation, application date and restrictions supplied by a qualified adviser/label. Do not calculate a universal dose or safe harvest date. Harvest clearance must inspect applicable restrictions and quality holds.

Harvest creates a traceable batch in Ledger with quantity, grade, harvest time, plot/cycle and disposition. Grade-outs, spoilage, own consumption, animal feed and transfer to food production are separate movements. Repeated harvests and a partial failed crop must not force a full-cycle close.

Seedlings, compost and manure can be tracked at useful precision without overcomplicating the first release. Reusing manure or crop residues must not create circular cost allocations or duplicate inventory. The selected valuation policy determines whether a by-product carries cost.

### 6.2 Pasture and farm land

Keep maps/areas, camps/paddocks, grazing history, grazing rest periods as observations/plans, fence/gate condition, invasive-plant work and land-use permits. Carrying-capacity estimates must have source, season, confidence and units. The ERP should help the manager compare scenarios; it must not present a fixed stocking rate as valid throughout Southern Africa.

Capture owned, leased, communal or other tenure using documents and rights records. A farm name does not prove title, exclusive grazing rights or permission to hunt/harvest. Separate land ownership from permission to undertake an activity on that land.

### 6.3 Water, rainfall and resilience

Work owns boreholes, pumps, tanks, dams, meters, pipes, troughs, irrigation equipment and maintenance; Crops owns crop-water work; Ledger owns costs and consumables. Shared infrastructure costs can be allocated by measured use or an approved allocation basis.

Minimum records: asset/location, source, capacity/unit, meter readings and rollover/reset, water-level/quality observations, pump runtime, fuel/energy use, faults, repair orders, permit/right evidence and tasks. A missing reading is not zero consumption. Meter differences must detect replacement, reverse readings and implausible jumps.

Primary sources show distinct permission processes: Namibia publishes borehole and water-use forms; Botswana has water-right applications; South Africa distinguishes water-use categories and licensing processes [R26–R29]. The product must store the applicable authorisation and conditions instead of using a single regional borehole checkbox.

Rain gauges require location, measured interval, millimetres, observer/device and missing-data flags. Seasonal charts must distinguish observed rain from forecasts. Drought budgeting can compare feed stock, planned consumption, cash and water constraints, with manager-approved assumptions. Automated remote pump control and disease/fire decision-making are outside the pilot.

Work should cover fuel receipts/issues, generator and solar assets, vehicle odometer/hour meters, service schedules, fencing, road repairs, firebreak inspections, emergency contact lists, incident reports and insurance evidence. South African FPA guidance supports the need to organise prevention, training and communication [R30]; no emergency response may depend on a successful ERP upload.

## 7. Hunting, wildlife and accommodation

### 7.1 Wildlife is a distinct domain

An optional wildlife register may track individual managed animals or surveyed populations by species, area, date, method and uncertainty. A survey estimate is not saleable stock and must not be reduced like a guaranteed warehouse balance. Sensitive species locations need separate permissions and safe exports.

Candidate species labels for configuration include kudu, oryx/gemsbok, springbok, impala, eland and relevant local species. Enabling a species does not grant permission to hunt, sell, transport or export it. Protected status, seasons and quotas depend on jurisdiction, property, species and current permission.

Namibia's MEFT publishes separate forms for hunting-farm/operator-related matters, trophy permits, quotas and CITES [R16]. South African national and provincial authorities have distinct permit roles [R17, R18]. Botswana's published services distinguish tourist enterprise licensing, trophy dealing and export permissions [R19–R21]. These support a layered permission model, not a generic hunt-approved Boolean.

### 7.2 Enquiry-to-hunt workflow

Stay should manage enquiry → provisional offer → time-limited reservation → deposit/commercial confirmation → compliance review → operationally cleared activity → activity record → final settlement → document/dispatch completion.

Track the customer, hunting client, accompanying guests and payer separately. Store requested species/activity, hunt dates, site/concession, guide/professional qualifications and validity, client documents when needed, property consent, transport, accommodation, resources and permit references. Payment confirmation alone does not clear a hunt.

Quota allocations need species, jurisdiction/site, season/period, authority document, authorised quantity, reserved quantity, actual utilisation, corrections and remaining capacity. Simultaneous reservations must be serialised so that two coordinators cannot reserve the last allocation. A cancellation does not automatically return a harvested or otherwise legally consumed allocation. The relevant authority's conditions determine the treatment of outcomes, including unsuccessful or wounded/lost events.

Record outcomes neutrally and accurately; do not infer them from an invoice line. Link trophy/animal-product identifiers, custodian transfers, taxidermist, transport and export evidence where applicable. A paid invoice does not prove legal acquisition or authorise export. Public confirmation screens must never reveal sensitive wildlife locations or identity documents.

Do not hardcode a common hunting season, national quota, rifle/import rule or CITES status for all three countries. Obtain the exact current licence conditions and relevant authorities before enabling those workflows for a farm. Store required travel/firearm/transport documents where applicable; the ERP is not a permit issuer.

### 7.3 Accommodation

Support individually bookable rooms, units and campsites, capacity, adult/child occupancy, rate plans, local dates, meal plans, deposits, cancellation policies, maintenance blocks, housekeeping and guest arrival/departure. Hunting packages can reserve accommodation and guides together without merging their separate capacity ledgers.

Booking invariants:

1. Active overlapping allocations cannot exceed a resource's capacity.
2. Holds expire through a reliable server process, with retries; an expired hold cannot become confirmed without a fresh availability check.
3. Concurrent booking attempts, price changes, payment callbacks and manual changes are idempotent and version checked.
4. Group bookings allocate explicit resources or validated pooled capacity. A manually typed total guest count does not reserve beds.
5. Maintenance/out-of-service blocks participate in the same availability calculation.
6. Check-out on a date and check-in on that date may coexist where turnaround policy permits; housekeeping readiness is an independent status.
7. Refunds, no-shows, cancellations, forfeitures and rebookings preserve the original booking and financial evidence.

Namibia Tourism Board publishes guest-farm/lodge and other registration forms and accommodation-levy guidance [R22, R23]. Botswana publishes accommodation licensing categories and TOLIS reporting/levy functions [R19, R24]. Store registration numbers and expiry, activity category and the applicable reporting pack. Do not assume South African accommodation follows either neighbouring country's levy rules.

## 8. Woodwork, food production and farmers' markets

### 8.1 Shared manufacturing core

Make should use versioned recipes/BOMs, operations, planned versus actual inputs, labour, machine time, production outputs, by-products, waste, quality holds and rework. Ledger owns the stock and cost entries. A production order cannot issue its materials once from Make and again through a generic stock form.

Support make-to-order woodwork and make-to-stock food in the same manufacturing model with different templates. The order freezes its BOM version. Substitutions and extra use require an approved variation. Planned yield is a forecast; actual yield controls inventory receipt.

Start with simple one-level BOMs and explicit steps. Multi-level routings, capacity optimisation, automated scheduling and industrial sensor integrations follow only when real use cases justify them. Nonetheless, lot genealogy and correction/reversal must exist from the first production batch.

Farm-made feed blends can later use the same batch and input-lot model, with appropriate separation from human-food production. Nutritional formulation, ingredient suitability and any medicated-feed controls require qualified approved instructions; the application must not invent a balanced ration. Animal-feed use is a consumption destination in Ledger, while producing saleable feed is a Make workflow with its own approved product and quality rules.

### 8.2 Woodwork

Records include material species/category, supplier or harvest source, permit evidence where applicable, dimensions/grade, moisture observation where useful, stock unit, cutting/assembly operations, consumables, finish, output variant and job labour. The farmer can quote a table, gate, toy or other item and see material and labour costs.

Model offcuts that remain usable separately from waste. Avoid converting every offcut into its own SKU; size/grade bins or a remnant register may be enough. Finished item variants and optional engraving/customisation must be captured on the order and carried to production.

Namibia's trade portal identifies permit-controlled activities for forest produce [R25]. Purchased timber, farm-harvested wood, bush thinning and charcoal production can have different evidence requirements. A workshop sale does not erase the need to retain lawful-source documentation. Other-country forestry packs remain an activation investigation where that activity is used.

### 8.3 Food, preserves and other value-added products

Minimum food template: approved recipe version, ingredient and packaging lots, allergen attributes, production batch, process/check records required by the producer's validated plan, responsible operator, quality release, date marking, storage requirements and complete sale/recall traceability. Canning and shelf-life parameters must come from a competent food-safety process and applicable rules; this roadmap does not prescribe a canning method or certify a recipe.

Primary sources show country-specific food-control and premises regimes, including South Africa's food-premises regulations and Botswana's food-control/manufacturing requirements [R31–R34]. Namibia's local-authority fitness process is location-specific and cannot be applied as if all rural farms were in Windhoek [R35]. Obtain the actual farm's health, labelling and premises requirements.

Milk, meat, fermented products, beverages and packaged preserves may need different quality checks and permissions. Enable templates only for activities actually undertaken. A batch hold must block sale, dispatch and consumption in another production batch. Quarantined stock remains physically counted but unavailable.

For recalls, trace one step backward and forward through internal transformations: input lot → production output lot → transfers → sales/customers. Include anonymous cash market sales by event/date/receipt range without inventing customer identity. Recall records track stock still on hand, known recipients, quantities recovered, disposal and communication performed by authorised staff.

### 8.4 Farmers' market workflow

Transfer stock to a market-stall location; count opening stock and cash by currency; sell with a short item/favourite interface; record discounts and samples with permission; reconcile sold/returned/spoiled quantities; count closing cash; deposit cash; review variances. Printing a receipt and receiving money are related but separate operations.

A limited offline sales mode needs its own conflict/financial controls and must be validated before launch. The first release can use pre-numbered paper receipts or a connected stall, followed by a reconciled import. Do not claim card-terminal offline authorisation or bank settlement capabilities without an actual provider contract.

## 9. Staff, contractors, tasks and welfare

The operational people module covers employees and contractors, engagement periods, role/crew, emergency contacts with access restrictions, qualifications/expiry, work assignments, attendance, approved time, leave requests, training, PPE issuance and incident records. Record contractor work separately from employee payroll; a dropdown does not determine legal worker classification.

Time entries can allocate one person's day across livestock, crops, workshop, lodge and general maintenance. Do not duplicate a worker's paid hours when allocating cost across enterprises. Supervisor correction needs the original entry, reason and acknowledgement where appropriate. Workers need access to their own approved time and relevant notices without seeing other people's pay.

Namibia's published minimum-wage material contains staged sector/date changes [R36]. South Africa published a different 2026 farm-worker minimum and effective date [R37]. These are evidence that wage settings cannot be one regional number. Botswana's current sectoral orders, payroll deductions and applicable employment law must be independently verified before its payroll pack is enabled.

Phase-one scope is attendance, leave workflow, contract/qualification references, approved labour allocation and payroll export. Full payroll adds effective-dated pay rules, allowances, overtime, public-holiday/leave treatment, deductions, statutory contributions, payslips, final pay and filing only after local payroll validation. Lodging staff, workshop employees, farm staff and security work must not automatically inherit the same employment classification.

Food or housing provided to workers must not silently become a wage deduction. Require the exact approved legal/payroll treatment and any required agreements. Keep health, disciplinary and sensitive identity records in restricted storage, with a documented purpose and retention policy.

## 10. Privacy, document security and audit

South Africa's Information Regulator publishes POPIA and related legal material [R38]. Botswana's government-linked agencies publish the 2024 Data Protection Act [R39]. A January 2026 Namibian ministry statement discussed a Data Protection Bill still progressing through the legislative process at that time [R40]. The research does **not** establish the final Namibian position on 19 November 2026; verify current enactment and sector rules before deployment. Do not infer that lack of a verified law permits careless data handling.

Product baseline, independent of those legal conclusions:

- Collect only data needed for the operation and its approved obligations; display its purpose.
- Keep guest identity documents, staff records and sensitive wildlife locations out of public media directories and routine email attachments.
- Authorise every document download; use controlled storage, malware/type/size checks, expiry where appropriate and download audit.
- Encrypt transport; keep secrets outside JCB exports and source control; use least-privilege production credentials and backups with restricted access.
- Use retention categories and legal holds; a deletion request does not automatically erase required financial records. Pseudonymise where appropriate and retain the minimum audit link.
- Do not use blanket consent as the only possible processing basis. The approved country pack documents the actual basis and notice.
- Record who changed sensitive data and material workflow state, before/after values where suitable, time and reason. Avoid leaking secrets or full identity documents into the audit log.
- Provide supervised exports and a record of what was disclosed. Keep marketing permissions separate from operational booking communications.
- Make backups restorable and access-controlled; test the restoration and permissions rather than only checking that a backup file exists.

## 11. Requirement register and acceptance gates

| ID | Requirement | Owner | Minimum acceptance evidence |
| --- | --- | --- | --- |
| REG-001 | Country, site and functional currency are explicit | Core | Onboard one synthetic entity for each country; incorrect currency cannot change country rules |
| REG-002 | Three-currency arithmetic and immutable transaction rates | Ledger | NAD/ZAR parity, BWP conversion, separate cash counts and rate-change regression examples |
| REG-003 | Versioned local rules with provenance and approval | Core | Old invoice retains old rule; future rule does not rewrite it; unapproved rule cannot activate |
| REG-004 | Official and internal animal identities remain distinct | Livestock | Replacement tag retains history; leading zero survives import/export |
| REG-005 | External movement evidence and reconciliation | Livestock | Planned, partial dispatch, in-transit, partial receipt and discrepancy cases |
| REG-006 | Current disease/withdrawal restrictions respected | Livestock/Ledger | Blocked dispatch and reviewed correction; no dosage generation |
| REG-007 | Flock split/merge and headcounts reconcile | Livestock | Opening + births + purchases − exits = closing, with explicit corrections |
| REG-008 | Harvest creates traceable inventory | Crops/Ledger | Multiple harvests and grade-outs link back to plot/cycle and stock ledger |
| REG-009 | Water assets, readings and authorisations distinct | Work | Meter reset not interpreted as negative consumption; licence scope retained |
| REG-010 | Manufacturing consumes and produces once | Make/Ledger | Partial production, retry, spoilage and reversal do not duplicate stock |
| REG-011 | Food holds and recall genealogy | Make/Ledger | One input-lot recall finds all affected output and sales; anonymous sales remain honest |
| REG-012 | Accommodation capacity is concurrency safe | Stay | Simultaneous last-room requests: one succeeds; other receives an actionable conflict |
| REG-013 | Hunting booking, payment and authority clearance are separate | Stay | Paid booking with expired permit remains uncleared; quota race test passes |
| REG-014 | Staff time and privacy remain bounded | Work | Crew allocation reconciles total time; unauthorised payroll/document access denied |
| REG-015 | Operational export supports accountant reconciliation | Ledger | Cash, stock and source-document counts reconcile; no unsupported net-profit claim |
| REG-016 | Weak-network capture is explicit | All | Interrupted request/retry, stale client version and reconnect conflict exercised |
| REG-017 | Optional enterprises do not clutter simple farms | Core/UI | Cattle-only farm can complete daily work without manufacturing or lodge menus |
| REG-018 | Plain labels and usable local documents | All | Pilot farmer completes core scenarios on a phone; all dates/amounts/units unambiguous |
| REG-019 | Regulated integrations have verified contracts | Integration owners | No production adapter enabled without documented schema, authority and reconciliation |
| REG-020 | Recovery preserves both records and permissions | All | Restore synthetic entity, reconcile counts/totals and rerun cross-role access checks |

Country activation is separate from component installation. An unapproved payroll pack must not prevent a worker's attendance record. An unapproved hunting permit pack must prevent the application claiming operational clearance of a hunt, while still allowing an enquiry or draft booking. This preserves useful day-to-day work without disguising a missing control.

## 12. Phased regional rollout and discovery inputs

Start with one farmer, one legal entity and one agreed country configuration. The country is a discovery input: the user's location does not prove the friend's farm location. Use synthetic Namibia examples for development only where a concrete fixture is needed and clearly mark them as such.

### Pilot essentials

Shared people/items/farms, permissions, expenses, purchases, basic sales/payments, reliable stock, cattle/sheep records, daily tasks and water/asset records; add the friend's actual woodwork and basic lodging/reservations early enough to test shared costs and people. Provide accountant exports and independent backups. The farmer should finish a complete weekly cycle before adding advanced automation.

### Next useful depth

Crop cycles/harvest, manufacturing batches, food quality/recall, fuller stay/hunting workflows, improved enterprise contribution reporting and approved staff/payroll exports. Introduce offline capture only for carefully chosen workflows with proven conflict handling.

### Later gated functions

Full statutory accounting, local payroll, automated authority submissions, bank/payment integrations, online public booking, advanced production scheduling, telemetry and additional countries/currencies. Each requires a real operational need, verified interface and its own acceptance evidence.

Required farmer discovery inputs:

1. Country, subjurisdiction, legal entity, VAT/payroll registrations, financial year, accountant and current books.
2. Sites/enterprises, owned/leased/communal arrangements and relevant permissions.
3. Herd/flock sizes, individual identification practice, government traceability accounts and export formats.
4. Actual animal/crop species, gardening scale, harvest units and sales channels.
5. Wood/food products, production processes, quality responsibility and existing permits.
6. Accommodation resources, rates, cancellation/deposit rules, hunting operation type, guides, licences and quotas.
7. Staff roles/languages, shared-device use, literacy/accessibility preferences, contracts, timekeeping and payroll provider.
8. Devices, electricity reliability, mobile/network coverage by work area, printer/scanner availability and backup custodian.
9. Opening animal counts, inventory, money balances, unpaid documents, booked stays and data quality.
10. The first five decisions the farmer wants the system to improve, plus who is responsible for keeping each input current.

Do not ask the farmer to design the database. Gather examples of their existing day sheets, invoices, animal records, booking calendar and market reconciliation, then turn those examples into the acceptance scenarios in the companion document.

## 13. Source register

All sources below were researched on **2026-11-19**. Titles and observations identify the scope actually used. Linked pages can change; the implementation evidence pack should retain approved instruments/forms and hashes where distribution rights permit. These sources support bounded factual observations; the surrounding software design is a proposal.

| ID | Primary source | Evidence used and limit |
| --- | --- | --- |
| R01 | [Bank of Namibia: Inflation Target, 2025 media release](https://www.bon.com.na/Informations/Media/Media-Releases/2025-Media-Releases/Articles/Inflation-Target.aspx) | NAD/ZAR parity and rand legal tender in Namibia; not a transaction-fee or tax rule. |
| R02 | [Bank of Botswana: Exchange Rate Policy](https://bankofbotswana.bw/content/exchange-rate-policy) | Pula currency-basket framework; not a real-time executable FX feed. |
| R03 | [Namibia agriculture ministry: Directorate of Veterinary Services](https://mawlr.gov.na/directorate-of-veterinary-services) | DVS administers NamLITS; page provides institutional context, not an API contract. |
| R04 | [Livestock and Livestock Products Board: NamLITS Online general information](https://nammic.com.na/namlits-online-general-information/) | Producer functions, movement/registration and reconciliation evidence. A local register does not itself change the official herd statement. |
| R05 | [South African Government: Register an animal identification mark](https://www.gov.za/services/services-organisations/permits-licences-and-rights/animal-improvement/register-animal) | Registered marking requirement for named livestock types. Exact enforcement and exceptions require current regulations. |
| R06 | [Botswana Government: Issuance of Livestock Permit](https://gov.bw/animals-and-plants/issuance-livestock-permit) | Online and assisted application routes, movement purposes, international collection distinction. Search-index text retrieved; direct fetch timed out during this research. |
| R07 | [South African Department of Agriculture: FMD technical report, 31 October 2026](https://nda.gov.za/images/outbreaks/Foot%20and%20Mouth%20Disease%20Outbreak/Reports/2026/2026-10-31-fmd-technical-report_.pdf) | Recent changing control measures; not a guarantee of the restriction status of a specific farm. |
| R08 | [Botswana Government: BAITS user application](https://www.gov.bw/animal-husbandry/user-application-botswana-animal-identification-and-traceability-system-baits?_exception_statuscode=404&destination=%2F%3Fpage%3D3&page=1) | BAITS registration, ownership, arrival, treatment and exit functions; official page indexed with routing parameters. |
| R09 | [NamRA-hosted Value-Added Tax Act 10 of 2000, amended compilation](https://www.namra.org.na/documents/cms/uploaded/valueadded-tax-act-10-of-2000-0d8c7ed7fc.pdf) | Amended registration threshold and legislative context. Verify commencement and later amendments before activation. |
| R10 | [NamRA ITAS: Taxes](https://itas.namra.org.na/taxes) | Demonstrates a conflicting older threshold summary; not used as the authoritative threshold seed. |
| R11 | [SARS: Other Taxes, 25 February 2026 VAT section](https://www.sars.gov.za/tax-rates/other-taxes/) | Standard VAT rate observation dated by SARS. |
| R12 | [SARS: Binding General Ruling VAT 11, Issue 3](https://www.sars.gov.za/wp-content/uploads/Legal/Rulings/BGR/LAPD-IntR-R-BGR-2012-11-Use-Exchange-Rate.pdf) | Currency/rate treatment for the specified invoice cases; check applicability and supersession. |
| R13 | [SARS: Tax Invoices](https://www.sars.gov.za/businesses-and-employers/government/tax-invoices/) | Required invoice information and format distinctions. No unsupported cross-country reuse. |
| R14 | [BURS: Value Added Tax legacy explainer](https://www.burs.org.bw/index.php/tax/value-added-tax) | Conflicting older rate/threshold display, recorded as evidence-quality risk. |
| R15 | [BURS: Value Added Tax Act 2026 and commencement material](https://burs.org.bw/index.php/tax/tax-laws-2026?download=958%3Avalue-added-tax-act-2026) | Act 15 of 2026, rate and partial-commencement order; tourism exceptions need individual analysis. |
| R16 | [Namibia MEFT: Permits, registrations, certificates and licences](https://meft.gov.na/services/permits-registrationscertificates-licences/173/) | Distinct wildlife, trophy, quota, guide and export application categories. |
| R17 | [South African DFFE: TOPS permit and registration process](https://www.dffe.gov.za/tops-permit-and-registration-application-process-carrying-out-restricted-activities-terms-nemba-10) | National threatened/protected species process and issuing-authority distinctions. |
| R18 | [CapeNature: Hunting licences and permits](https://www.capenature.co.za/permits/hunting-permits) | Example of province-specific hunting authority; applies to Western Cape, not every province. |
| R19 | [Botswana Government: Tourist Enterprise Licence](https://www.gov.bw/tourism/application-tourist-enterprise-licence-tel?_exception_statuscode=404&destination=%2F%3Fpage%3D3&page=1) | Accommodation and tourism licence categories; search-indexed official routing variant. |
| R20 | [Botswana Government: Trophy Dealer Licence](https://www.gov.bw/natural-resources/trophy-dealer-licence?page=0) | Separate trophy-dealing authorisation; not permission to conduct a hunt. |
| R21 | [Botswana Trade Portal: Export/re-export of animal or trophy](https://www.botswanatradeportal.org.bw/index.php?id=41&r=searchProcedure%2Fview1) | Legal-acquisition and export evidence requirements; reviewed process is older and needs current verification. |
| R22 | [Namibia Tourism Board: Registration Forms](https://visitnamibia.com.na/registration-forms/) | Guest farm/lodge/camping and operator registration forms and levy resources. |
| R23 | [Namibia Tourism Board: FAQ](https://visitnamibia.com.na/faq/) | Accommodation-levy distinction and reporting context; exact computation requires approved current rules. |
| R24 | [Botswana tourism eServices: TOLIS FAQ](https://eservices-met.gov.bw/faq.html) | Enterprise licensing, accommodation-statistics and levy services; not a developer API specification. |
| R25 | [Namibia Trade Information Portal: Forest-produce licensing measure](https://namibiatradeportal.gov.na/trade-goods/measure-details/view_express_entity/259) | Distinct forest-produce activities subject to licensing/permits; activity-specific verification required. |
| R26 | [Namibia agriculture ministry: Water Services](https://mawlr.gov.na/water-services) | Published borehole and water-use application categories. |
| R27 | [Namibia agriculture ministry: Borehole licence application WA04](https://mawlr.gov.na/documents/268157/7963469/WA04_Application%2Bfor%2Ba%2Bborehole%2Blicence.Final.pdf/a59ba31d-c5a1-0505-cc01-d6816c97f5c8?download=true) | Form scope includes drilling and certain borehole works; no blanket determination of a farm's exemptions. |
| R28 | [Botswana Department of Water Affairs: Water-right application](https://www.water.gov.bw/application%20for%20water%20rights.html) | Water-right evidence and land-right documentation; older service page, verify operational process. |
| R29 | [South African DWS: Water-use licensing process](https://www.dws.gov.za/WAR/licenceprocess.aspx) | Activities and regional authority process; use/category determines exact requirement. |
| R30 | [South African Government: Register fire protection association](https://www.gov.za/services/services-organisations/register-business-or-organisation/register-fire-protection) | Organised fire prevention, training and communication functions. |
| R31 | [South African Department of Health: Food Control Regulations](https://www.health.gov.za/food-control-regulations/) | Published food-hygiene, premises and specialised food rules. |
| R32 | [South African Government: General food-premises hygiene regulations](https://www.gov.za/documents/notices/foodstuffs-cosmetics-and-disinfectants-act-regulations-general-hygiene-0) | R638 publication and attachment; current local enforcement/application must be checked. |
| R33 | [Botswana Ministry of Health: Food Control Act](https://www.moh.gov.bw/Publications/acts/FOOD%20ACT%201993%20BOTSWANA.pdf) | Food-control and premises framework; the hosted text is not proof of a complete current consolidation. |
| R34 | [Botswana Ministry of Trade eServices: Applications](https://trade.gov.bw/Home/Applications?DeptId=7) | Food-manufacturing clearance appears in industrial application requirements. |
| R35 | [City of Windhoek: Fitness Certificates](https://www.windhoekcc.org.na/fitness-certificates/) | Municipal example for food/business premises. Not applied to all Namibia or assumed current over later bylaws. |
| R36 | [Namibia labour ministry: National Minimum Wage Brochure](https://mol.gov.na/documents/53329/0/National%2BMinimum%2BWage%2BBrochure%2BFinal.pdf/fcbf08e0-1062-0892-601e-8f556ca399a7) | Phased, dated sector distinctions; a payroll pack must use current orders and employment facts. |
| R37 | [South African labour ministry: 2026 minimum wage announcement](https://www.labour.gov.za/Media-Desk/Media-Statements/Pages/Minister-of-Employment-and-Labour%2C-Meth-increases-the-statutory-National-Minimum-Wage-to-R30%2C23-per-hour.aspx) | 2026 farm-worker wage and effective-date change; not a complete payroll specification. |
| R38 | [South African Information Regulator: Acts](https://inforegulator.org.za/acts/) | POPIA and associated legal material. |
| R39 | [Botswana Financial Intelligence Agency: Data protection](https://fia.org.bw/data-protection) | Government agency links the Data Protection Act 2024; exact duties and commencement need legal-pack verification. |
| R40 | [Namibia MICT: Minister's 2026 year-start engagement speech](https://mict.gov.na/documents/869282/7497492/Ministers%2BSpeech%2B2026%2BYear%2Bstart%2Bengagement.pdf/d4f35532-67c9-934f-964f-507d31be8006?t=1769519978407) | Evidence of bill status at that speech; does not settle later enactment. |

