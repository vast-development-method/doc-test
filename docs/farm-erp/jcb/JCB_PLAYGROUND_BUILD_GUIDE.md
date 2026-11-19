# JCB and Playground implementation guide

**Purpose:** a build procedure for the Southern African farm ERP, using Joomla Component Builder (JCB) as the maintained source and compiler. This document specifies work for the implementation agent. It does not claim that an ERP has already been authored, compiled, installed or tested.

**Research date:** 19 November 2026. The complete `joomengine/skills` checkout inspected for this guide is `b3f79efe7e83f40aa2a5236844277dd9b67eb60e`. JCB's `6.x` branch resolved to `037752c7e6599aa4cec900138dfb61af7ee4ba8f`. Playground's Git head resolved to `c168f7c2d3b79c8b291713b57a608b1f8d0ee714`; that is a repository observation, not a statement about the currently deployed Playground or a saved workspace. Resolve compatible production releases again when implementation starts. [JCB-01] [JCB-02]

## 1. Authoring contract

Use connected JCB definitions from the first application record. Maintain Fields, Admin Views, component attachments, Site/Custom Admin Views, Dynamic Gets, Templates, Layouts, Powers, plugin definitions and assets in their native JCB models. Generated PHP, XML, SQL and installation ZIPs are outputs. Lasting corrections go back into those models and are recompiled. Do not hand-code a component and then Extrude it to create the appearance of JCB authorship; Extrusion is reserved for genuinely pre-existing migration material. [JCB-01] [JCB-03]

The seven planned component roots are `com_farmcore`, `com_farmledger`, `com_farmlivestock`, `com_farmcrops`, `com_farmmake`, `com_farmstay` and `com_farmwork`. Their detailed responsibilities belong in the architecture and domain specifications. For JCB purposes, each is a separately compiled root in a connected source graph. Do not attach another owner's Admin View simply to gain access to its records: doing so can generate a competing table/model implementation. Preserve a single component owner for each application table and transaction. Cross-component integration is a required proof exercise in section 9.

JCB's native facilities should do ordinary CRUD, selection, queries, presentation composition and source transport. Additional domain services are justified for posting money and stock, booking resources, immutable animal events, recipe consumption, scope enforcement and other explicitly specified business invariants. Keep those services small, cohesive and callable through every enabled entry path. Replacing routine generated functionality with a second application framework would make the build harder to reproduce. [JCB-03] [JCB-04]

### Four representations to keep separate

| Representation | What belongs there | Acceptance evidence |
| --- | --- | --- |
| Definition repositories | Portable JCB graph, model indexes, project Powers and assets | Exact commits, identities, dependency resolution and source review |
| JCB authoring database | Imported or GUI-authored records actually used for compilation | Save/reopen and persisted-value comparison |
| Compiler artifacts | Component/plugin/module ZIPs and generated files | Retained bytes, SHA-256, manifest/SQL/PHP inspection |
| Installed application | Real forms, actions, routes, database rows and user experience | Authorized and denied operations, invariants, errors and upgrade tests |

A pass in one row does not certify another. A whole Playground archive is a further artifact containing editable site state; it is not interchangeable with a source repository or extension installer. [JCB-05]

## 2. Reading and evidence sequence

Keep the complete skills checkout together; individual entrypoints depend on shared contracts and references. Before creating the first record, read the root `AGENTS.md`, `SKILL.md`, version policy, request-to-extension workflow, Packages entrypoint and Playground guide. Then load the relevant smaller workflow for each slice. [JCB-01] [JCB-03] [JCB-06]

| Implementation concern | Required skills source |
| --- | --- |
| Stored entity, field type, concrete Field and component link | `packages/models/admin-views.md`, `packages/models/fields-and-relationships.md`, exact `packages/reference/*.json` |
| Portable keys and managed selectors | `packages/workflows/application-identities.md`, `modal-relationships.md` |
| Separate-table repeated rows | `packages/workflows/normalized-subforms.md` |
| Page queries and rendering | `packages/workflows/dynamic-get.md`, `packages/models/presentation-and-queries.md` |
| Domain services and DI | `super-powers/workflows/customize-extension.md`, `super-powers/settings-reference.md` |
| Generated API | `packages/models/api-selection.md` |
| Importing business data | `packages/workflows/imports.md`, `immediate-import.md` or `staged-import.md` |
| Files, photographs and documents | `packages/workflows/media-files.md` |
| Seed/reference data and migrations | `packages/workflows/initial-data.md`, `packages/models/component.md` |
| Export and independent reconstruction | `packages/workflows/author-in-playground.md`, `workflows/delivery.md` |

Use the installed target's implementation when its controls or behavior differ from the guide. Source citations are historical evidence; they do not require a production build to install an old prerelease. Use the latest compatible production JCB at the start of a build and retain that toolchain through its verification. Refresh it deliberately for the next build or upgrade. [JCB-02]

## 3. Bootstrap an isolated authoring workspace

1. Open [JCB setup](https://playground.joomengine.org/?deploy=jcb&start=0). Inspect the current Joomla, JCB and PHP selectors and published version catalogue. Select the compatible stable releases for the agreed target. A recipe labelled latest is insufficient evidence of the version actually installed.
2. Create a distinctly named ERP authoring workspace. Preserve an existing workspace before replacing it. Keep the owner tab open; a second ordinary tab can share the same storage and is not an independent restore test.
3. Wait for Joomla and JCB provisioning to complete. Record the displayed versions, browser, resolved PHP patch/integer width when accessible, selected package provenance, and deployed Playground `sourceCommit` when available. Record unavailable information honestly.
4. Allocate one controller for that live workspace. Other agents can research, author independent source branches and review files, but must not concurrently save, import, compile or install into the same runtime.
5. Complete one mutation and inspect its result before the next. After a timeout, inspect the existing operation and resulting state before retrying. A browser wait expiring neither cancels PHP nor rolls back a completed database mutation.
6. Use supported browser controls and permitted automation APIs. Do not assume a public `window.playground` object or invent remote access to the private browser instance.
7. Save the initial environment receipt and obtain a retained external backup once there is useful source state. The current Save operation stores a deployment recipe; live files and database persist automatically. Neither is a substitute for Download → Complete site. Check deployed behavior because saved older workspaces can differ. [JCB-06] [JCB-07]

The supplied task requests a roadmap, so this research did not launch or mutate a Playground. The steps above are implementation work still to execute.

### Runtime limits that affect the plan

Playground is an authoring and integration environment. Its documented WASM runtime does not provide arbitrary host executables, native worker processes, arbitrary sockets or a production mail server. Test native cron/CLI workers, mail delivery, scheduled outbox execution, concurrent database contention, printer integration and hosting recovery on the eventual compatible native staging server. A successful in-browser demonstration is useful evidence, but does not prove these host facilities. [JCB-06] [JCB-08]

## 4. Resolve reusable source before making new definitions

Search the complete relevant feature graphs, not only class names. The Skills reference catalogue identifies useful Demo and Service Directory patterns for GUID selectors, smart subforms, files/images, Dynamic Gets, composed presentation and importers. They are candidates to inspect and adapt, not a prebuilt farm ERP. [JCB-09]

For each candidate, record the canonical repository, actual transport, branch, exact commit, typed identities, dependencies, licence and reuse decision. Preserve an unchanged entity's identity. A distinct adaptation gets a new model-appropriate identity, with all affected references remapped coherently. An intentional same-identity override is a separate maintenance decision requiring explicit resolution order. [JCB-10]

Configure only required repository connections in JCB. Content targets are Super Powers `1`, Joomla Powers `2`, Field Types `3`, Packages `4`, Snippets `5`, with a separate repository catalogue `6`. Provider and content target are different fields. Read branch selects acquisition source; write branch selects an export destination. Inspect effective precedence and fallback sources. At the inspected baseline, archived rows can still qualify and duplicate owner/repository keys can collapse; display labels do not establish selection. [JCB-06] [JCB-11]

| Operation | Use and expected observation |
| --- | --- |
| Init | Acquire absent selected definitions; an already-local record has not thereby been refreshed |
| Pull | Deliberately import/replace selected records from the intended source; inspect the resulting differences |
| JCB entity Reset | Refresh local definitions through the model's configured lookup; preserve local changes first |
| JCB Push | Export source to eligible writable destinations; inspect every effective destination before use |
| Playground Reset | Replace/delete runtime state; unrelated to refreshing an entity definition |

For new Power identities, use the current catalogue and repository-aware GUID tools in the skills distribution. Concrete package Fields, Field Types and runtime rows have different identities and collision domains. Do not copy example GUIDs into new production definitions. Do not access the explicitly prohibited `git.vdm.dev` host; follow the skills' maintained mirror discovery and provenance procedure when needed. [JCB-01] [JCB-10]

## 5. Model the native graph and application keys

### 5.1 Every persisted entity has an owner and an Admin View

Create a real Admin View for every separately persisted application table, even when farmers only edit its rows through a parent screen. Examples include animal events, invoice lines, stock entry lines, production inputs, booking resource allocations, labour entries and attachment links. Attach each view to its owning component with the appropriate fields. Hide conventional child menus when useful; do not omit the underlying model. A JSON subform control alone neither creates a child table nor supplies its lifecycle. [JCB-12]

Set concrete Field datatype, length, scale, nullability, default, index and storage intentionally. Field Type defaults are suggestions, not the ERP schema. Monetary precision, quantities, date/time policy and units come from the domain data contracts. Inspect emitted SQL to verify that the chosen decimal and index definitions survive compilation. Do not infer a physical UNIQUE constraint from a helper named `DatabaseUniqueGuid`. [JCB-13]

Reserve names before creating roots: component `farmlivestock`, item `animal`, list `animals`, with distinct names for its standard dashboard. A component code equal to a CRUD list code can produce a generated dashboard/list collision. Visible product wording need not equal an internal code name. [JCB-14]

### 5.2 Four identities for one animal

| Identity | Example meaning | Rule |
| --- | --- | --- |
| Definition GUID | The Animal Admin View or a tag-number Field in JCB | Stable source identity for that definition |
| Application GUID | One actual cow or sheep record | Immutable portable row identity |
| Numeric `id` | Local Joomla row/controller/asset identity | Retained, resolved locally, never assumed equal across installations |
| Business key | Official animal tag, herd number or farmer's display code | Separately scoped uniqueness and change policy |

New portable relationships use canonical application GUID strings while retaining Joomla numeric primary keys. Parent and child must have matching types/collations; each entity has an actual unique GUID index, and each relationship is indexed. Keep Joomla user IDs, quantities, money and unrelated integers in their appropriate types. GUIDs do not implement replication, offline conflict resolution or authorization. [JCB-13]

Validate missing, malformed, nil and duplicate identities at the correct server boundary. Preserve identity on edit; Save as Copy allocates fresh parent/child identities according to an explicit copy policy. At the current researched compiler baseline, generated key normalization can clear a supplied GUID on API creation before later save hooks. Therefore authorized import-preservation rules must inspect and validate the original input at a suitable maintained boundary; an after-normalization `$data['guid']` cannot prove what the caller submitted. [JCB-13]

### 5.3 Selectors and repeated editors

For a GUID selector, adapt the target table, display column, `sql_title_key`, selection route, linked New/Edit routes and controller GUID resolution together. Reuse the complete ModalSelect graph and `formControllerEdit` companion where appropriate. Selecting a record and displaying its title do not establish that Edit resolves the same row or applies its access rules. Preserve a submitted choice after failed validation; route defaults only fill a fresh permitted form. [JCB-15]

Use ordinary normalized `Data.Subform` patterns for complete editing of low-risk owned collections when their semantics fit. The inspected recipe uses expert storage `store=6`, non-database attachment of the parent control, and both `on_get_model_field` and `on_save_model_field`; the child Admin View owns storage. Its save operation treats the submitted collection as complete: omitted children can be purged, and malformed non-array values can become an empty collection. Never expose this behavior as an unspecified partial API update. [JCB-12]

For immutable or balance-affecting collections, use the explicit command/approval lifecycle in the ERP design. A posted journal, stock movement or completed animal event must not be silently rewritten through a generic child list, parent subform, batch operation, import or generated API. Ordinary draft editing can use native forms; finalization and reversal must enter the same domain service and enforce the same invariants.

## 6. Build the first complete slice

Start with a small functional system before generating hundreds of views. The first slice should establish the actual build and dependency path:

1. Create Farm Core's legal-entity/farm context, membership/scope and essential managed masters as native Fields and Admin Views. Establish the one-legal-entity-per-installation baseline and multiple farm/cost-centre associations.
2. Create Farm Livestock's Animal and Animal Event views. Use immutable GUIDs for row relationships and an actual herd/tag uniqueness rule. Keep medically meaningful event validation configurable; do not invent treatment dosages.
3. Create the relevant component associations, field ordering, tabs, titles, search and filters. Reopen each association. An unlinked record does not compile merely because it exists in JCB.
4. Add the smallest farmer-facing Site View: animal search, animal detail and a safe event entry action. Reuse generated/admin management for setup; use task-oriented farmer pages for daily work.
5. Define a Dynamic Get for each ordinary display query, selecting the identifiers and relation keys required by the consumer. Add explicit farm/permission restrictions, stable ordering and pagination.
6. Build presentation from a focused Site View body, meaningful Templates and reusable Layouts. Define each renderer's input shape and empty states; escape output in context. Wrap user-facing text using supported Joomla translation calls.
7. Add an owned Power for the event business rule and a thin real caller in the relevant JCB controller/model hook. Do not assume the existence of a service file causes it to run.
8. Compile, retain and inspect the ZIP, then install it in a clean Joomla consumer with Core first. Create an animal; create an event; reopen both; filter by farm; exercise a user without the relevant farm scope; attempt a stale or repeated submission.
9. Export both source roots and their actual dependencies, reconstruct them in a clean JCB instance, and rebuild the same slice. Complete the two-component service/atomicity proof before extending it to financial and stock effects. [JCB-03] [JCB-04] [JCB-05] [JCB-16]

The farm context must be enforced at the server action and query boundary. Hiding menus, filtering an HTML selector, or supplying `farm_guid` from the browser is not an authorization decision. Verify API/import/AJAX paths as deliberately as ordinary forms.

## 7. Queries, presentation and assets

Use JCB Dynamic Gets for routine data retrieval. Select a main single/list result under alias `a`, then define single-row joins and related collections according to real cardinality. Select explicit aliases and all keys needed by the generated related getters. Inspect the actual generated property names instead of guessing them from view titles. Apply farm ownership/access restrictions to related queries as well as the parent query. [JCB-16]

A farmer dashboard can combine outstanding tasks, animals needing attention, bookings and cash/stock summaries, but each contribution must respect installed optional modules and permissions. The Core dashboard must continue to load when a satellite is absent. Use measured query budgets and indexes; a paginated main list does not automatically paginate every related collection. Use scoped custom aggregation where the required calculation genuinely exceeds configured query behavior.

Keep markup out of domain services. Use the Template/Layout Custom View Script fields for preparation in their supported raw-PHP context, and Templates/Layouts for display. Keep the source readable; do not compress an entire application into a single Site View default field. [JCB-16] [JCB-17]

Reuse the complete Files/File Types, upload, display and image-crop feature for animal photos, invoices, permits and work records. Define business ownership, allowed file types, size limits, private/public access and retention. A text path or file input alone is not managed document storage. Verify direct file access and download authorization, not only a hidden button. Include all CSS/JavaScript and third-party asset dependencies in the actual package; assets available on the authoring site can mask missing consumer dependencies. [JCB-09] [JCB-18]

## 8. Domain services, Powers and DI

Joomla Powers map target-compatible Joomla classes; Super Powers define the application's reusable PHP classes/interfaces/traits. Use supported JPK/SPK references and dependency selections where those models apply. The import source for a Power is `settings.json` plus its raw declaration body in `code.power`; derived `code.php` alone is not the maintained definition. [JCB-04]

Choose placement through the Power's namespace template. For an administrator-owned `AnimalEvents` class, a supported template is `[[[NamespacePrefix]]]\Component\[[[ComponentNamespace]]]\Administrator\Service.AnimalEvents` (this is the plain namespace value; escape backslashes when representing it in JSON). The dotted suffix is significant to the compiler's folder algorithm. Inspect the compiled and installed path. Do not invent an `admin: true` or `placement: api` setting. [JCB-04]

Place needed namespace imports in enabled Class Header Code (`add_head=1`, `head`) without PHP opening tags. Keep class members in the body. Do not rely on a disabled header and body tokens to arrange imports; the Skills explicitly corrected that unsupported authoring pattern. Keep existing supported dependency-generated imports consistent and inspect aliases. [JCB-19]

Each nontrivial service has a real constructor, narrow dependencies, declared result/error contract and actual caller. Registration must happen through the owning factory/bootstrap. `use_selection`, `load_selection`, file presence and a provider class do not register DI services. Record which container owns the service, the driver supplied to it and its lifetime. A global Joomla container and a private Power factory container need not be identical. [JCB-04]

For transactional commands, authorize and validate before mutation, acquire the required locks/conditional version checks, persist the domain result and Ledger effects in the agreed single transaction, and enqueue external side effects in an outbox. Avoid network/mail calls inside that transaction. Do not place independent commit/rollback logic in reusable participants. These are ERP design requirements to implement and test, not automatic guarantees of JCB.

## 9. Mandatory two-component service and transaction proof

This is the principal technical gate before the seven-component design can be considered buildable.

### What the source actually provides

At JCB `037752c7`, the Joomla 6 component provider template registers normal Joomla component, MVC, category, dispatcher and router services. The component extension template has a boot method but does not expose a generic ERP service container or service getter. It is therefore incorrect to invent calls such as `bootComponent(...)->getService()` and present them as generated JCB capabilities. [JCB-20] [JCB-21]

The documented Admin View `php_model`/`php_controller` slots and their enable switches can add the necessary real model/controller methods. A viable first candidate is a thin owner model bridge obtained through Joomla's component/MVC factory and invoking the owner's cohesive Power services. Verify the exact Joomla target APIs and generated model class before implementation. The bridge is an adapter; domain algorithms stay in Powers. An alternative explicit external runtime class boundary needs the same namespace/ownership/loader proof and must not silently cause satellites to republish the owner's Power files. [JCB-04] [JCB-22]

### Proof procedure and pass criteria

1. Compile a Core owner service and a minimal Ledger caller as two real JCB roots. Install Core, then Ledger, on Joomla without JCB installed. Verify the caller in administrator, frontend and API contexts actually required by the project. Add a minimal Livestock caller before claiming the three-owner domain → Ledger → Core posting path is proved; the initial two-root bridge alone does not establish that full transaction.
2. Inspect both archives: the owner service has one installation/update/uninstall owner. No satellite installs a conflicting copy into the same global Power library path. Core can load without the satellite; a missing/incompatible Core dependency produces a clear preflight/runtime failure.
3. Demonstrate the selected bridge reaches a real owner factory. Do not claim arbitrary container access merely from `bootComponent()`. Verify actual generated class imports, loaded namespaces, request context and provider registration.
4. Supply one actual database driver instance to all participants. Record a test assertion of driver identity/connection use. A shared database name is insufficient: two connections do not share one transaction.
5. Start one outer unit of work in the command coordinator. The domain owner writes its tables through its service; Ledger writes Ledger-owned stock/financial tables through its service; Core appends any required audit/outbox rows through the same connection. No participant commits independently.
6. Keep Joomla Table/asset-tree mutations outside the command's transactional critical section unless the exact path has been proven safe. The Skills record a case where asset/table locking was reported to cause an implicit commit; its general applicability must be investigated, not presumed away. Master/draft CRUD can use ordinary Joomla models, while posting commands require a tested storage path. [JCB-12]
7. Force an exception after the domain write and again after the Ledger write. Verify that all transactional business/audit/outbox effects roll back together, identities remain coherent and no notification was sent.
8. Run the same command twice with the same idempotency key, then with a conflicting payload; verify the specified replay and conflict outcomes. Run independent native requests contending for the same stock, animal or booking resource; verify overselling/overbooking and lost-update prevention.
9. Upgrade one owner within the supported version range, reject an incompatible owner version, disable/remove the optional satellite, and verify Core and unrelated modules still operate. Block removal of a required owner while dependants or protected data remain.
10. Export the complete source, reacquire it in clean JCB, rebuild the participating components and repeat the representative tests. Keep the exact supported bridge, provider bootstrapping and required assets in the source. If a compiler extension is demonstrably necessary, author it in JCB, scope it narrowly and test its drift/repeatability; never patch generated output as the lasting implementation.

Until this gate passes, the roadmap's cross-component atomic commands are proposed architecture. Do not spread untested wiring across all modules and try to repair it at the end.

## 10. Generated APIs and command endpoints

Generated API exposure is configured on the component-to-Admin-View attachment. At the researched compiler revision, `add_api=0` is none, `1` is collection GET, `3` is item mode including GET/POST/PATCH/DELETE, and `2` is both. Item does not mean read-only. A separate JCB-authored webservices plugin must emit and register the actual route methods and be installed/enabled in the consumer. [JCB-23]

Direct inspection of the current `Resources.php` also confirmed that enabling an admin API discovers eligible custom-admin/site Dynamic Get resources. Site `public_access=1` can produce public read routes, and the future per-link Dynamic Get API filter was still commented out. Audit the complete emitted route list and serializers; reviewing only explicit admin attachments is insufficient. This is a current source observation, not an installed HTTP test. [JCB-24]

Keep generic CRUD disabled for posted journals, immutable movements and other entities that must enter commands. Where draft CRUD is exposed, enforce field allowlists, original-payload semantics, scope and revision checks. Define command endpoints for approve/post/reverse/reserve/complete operations in maintained JCB plugin/controller/service records and test real authentication/ACL/CSRF as appropriate. Never infer safe business behavior from the existence of a generated endpoint.

Run anonymous, restricted, authorized and cross-farm requests; inspect HTTP status, response body and actual persisted state. Test omitted versus explicit null/empty values, child replacement versus partial updates, malformed identities, unauthorized parent reassignment, stale revisions and direct DELETE attempts. Inspect route collisions and plugin enablement before diagnosing a missing route as a database error. [JCB-23]

## 11. Imports, reference data and migrations

Treat three operations separately: acquiring JCB source, importing business data, and seeding a fresh installer. The ERP needs all three but they have different input and lifecycle contracts. [JCB-25]

For farmer spreadsheet onboarding, reuse a complete immediate or queued importer feature: upload, mapping, preview, example download, validation, results and retry behavior. Derive the example headers and mapping choices from JCB Table metadata and the allowed import contract; do not maintain a second drifting column catalogue. Bind uploaded files to the authorized user/operation. Never accept an arbitrary server file path from a request. Verify the example-download → edit → upload → preview → apply journey. [JCB-25]

Small immediate imports can be synchronous when their resource bounds and error behavior are appropriate. Larger staged imports require a real supported processor, scheduling, progress, retry/concurrency control and message logs. A visible queue in Playground does not prove native cron/worker operation. Animal/stock/opening-balance imports must enter their owner's validation and posting rules; bypassing those through table upserts would invalidate the ERP ledgers.

For initial reference data, first compile/install the empty component, populate permitted reference records through application forms/import, then configure the Admin View's native Table-mode seed source and source map. Inspect the generated install SQL and verify a fresh consumer. Do not copy source-site `asset_id`, credentials, audit users or production customer records into a distributable installer. [JCB-26]

Table-mode source maps/live rows are not automatically preserved by Packages blueprint export. For a fully reconstructible source-only build, deliberately maintain supported Dump-mode seed SQL or a documented source-data reconstruction step; verify the exported/imported result. A complete-site archive can preserve the Table-mode authoring database but is a separate dependency. Fresh-install seed data is not an upgrade policy. [JCB-26]

Maintain versioned migration source, preconditions and recovery for installed data. JCB's historical schema comparison can depend on local authoring history; a fresh importer may not reconstruct that history. Verify retained update SQL across repeat builds and clean-source reconstruction. Test both upgrade and fresh installation. Do not claim database DDL rollback merely because DML is transactional. [JCB-14] [JCB-27]

## 12. Verification and source publication for every increment

For each useful slice, complete and record these distinct gates:

| Gate | Required result |
| --- | --- |
| Source/profile | Relevant native JSON/index/body checks pass, dependencies resolve, intentional shadows recorded |
| Authoring | Saved/reopened JCB records and links contain the intended definitions |
| Compilation | Actual root compiles for the target; generated SQL/XML/PHP/assets/routes inspected |
| Retention | Genuine installer downloaded outside browser storage, member list and SHA-256 retained |
| Clean installation | Installs on a compatible consumer with only declared runtime dependencies |
| Runtime | Normal, denied, malformed, stale, retry and relevant transaction cases meet the domain contract |
| Upgrade | Existing representative data survives the versioned upgrade and failure/recovery path |
| Source publication | Authorized source branches contain the complete graph and project-owned support models |
| Reconstruction | Fresh JCB acquisition builds a functioning consumer without hidden authoring-state dependencies |
| Complete-site restoration | Exact retained archive opens independently and supports saved data plus representative rebuild |

The skills' tools validate bounded structural profiles, not the compiler or application. Invoke them from the complete skills checkout using their documented actual repository/catalogue arguments. `bash tools/check.sh` validates the skills distribution itself; it is not an ERP test command. Keep unresolved Power references, deferred transforms and skipped PHP checks visible. [JCB-28]

Before JCB Push, inspect **every** eligible writable repository connection, write branch, effective fallback and credential. Selecting one component or read source does not restrict Push to one destination. Export can make several remote writes and partially fail. Reconcile the remote before/after diff before retrying. Package Push does not automatically publish every project-owned Power, Field Type or Snippet; export each through its own model contract. [JCB-11] [JCB-29]

Download compiler artifacts before installation actions that may remove temporary ZIPs. Prepare download capture before triggering once; verify the file actually exists and is retained. If the embedded link fails, the skills document Code's Download file fallback using the observed actual path. Do not guess an artifact name or claim a completed transfer from a toast. [JCB-06]

When persistence fails, retain the live owner and attempt a complete live export before reset, stop, reload or cleanup. A low browser storage estimate does not prove that a write cannot fail. External retention and an independent Upload test are necessary before discarding the only live copy. [JCB-30]

### Minimum slice receipt

Record the feature/task identifiers; source commits and root identities; actual environment versions; reusable-source provenance; changed definitions; table/index migration; compiled artifact names/hashes; authorized/denied test identities; expected/observed outcomes; transaction/replay results where relevant; publication and read-back commits; reconstruction and restore outcomes; and the next unresolved gate. Use synthetic data. Do not put credentials, private personal data, live site archives or production exports in this public documentation repository.

## 13. Parallel-agent operating model

Parallelize requirements research, separate domain definitions, Power code review, test design, source validation and documentation. Give every entity or natural key one owner and keep an identity ledger to prevent independent adaptations from clobbering each other. Integrate coherent changes through reviewed commits.

Serialize mutations in a shared Playground. One build controller acquires a reviewed increment, verifies it, compiles, installs and records the evidence. Other agents review resulting artifacts or work against separate isolated workspaces. Never let two agents click Save/Push/Compile into the same runtime. Source branches do not prevent races in a shared JCB database. [JCB-06]

When guidance fails, retain a minimal sanitized reproduction and use the Skills feedback process within the project's authorization. Distinguish a skills gap, a compiler defect, an application bug, a browser transfer failure and a native deployment limitation. Correct the authoritative source and regenerate; do not normalize an undocumented workaround into a claim that every path is supported. [JCB-01]

## Sources

[JCB-01]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/AGENTS.md
[JCB-02]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/standards/version-policy.md
[JCB-03]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/workflows/request-to-extension.md
[JCB-04]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/super-powers/workflows/customize-extension.md
[JCB-05]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/workflows/delivery.md
[JCB-06]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/testing/playground/README.md
[JCB-07]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/testing/playground/configuration.md
[JCB-08]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/workflows/mcp.md
[JCB-09]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/examples/reference-patterns.md
[JCB-10]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/standards/entity-reuse.md
[JCB-11]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/standards/repository-operations.md
[JCB-12]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/normalized-subforms.md
[JCB-13]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/application-identities.md
[JCB-14]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/models/component.md
[JCB-15]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/modal-relationships.md
[JCB-16]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/dynamic-get.md
[JCB-17]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/models/presentation-and-queries.md
[JCB-18]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/media-files.md
[JCB-19]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/super-powers/settings-reference.md
[JCB-20]: https://github.com/joomengine/Joomla-Component-Builder/blob/037752c7e6599aa4cec900138dfb61af7ee4ba8f/admin/compiler/joomla_6/ADMIN_PROVIDER.php
[JCB-21]: https://github.com/joomengine/Joomla-Component-Builder/blob/037752c7e6599aa4cec900138dfb61af7ee4ba8f/admin/compiler/joomla_6/ADMIN_EXTENSION_COMPONENT.php
[JCB-22]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/models/admin-views.md
[JCB-23]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/models/api-selection.md
[JCB-24]: https://github.com/joomengine/Joomla-Component-Builder/blob/037752c7e6599aa4cec900138dfb61af7ee4ba8f/libraries/vendor_jcb/VDM.Joomla/src/Componentbuilder/Compiler/Architecture/Api/Resources.php
[JCB-25]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/imports.md
[JCB-26]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/initial-data.md
[JCB-27]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/compiler-plugins.md
[JCB-28]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/tools/README.md
[JCB-29]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/packages/workflows/author-in-playground.md
[JCB-30]: https://github.com/joomengine/skills/blob/b3f79efe7e83f40aa2a5236844277dd9b67eb60e/testing/playground/storage-recovery.md
