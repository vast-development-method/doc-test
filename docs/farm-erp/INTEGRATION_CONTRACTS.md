# Commands, owner services and external contracts

## 1. Contract status

All interfaces and route names below are **proposed farm-product contracts**. They are not documented existing JCB endpoints. Implement them through JCB-authored Powers, model/controller hooks and, where needed, native webservices/task plugins after the [JCB proof gate](jcb/JCB_PLAYGROUND_BUILD_GUIDE.md). Inspect actual generated routes and target Joomla authentication before claiming compatibility.

Use normal JCB forms and Dynamic Gets for ordinary master CRUD and reads. The command contract applies to actions whose invariants are stronger than a row save: posting, reservation, release, transfer, completion, correction and import.

## 2. In-process integration first

Satellite → owner service → transaction participant is the default call path. Do not make HTTP calls from one installed component to another inside a transaction. Owner service input consists of a validated command DTO and authenticated context; output is a stable result DTO. Owner classes are installed once and versioned.

The current inspected JCB templates do not establish a public arbitrary `getService()` or `getContainer()` method on the component. The first supported candidate is a thin owner-model method reached through Joomla's MVC factory and delegating to cohesive owner Powers. The bridge must not expose arbitrary base-model `save`, `delete`, SQL or table mutation. Prove service lifetime, same database driver and upgrade/loading through the [build guide](jcb/JCB_PLAYGROUND_BUILD_GUIDE.md#9-mandatory-two-component-service-and-transaction-proof).

| Public contract | Owner | Input / output | Critical guarantee |
| --- | --- | --- | --- |
| `ScopePolicy` | Core | Actor + requested action + record scope → allow/deny | Checks current permissions; rejects cross-farm GUID substitution |
| `CommandExecutor` | Core | Typed command + actor context → persisted command result | One receipt, one outer transaction, no hidden inner commit |
| `StockPosting` | Ledger | Validated source/lines + active transaction → effect references | Availability, unit, quality, valuation and uniqueness checked under locks |
| `StockEligibility` | Ledger coordinates required owner policies | Product/lot, actual disposition/purpose, date and source → eligible/blocked with reasons | Independent holds plus relevant animal/crop restrictions apply to every write path; caller cannot supply a bypass flag; absent required owner policy fails closed |
| `TradePosting` | Ledger | Approved document/version → status/totals/effects | Tax/account mapping and period checked; posted lines immutable |
| `PaymentAllocation` | Ledger | Payment/document splits → allocated/remaining balances | Cannot overallocate or post duplicate settlement |
| `PrivateDocumentAccess` | Core | File/owner reference + actor → authorised stream metadata | File link cannot bypass owner access; no public storage URL assumption |
| `CapacityReservation` | Stay | Resource/date/quantity claims → hold/confirmation | Claims all commit or none; concurrent callers cannot oversell |
| `DashboardProvider` | Each owner, registered with Core | Actor/scope/as-of → limited card DTO | Read only; enabled capabilities and data freshness explicit |
| `ExportProvider` | Relevant owner | Approved range/schema/version → file manifest + totals | Stable GUIDs, no hidden cross-scope records, repeatable watermark |

Names represent interfaces to author, not packages already discovered in a catalogue. Before creating one, inspect whether a suitable Joomla/JCB Power already supplies its actual behaviour. Generic Ledger issue/transfer/adjust/market or production commands must derive actual disposition from their validated source and invoke the required eligibility policy; calling Ledger directly never bypasses a domain restriction. Restricted flock descendants retain restriction ancestry across splitting, transfers and individual identification.

## 3. Transport envelope

If a remote command API is enabled, a candidate route is `POST /api/index.php/v1/farmerp/commands`. A single route is acceptable only with a fixed command allowlist, per-command action permissions, rate limits and payload limits. Separate resource-specific command routes are also acceptable if they preserve the identical semantics. Discovery/route tests decide the final native integration.

The [JSON Schema](contracts/command-envelope.schema.json) describes the transport shape. Each registered command adds a strict payload schema; accepting arbitrary JSON under `payload` alone is insufficient. Client-supplied actor, roles, functional currency, exchange approvals, calculated totals or permissions are never trusted.

Illustrative synthetic request:

```json
{
  "schema_version": "1.0",
  "request_key": "2ab99570-8b41-4b2a-962d-e48cc5ac93df",
  "command_type": "livestock.record_weight",
  "aggregate_guid": "e71805d8-2e96-4d59-b7db-e72cf1d6fca8",
  "expected_version": 7,
  "farm_guid": "14d5b16e-b8fa-44b6-b0d4-00a9f4ea18d0",
  "occurred_on": "2026-11-19",
  "payload": {
    "weight_kg": "421.500000",
    "observed_at": "2026-11-19T09:30:00Z",
    "measurement_method": "scale",
    "estimated": false
  }
}
```

These are fixture GUIDs, not live records or JCB definition identifiers. The server derives organisation and actor from the session/token and validates the selected farm and aggregate. A create command has no aggregate GUID/version until assigned; its schema defines that case explicitly.

Successful result includes `schema_version`, `command_id`, `request_key`, `correlation_id`, `aggregate_guid`, `aggregate_version`, `effect_guids`, `committed_at`, and a small safe result. A replay returns the committed result with `replayed: true`; recheck current authorisation before returning it. It must not resend notifications or generate new effect GUIDs.

## 4. Command processing order

1. Authenticate using the target Joomla-supported session/token mechanism. Session writes require CSRF verification; token endpoints require their own supported authentication and action policy.
2. Apply request size/rate limits, strict schema, unknown-field rejection, type/decimal/date validation and command allowlist.
3. Derive actor/organisation; authorise action and requested scope. Reject unsanitised relation IDs and file references.
4. Canonicalise accepted command content and compute its hash, including command type, scope, expected version and authenticated actor identity. Do not hash transport secrets or unordered object formatting.
5. Acquire the unique receipt under the transaction. An existing committed matching receipt returns its safe result; a different hash/actor is a conflict. An in-progress command is not executed a second time.
6. Load and lock aggregate and affected capacity/stock/period rows in the documented order; check expected version and invariants.
7. Perform owner-controlled effects, audit and outbox inserts. Commit once with the receipt/result.
8. Return success only after commit. A worker handles committed external work. Uncertain client delivery is resolved by the same request key.

Database uniqueness is required in addition to application checks. Receipts and effects need a retention policy long enough to prevent historic imports/webhooks replaying; deleting a receipt must not remove source-effect uniqueness.

## 5. Error semantics

| Condition | Candidate HTTP status | User-facing behaviour |
| --- | --- | --- |
| Unauthenticated / expired session | 401 | Reauthenticate; retain safe draft locally only if allowed |
| Denied action/scope | 403, or consistently concealed 404 | No data/record-existence leakage; no write |
| Bad envelope or unknown field | 400 | Field-specific message; preserve entered values |
| Valid shape but impossible domain action | 422 | Explain the actionable cause: expired permit, held lot, invalid quantity, etc. |
| Stale version or changed idempotency payload | 409 | Show current version; require review, not blind overwrite |
| Capacity/stock conflict | 409 | Refresh available quantity/resources and present alternatives |
| Too many requests | 429 | Retry after advertised delay; do not mint a new command key |
| Transient infrastructure failure | 503 | Correlation ID and safe retry; uncertain outcomes checked by original key |
| Unexpected defect | 500 | Generic message and correlation ID; internal diagnostic logged privately |

No endpoint returns HTTP 200 with an error that the UI treats as success. A logged exception is not evidence of rollback: tests independently query authoritative tables after failure.

## 6. Initial command catalogue

| Family | Commands | Principal effects |
| --- | --- | --- |
| Core | `core.approve_import`, `core.activate_country_pack`, `core.change_scope` | Controlled imports/settings/access audit |
| Stock | `stock.receive`, `stock.transfer`, `stock.reserve`, `stock.issue`, `stock.adjust`, `stock.reverse` | Quantity + valuation + source state + optional GL |
| Trade | `trade.confirm_order`, `trade.post_invoice`, `trade.post_bill`, `trade.post_credit`, `trade.close_cash_session` | Frozen snapshots, numbering, tax, balances, GL |
| Accounting | `finance.post_payment`, `finance.allocate_payment`, `finance.post_journal`, `finance.reconcile_bank`, `finance.close_period`, `finance.revalue_fx` | Balanced immutable financial effects |
| Livestock | `livestock.register_birth`, `livestock.record_weight`, `livestock.record_treatment`, `livestock.dispatch_movement`, `livestock.receive_movement`, `livestock.record_mortality` | Biological/ownership events plus required stock/cost effects |
| Crops | `crops.record_application`, `crops.record_irrigation`, `crops.complete_harvest` | Crop activity/input consumption/harvest lots |
| Make | `make.release_order`, `make.complete_batch`, `make.release_quality`, `make.start_recall` | Materials/output/genealogy/cost/quality restrictions |
| Stay | `stay.place_hold`, `stay.confirm_reservation`, `stay.expire_hold`, `stay.cancel_reservation`, `stay.approve_hunt`, `stay.record_hunt_outcome` | Capacity/quota claims and distinct commercial effects |
| Work | `work.approve_time`, `work.complete_maintenance`, `work.record_fuel_issue`, `work.approve_payroll_export` | Approved work evidence and linked costs/parts |

Before implementing each command, document required fields, permission string, scope, locks, source uniqueness, preconditions, transitions, effect owners, reversal and acceptance case IDs. A command with no actual caller is unfinished.

The [structured command registry](contracts/commands.json) supplies these contracts for every catalogue command. They remain proposed application commands, not claims of pre-existing generated routes.

## 7. Events and delivery

Use event names such as `stock.transaction_posted.v1`, `trade.invoice_posted.v1`, `livestock.movement_dispatched.v1`, `crops.harvest_completed.v1`, `make.batch_completed.v1`, `stay.reservation_confirmed.v1`, `work.maintenance_completed.v1`. Every event contains event UUID, schema version, owner/source GUID, organisation/farm scope, actor reference, UTC occurrence and correlation ID.

Outbox worker states: pending → leased → delivered; failed attempts return to pending with bounded backoff; exhausted attempts become needs_attention. Lease expiry allows recovery after worker death. Delivery deduplication is by event/destination, and consumer processing is idempotent. A network acknowledgement can be lost; delivery is at least once, not advertised as exactly once.

Notifications, report projections and exports can be delayed without corrupting stock or books. If notification fails, the farmer sees the committed action and the separate delivery problem. A domain command must never roll back a valid invoice solely because the mail server was unavailable.

Use a JCB-authored scheduled/console plugin with discovered target capabilities. Prove cron/lease behaviour on the actual deployment; browser Playground activity does not demonstrate unattended production scheduling.

## 8. External adapters

| Adapter | First implementation | Evidence / activation requirement |
| --- | --- | --- |
| Accountant | Versioned CSV + manifest + totals | Approved sample imported into the farmer's actual accounting process |
| Bank | Restricted CSV statement staging and reviewed matching | Bank format sample, duplicate rules, timezone and debit/credit sign convention |
| Government animal / permit systems | External IDs, document evidence, reviewed import/export | No invented API, automatic submission or claim of official acceptance |
| Email | Queued documents via configured Joomla mail transport | Verified recipient, sandbox test, retry and attachment privacy |
| Payment provider | Manual bank/cash first; optional documented provider adapter | Signature/replay verification and settlement/refund tests before enablement |
| Weather / meters | Manual entries first; optional authenticated import | Unit, timestamp, station, data quality and missing-reading rules |
| Public booking | Enquiry-only initially | Rate limits, minimal guest data and staff review; availability/confirmation exposed only after capacity proof |

Each adapter declares supported provider/version, credentials scope, environment, mapping version, rate limits, timeout/retry policy, redacted diagnostics, deactivation and replay procedure. Never embed credentials in package exports, screenshots, source URLs or fixtures.

## 9. Offline and import boundaries

Offline initially means **draft observation capture**, not final financial posting or authoritative reservations. Supported candidates: weight observations, rainfall, task progress and non-sensitive field notes. Each device item has a persistent request key and local capture time; on reconnect the server reauthenticates, rechecks current scope and validates the current aggregate. Rejected/stale drafts remain visible for correction.

No offline confirmation of invoices/payments, stock dispatch, medicine issue, room/hunt reservations or country-pack changes. Do not synchronize whole mutable tables or use last-write-wins for quantities. A lost device must not contain passport scans, payroll/bank data, production secrets or stored administrative tokens.

Imports use the same domain rules as UI commands. Stage → validate → dry-run → approve → execute idempotently → reconcile → archive receipt. A successful CSV parse is not a successful business import. Mixed-success batches expose row-level status and allow safe retry; a financial aggregate is all-or-nothing.
