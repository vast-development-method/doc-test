# Finance, inventory and enterprise costing

## 1. Evidence and policy boundary

The [ERP comparison](research/ERP_REFERENCE_COMPARISON.md) and [workflow patterns](research/ERP_WORKFLOW_PATTERNS.md) supply behavioural references and their limitations. This document chooses the new product's accounting and stock design. Examples are synthetic and deliberately exclude tax unless stated. They are acceptance fixtures, not tax advice or mandatory accounting policies.

The pilot can keep statutory books in the farmer's existing accounting system. Full native books are a later explicit release gate, with an accountant approving opening balances, mappings, asset/livestock treatment, tax and reporting. The product must not offer a trial balance in operational/export mode that implies unimplemented double-entry controls exist.

## 2. Numeric and date conventions

| Value | Proposed persisted form | Rule |
| --- | --- | --- |
| Quantities and unit costs | `DECIMAL(20,6)` | Validate bounds and product scale; whole animals/items cannot be fractional unless group weight is the actual unit |
| Calculation amounts | Exact decimal arithmetic, at least six fractional digits | No binary floating point; prove chosen decimal implementation exists on browser and production PHP |
| Posted monetary amounts | Functional/document currency minor units, initially two decimal places | Explicit rounding mode `half-up`; persist signed debit/credit or separate nonnegative columns consistently |
| FX/conversion factors | `DECIMAL(24,12)` with direction | Positive rates; prevent silent overflow; source/date/version snapshot |
| Business/accounting date | `DATE` | Separate from UTC posting instant and real occurrence date |
| Rate/tax validity | Half-open effective-date range | One applicable approved version for the selected use; ambiguity blocks posting |

The implementer may adjust storage precision after testing extreme supported values, but must update schema, fixtures and all adapters together. API decimals are strings. A nominal 1:1 currency relationship does not erase transaction currency, bank fees or exchange provenance; see [country evidence](research/SOUTHERN_AFRICA_REQUIREMENTS.md).

Tax calculation order is explicit: price basis → permitted discount allocation → taxable base → ordered tax rules → line rounding → document totals. Inclusive prices require the approved inverse rule. Allocate document discount/rounding residuals deterministically by fractional remainder and stable line GUID, preserving totals. A document may be posted only when sums match displayed totals exactly. Zero-rated, exempt and out-of-scope codes remain distinct where the country pack needs them.

## 3. Operational invariants

1. Stock on hand is the sum of immutable posted quantity entries; availability is on hand less active reservations and relevant holds.
2. Count/valuation effects and final source status commit together. A retry cannot produce a second movement, invoice, payment or journal.
3. A receipt establishes goods received; a supplier invoice establishes a payable. They are related, but neither substitutes for the other.
4. A customer invoice establishes a receivable; delivery establishes stock leaving; payment allocates a settlement. Each has its own date and provenance.
5. Posted documents are not edited or trashed. Corrections use credit/reversal/new documents and preserve links.
6. Monetary effects reconcile in functional currency; transaction-currency amounts remain available to explain settlement and FX.
7. Closed-period locks apply to all posting routes, scheduled jobs, imports and correction commands.
8. Enterprise allocations do not duplicate organisational expenses. A cost is posted once and attributed or reallocated with an explicit rule.

## 4. Stock policy

### Quantity and reservation rules

Every stock-managed product has a base unit and declared lot/expiry tracking. Use a single owned-location hierarchy: store → bin. Quarantine and in-transit stock are explicit statuses/locations with availability rules. Consignment/third-party stock, if introduced, requires separate ownership and must not be valued as farm-owned stock automatically.

Maintain independent `stock_hold` records for quality, recall and other restrictions. A quality release closes only its matching hold; another active hold still blocks the lot. Compute unavailable stock from the union of restricted units and reservation commitments, not by blindly subtracting overlapping full-lot holds twice. For partial holds, identify the affected quantity/partition and prove its allocation semantics; the initial safe policy can hold the entire lot when the affected units cannot be distinguished.

Reject negative available stock by default. A physical emergency is recorded as a pending discrepancy requiring an authorised count/adjustment, not as an invisible negative posting. A counted adjustment includes reason, evidence, counted time and approver; stale counts must reconcile intervening movements before posting.

Reserve against a source line; partial fulfilment reduces the reservation and on-hand quantity atomically. Cancelled/expired demands release remaining reservations exactly once. Transfer within a warehouse or same-site move is one balanced transaction. Travel between farms can use two honest physical stages: dispatch into owned transit, then receipt out of transit. A failed one-stage transfer may not leave only its debit or credit.

### Valuation

Initial stocked consumables and finished products use **perpetual moving weighted average** per product and warehouse valuation pool. Lot/bin choose physical traceability; they do not silently choose a different costing method. Transfers carry source value into the destination pool. FEFO is a picking policy, not a financial valuation method.

For an initial 10 units at N$20 and a receipt of 10 at N$30, on hand is 20 and value N$500; average is N$25. A 4-unit issue is N$100 and leaves 16 units worth N$400. Transferring 2 units carries N$50; the destination blends that value with its own pool. The combined organisation value remains unchanged.

Store enough cost precision and allocate rounding residue deterministically; the final depletion of a pool must bring both quantity and value to zero. A zero-quantity/nonzero-value exception is investigated, not silently discarded. Landed costs and supplier price differences use documented adjustment effects with traceable allocation; they must not overwrite an old entry.

Initial policy forbids reordering historic cost entries after downstream postings. A late physical event records its true occurrence date but posts financial/stock correction in an allowed current period, with a reason and accountant review. Later retrospective costing is a distinct feature requiring replay/revaluation tests, not a hidden date-edit option.

Individual animals/biological assets require an accountant-approved financial classification. The operational register can track the animal and acquisition cost without inventing statutory fair-value changes. Market-price observations and financial valuation entries are different records.

## 5. Purchase to payment

Purchase request (optional) → approved purchase order → partial/full goods receipt → supplier bill matching → approved payment → bank reconciliation.

Three-way matching compares ordered, received and billed quantities/prices within configured tolerances. It permits genuine service bills without goods receipts. Overdelivery, overbilling and substituted products require explicit approval. Unmatched goods received remain visible as an exception and, in native accounting mode, in the configured receipt accrual account.

Synthetic native-book fixture, no tax:

| Event | Debit | Credit |
| --- | --- | --- |
| Receive materials worth N$1,000 | Inventory 1,000 | Goods received not invoiced 1,000 |
| Accept matching supplier bill | Goods received not invoiced 1,000 | Accounts payable 1,000 |
| Pay bill | Accounts payable 1,000 | Bank 1,000 |

A bill price difference goes to the approved inventory/variance allocation policy, not an unexplained imbalance. Purchase return moves stock with source-cost provenance; supplier credit reduces the payable separately. Refunds/credits cannot imply goods were returned when they were not.

## 6. Sale to cash

Quote → sales order → reserve → deliver → invoice → allocate receipt → reconcile bank. Direct farmer-market sales can combine these into one command only if all required stock, tax, cash and journal effects remain atomic and the market receipt has a unique identity.

Synthetic fixture: deliver goods at carrying cost N$600, invoice N$1,000, receive N$1,000, no tax.

| Event | Debit | Credit |
| --- | --- | --- |
| Delivery | Cost of sales 600 | Inventory 600 |
| Invoice | Accounts receivable 1,000 | Sales 1,000 |
| Receipt | Bank/cash 1,000 | Accounts receivable 1,000 |

Return authorisation → physical return/inspection → accepted inventory transaction → customer credit/refund. Damaged returns may enter quarantine/scrap instead of saleable stock. Credit without return is a financial adjustment with an explicit reason. Keep the original tax and exchange snapshots needed by the selected country's correction rules.

An allocation has exactly one funding source: a real payment (including a classified deposit) or a posted customer/supplier credit. A credit can clear an invoice/bill without fabricating a cash payment. Validate same party, compatible AR/AP direction, supported currency pairing and remaining source/target amounts under locks. Allocation of an already posted credit changes subledger settlement; it does not recognise the credit's revenue/tax effect twice. An unapplied credit remains separately visible even when the customer's net balance is zero.

Cash sessions record opening float, cash/card/bank sales, refunds, expenses, expected cash, counted cash and variance. External card settlement is reconciled separately; a card receipt is not immediate bank cash. Market staff cannot hide discrepancies by editing opening float after close.

## 7. Double-entry, close and reports

Use a versioned chart of accounts with control-account mappings. Posting templates map approved event kinds to accounts; users cannot submit arbitrary balanced lines through a generic public endpoint. Manual journals are limited to authorised accountants with support and approval rules.

Required reconciliations:

- Stock valuation by warehouse/product equals inventory control accounts after approved timing adjustments.
- Open sales invoices/credits/allocations equal receivables control.
- Open purchase bills/credits/allocations equal payables control.
- Cash session totals equal cash ledger movements; bank reconciliation explains statement differences.
- Asset register roll-forward equals asset/depreciation controls.
- Trial balance total debits equals total credits, including reversals and FX entries.

Close process: resolve exceptions → complete bank/cash reconciliation → confirm stock counts/valuation → recognise approved accruals/depreciation/FX → review enterprise allocations → approve reports → lock period. Reopening is an audited accountant action with reason and affected report versions. Cross-period reversals must use an allowed date and retain the original date reference.

Reports for native accounting: general ledger, trial balance, profit/loss, balance sheet, receivable/payable ageing, cash/bank reconciliation, tax detail and enterprise margins. Cash-flow statements and statutory formats require the approved reporting pack; an operational cash trend is not called a statutory statement.

## 8. Currencies and FX

Choose functional currency once at setup. Every foreign document retains its transaction currency, original amount, exchange-rate direction/date/source, converted functional amount and rounding difference. Rates cannot be silently replaced after posting.

Synthetic BWP example, no tax: invoice BWP1,000 at **1 BWP = NAD1.35** produces NAD1,350 receivable/revenue. Settle at **1 BWP = NAD1.40**: NAD1,400 bank, NAD1,350 receivable release and NAD50 realised exchange gain. A bank fee posts separately. These rates are invented test inputs, not current quotes.

Partial payments track remaining transaction-currency and functional balances. Period-end revaluation affects qualifying open monetary items using an approved closing rate and a reversible/unwinding policy. Do not revalue nonmonetary inventory indiscriminately. Invoice/credit and settlement currency combinations outside the supported tested paths are rejected rather than guessed.

## 9. Costing across farm enterprises

Direct costs attach at source to farm, enterprise and, where useful, animal/group, crop cycle, production order or booking. Common fuel, wages, machinery and overhead use a versioned allocation basis: hours, hectares, head-days, measured consumption or explicit percentage. Persist basis quantities and approval so a report can explain why an expense was allocated.

Timesheets record labour once. Payroll journals or contractor bills create the financial cost; operational labour estimates remain labelled estimates until reconciled. Production absorption offsets the appropriate expense/clearing account rather than charging wages twice. Budget vs actual distinguishes commitments, accruals, posted costs and estimates.

Crop harvest costing allocates accumulated approved cycle cost across graded outputs using a declared method. Wood/food production snapshots BOM revision and actual inputs, operations, packaging, yield, by-products and waste. By-product value and scrap recovery cannot create unexplained negative main-product cost. Rework traces input lots and adds actual incremental cost.

Bookings split package value between accommodation, hunting and extras using the accepted quotation allocation. Deposits remain liabilities until earned under the approved policy. For a N$2,000 deposit: debit bank, credit customer deposits; apply to an issued invoice through explicit allocation, never recognise the same revenue again.

## 10. Accounting activation and export contract

In operational/export mode deliver versioned CSV files for parties, accounts/mappings, invoices/bills/credits, allocations, cash/bank movements, stock valuation and source documents. Include stable GUIDs, original/functional currency, dates, approved tax codes, farm/enterprise, status and export watermark. Export header/schema version and totals allow the accountant to check completeness. Prevent spreadsheet formula injection in text fields.

Native activation requires a signed cutover reconciliation: opening trial balance balanced; AR/AP detail agrees; inventory quantities/value agree; cash/bank/assets/deposits match; tax/control mappings approved; old export period frozen. Import opening stock and balances once with idempotent keys. The system records who approved the transition and its evidence.

Mandatory high-risk tests are in [the acceptance plan](ACCEPTANCE_AND_TEST_PLAN.md): replay, concurrency, partial failure, backdating, period-lock race, FX/rounding, lot recall, receipt/bill timing, deposits and complete reversal chains.
