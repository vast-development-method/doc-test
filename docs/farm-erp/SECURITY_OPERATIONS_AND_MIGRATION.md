# Security, deployment, data migration and operations

## 1. Deployment boundary

Playground validates JCB source, compilation and disposable installed workflows. Production requires a maintained Joomla hosting environment with supported PHP/database versions, HTTPS, durable storage, backups, scheduled workers and monitored recovery. The farm may use a managed remote server or an adequately supported LAN server; do not describe a browser tab as the production farm server.

At implementation time resolve current supported stable Joomla/JCB releases under the Skills version policy and record exact versions of JCB, Joomla, PHP, MariaDB/MySQL, browser and dependencies in a build receipt. Joomla's [technical requirements](https://manual.joomla.org/docs/get-started/technical-requirements/) and [version list](https://manual.joomla.org/versions/) are live references; do not infer a supported production combination from a research commit hash or an “upcoming” manual page.

Use the same database family and tested transaction behaviour in staging and production. Prefer the Playground-compatible family for the first release; supporting another engine is a separate tested target. Preserve decimal and date behaviour across the browser PHP runtime and native server.

## 2. Threat model and controls

| Threat | Required control | Proof |
| --- | --- | --- |
| Worker accesses another farm | Action + farm/record scope on every access path | Cross-farm direct URLs, guessed GUIDs, search/selectors, reports and file tests |
| CRUD bypasses posting rules | Immutable tables read only; command allowlist and guarded backend hooks | Generic save, API PATCH/DELETE, trash, batch, copy and import attempts denied |
| Lost/stolen mobile device | Short sessions, reauthentication, limited offline payload, revocation | Revoked actor cannot sync or retrieve old receipt/files |
| File disclosure or executable upload | Private storage/authorised streaming, MIME/size/extension checks, non-executable storage | Direct storage URL, MIME spoof, oversized file and owner-scope tests |
| SQL/XSS/CSV injection | Bound queries, output escaping per context, allowlisted identifiers, export neutralisation | Malicious name, filter, rich text, CSV and attachment filename fixtures |
| CSRF or forged webhook | Joomla CSRF for session writes; provider signature/time/replay checks | Invalid/missing/expired tokens or signatures rejected |
| Excessive API privilege | Least-privilege service accounts, explicit routes, rate/size limits | Anonymous/registered-only inventory and restricted field tests |
| Secrets in source/export | Secret references kept outside source, redacted diagnostics, export inspection | Scan exported JCB packages/site archives and logs before delivery |
| Financial or permit tampering | Append-only effects, reasons/approvals, restricted audit access | Original source/receipt survives correction and actor deactivation |
| Dependency or update compromise | Known provenance, locked build receipts, staging, rollback/forward plan | Fresh rebuild, checksum manifest, upgrade and restore exercises |

Joomla user groups, viewing levels and permissions are separate from record scope; use official [ACL guidance](https://manual.joomla.org/docs/general-concepts/acl/). Do not assume a component's ACL configuration automatically filters custom queries or file downloads.

Super User access is exceptional operational authority. It must not be the normal farmer account. Avoid world-readable database backups, private attachments in public `/images`, shared admin tokens, hardcoded API secrets and public debug routes.

## 3. Privacy and record retention

Classify data: public product descriptions, internal operations, confidential finances, restricted employee/guest identity, and secrets. Record the purpose and permitted roles for each field. Avoid collecting passports, health information or bank details merely because a generic ERP allows it.

Country packs provide approved retention and privacy obligations; [regional research](research/SOUTHERN_AFRICA_REQUIREMENTS.md) identifies evidence and uncertainty. Implement data export/correction/anonymisation workflows consistent with immutable financial evidence: retaining a transaction does not justify retaining every optional personal detail indefinitely. Legal holds and record-retention reasons are explicit.

Use managed-file ownership and deletion policies. A shared file is removed only when permitted references and retention allow it. Preserve original evidentiary documents separately from image thumbnails; a crop/display workflow may not preserve the original automatically. Store hashes, MIME and audit metadata; do not claim cryptographic signatures or legal admissibility from a hash alone.

## 4. Delivery artifact contract

Each release has a versioned manifest containing:

- Source commits and identities for package definitions, Powers, Fields, Field Types, Snippets, libraries/assets and approved country data.
- Exact installed build tool/runtime versions and selected source precedence.
- JCB-generated installable ZIPs and SHA-256 checksums, dependency/install order and compatibility range.
- Complete editable source graph, required migrations and seed inputs.
- Test receipts with environment, case IDs and actual results.
- Sanitised development-site archive where requested, with a proven independent restore.
- Operations, backup/restore, known limitations, upgrade and migration instructions.

Production secrets and real farm data do not belong in public GitHub. The `doc-test` repository currently contains research only. A future implementation agent confirms the authorised source and artifact destinations before publishing private source/data; this task is not permission to post a real farm database publicly.

## 5. Upgrade process

1. Read release dependencies and compare installed source/runtime versions to supported ranges.
2. Take and verify a recoverable database/files backup; record maintenance window and pending jobs.
3. Deploy to staging restored from a suitably protected representative backup; apply migrations and run upgrade scenarios.
4. Quiesce writes/workers as required; take final checkpoint; install Core, Ledger and domain packages in manifest order.
5. Apply idempotent, version-tracked migrations. Never silently drop a live column/table or rewrite historical journals.
6. Rebuild disposable projections and verify source counts, GUID links, balances, attachments, privileges and worker health.
7. Resume service only after smoke and reconciliation checks. Record versions, operator, time and artifacts.

Schema expansion and backfill should precede application assumptions. For large changes, use a staged forward migration. Ordinary database transactions cannot be assumed to roll back schema DDL. Code rollback is allowed only when old code is compatible with the resulting schema; otherwise restore the consistent backup or apply a reviewed forward fix. Never restore only files while keeping an incompatible database.

Uninstall must preserve live business data by default and block removal of required owners. A deliberate data purge is a separate authorised, backed-up operation. Test disabling a module without losing historical reporting.

## 6. Backups and recovery

Design targets for the first supported deployment: **RPO no more than 24 hours** and **RTO no more than four hours**, subject to the farmer's chosen hosting and connectivity. These are targets, not measured guarantees. Improve the RPO for busy markets/bookings using database log or more frequent backups if the deployment supports it.

Back up database, private files, site/configuration, extension manifests and keys needed to restore encrypted content. Keep protected off-device/off-site copies with an agreed retention schedule. Backup success means retrieval and integrity checks, not just a scheduler exit code.

At initial deployment and periodically thereafter restore into an isolated environment. Verify login/ACL, document hashes, animal counts, stock/valuation, AR/AP/GL totals, reservations and installed versions. Keep outgoing mail/payments/integrations disabled during restore verification. Re-enabling external delivery requires outbox watermark/deduplication review so old messages do not resend.

Measure elapsed restore time and the recovered transaction cutoff. A restore drill that exceeds targets creates an operational defect. Retain a printed recovery contact/process for the farmer when the primary server is unavailable.

## 7. Business data migration

### Discovery and mapping

Inventory existing spreadsheets, books, accounting exports, animal tags, stock lists, room calendars, customer/supplier details, asset lists and private documents. Record ownership, dates, currencies, units, duplicate identities and who can approve corrections. Choose a cutover date and a staging copy. Preserve original input files and hashes privately.

### Import order

1. Approved country settings, organisation, farms, enterprises, locations, units/currencies.
2. Parties/roles/addresses, products/conversions, stores/bins and account/tax mappings where enabled.
3. Employees/assets, animals/groups/identifiers, plots/cycles, resources/rate plans and recipe revisions.
4. Approved opening lots/quantities/costs, cash/bank, AR/AP detail, deposits and financial opening balances.
5. Future reservations, active orders/tasks, restrictions/permits and linked documents.
6. Optional historical operational records only after the opening-state reconciliation prevents double counting.

Every import uses staging, strict mappings, dry-run totals, reviewed duplicate handling and idempotent row keys. It does not bypass owner services. Separate an imported historical event from a posting that changes opening balances; replaying both must not duplicate stock or money.

### Reconciliation and acceptance

Compare row counts, head counts by identity/group, stock quantities and values by location/product, AR/AP totals by party/currency, bank/cash, deposits, bookings by resource/night and document checksums. Record expected, actual, difference and approved resolution. Reject a migration with unexplained material differences. The owner/accountant signs the actual reconciliation receipt, not a generic “import complete” message.

### Cutover and fallbacks

Freeze agreed source systems, capture final delta, import and reconcile, run role-based smoke tests, then open the new system. Avoid dual entry of the same live stock/cash event. If a temporary parallel comparison period is needed, one system remains authoritative and the copy is explicitly non-posting.

The rollback plan names the checkpoint and how transactions entered after cutover are exported/recovered. Restoring yesterday without accounting for today's business is not a complete rollback.

## 8. Monitoring and support

Monitor application error rate/latency, database contention/space, backup age, worker heartbeat, outbox queue/dead letters, failed imports, stock/GL integrity checks, expiring permits/certificates and unavailable external adapters. Alerts go to configured responsible users; avoid notifying every worker about accounting incidents.

Log a correlation ID, command type, safe source GUIDs, actor reference and outcome. Redact passwords/tokens, bank details, guest documents and full request bodies. A support bundle contains versions, redacted logs and synthetic reproduction steps.

Run scheduled jobs through a native JCB-authored task/console integration proved on the deployment. Lazy browser activity is insufficient for nightly expiry, backups or reports. Workers need leases, bounded execution, metrics and safe retry. Protect maintenance/diagnostic routes with explicit authority.

## 9. Integration and dependency maintenance

Review supported Joomla/JCB/PHP versions and dependency advisories regularly. Changes first enter a branch, rebuild through JCB, run the affected tests, and deploy to staging. A dependency update is not a reason to manually patch generated production code without bringing the fix back to source.

Keep one accountable support owner for hosting/backups and one for business configuration. Document contacts, service hours, incident severity, recovery actions and change approval. Training includes recording a correction, recovering an unsent draft, reconciling cash, reviewing a held lot and recognising an unconfirmed booking.
