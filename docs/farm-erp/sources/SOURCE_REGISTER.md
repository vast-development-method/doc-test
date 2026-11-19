# Research source register and qualification

Research date: **19 November 2026**. Source snapshots below support the research; they do not pin the runtime for a future build. The implementing agent must resolve current compatible stable releases and inspect changed behaviour at execution time.

## Repository snapshots

| Source | Inspected revision | Use / evidence boundary |
| --- | --- | --- |
| [JoomEngine Skills](https://github.com/joomengine/skills/tree/b3f79efe7e83f40aa2a5236844277dd9b67eb60e) | `b3f79efe7e83f40aa2a5236844277dd9b67eb60e` | Operating policy, native model/workflow contracts, bounded implementation evidence and known gaps |
| [JCB 6.x source](https://github.com/joomengine/Joomla-Component-Builder/tree/037752c7e6599aa4cec900138dfb61af7ee4ba8f) | `037752c7e6599aa4cec900138dfb61af7ee4ba8f` | Targeted provider/extension/compiler/API inspection; not a farm ERP runtime test |
| [JoomEngine Playground source](https://github.com/joomengine/playground/tree/c168f7c2d3b79c8b291713b57a608b1f8d0ee714) | `c168f7c2d3b79c8b291713b57a608b1f8d0ee714` | Repository observation and source/workflow reference; not a verified deployed browser build |
| [Dolibarr reference](https://github.com/vast-development-method/dolibarr-doc/tree/640ff739840dca25015a704300b2e78ee7269656) | `640ff739840dca25015a704300b2e78ee7269656` | Owner-supplied independent blueprint; source contracts and bounded recorded observations |
| [ERPNext reference](https://github.com/vast-development-method/erpnext-doc/tree/61a1196824f8df82127627d475599266244b71ce) | `61a1196824f8df82127627d475599266244b71ce` | Independent detailed specification and scoped runtime receipts; fixture profile does not prove every module |
| [Odoo reference](https://github.com/vast-development-method/odoo-doc/tree/81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0) | `81a0c3fc2eb11fb7194a72e7bb537d395b9e46a0` | Independent domain rebuild specification; stale coverage report identified and not treated as current tree truth |

## Detailed evidence locations

- [JCB guide source map](../jcb/JCB_PLAYGROUND_BUILD_GUIDE.md#sources): exact skill/model/compiler files underlying each instruction.
- [JCB risk matrix source map](../jcb/JCB_CAPABILITY_AND_RISK_MATRIX.md#source-map): verified baseline versus proof still required.
- [ERP comparison source register](../research/ERP_REFERENCE_COMPARISON.md#source-register): product-specific evidence and licences.
- [ERP workflow pinned sources](../research/ERP_WORKFLOW_PATTERNS.md#pinned-sources): behavioural rules, worked transactions and qualified failure observations.
- [Regional source register](../research/SOUTHERN_AFRICA_REQUIREMENTS.md#13-source-register): 40 primary institutional sources with subject and retrieval limitations.

Do not duplicate the detailed source registers into unsynchronised lists. Claims in the research chapters cite their local evidence identifiers; product-design requirements are explicitly identified as our choices.

## Supplementary primary Joomla sources

| Source | Inspected use | Limits |
| --- | --- | --- |
| [Extensions and child containers](https://manual.joomla.org/docs/general-concepts/dependency-injection/extension-child-containers/) | Joomla extension DI and service-provider conventions | Does not prove arbitrary JCB-generated service getters exist |
| [Joomla ACL](https://manual.joomla.org/docs/general-concepts/acl/) | Viewing access versus action permissions | Farm record scope and query enforcement remain application duties |
| [ACL permissions](https://manual.joomla.org/docs/general-concepts/acl/acl-permissions/) | Explicit authorisation in extension code | Group IDs are installation-specific |
| [Technical requirements](https://manual.joomla.org/docs/get-started/technical-requirements/) | Supported target selection | Live page; verify at build, and distinguish supported from absolute minimum |
| [Documentation versions](https://manual.joomla.org/versions/) | Avoid confusing upcoming/current/legacy manuals | Release selectors do not prove an installed site's version |

## Research method and coverage

Three parallel investigations covered (1) native JCB/Playground authoring and compiler risks, (2) the supplied ERP specifications and transaction patterns, and (3) regional operating/legal/configuration requirements. Root integration defined the architecture, ownership, logical schema, contracts, rollout, UX and operations. Subsequent cross-reviews corrected shared-service assumptions, nullable stock-key races, optional cross-component references, overlapping holds/restrictions and release sequencing.

Coverage is deliberate and bounded: relevant English source chapters, model contracts, implementation points, recorded observations and official regional sources were inspected. We do not claim every file/translation in the reference repositories was read, every external page was current, or any of the reference applications was executed in this task.

Government pages sometimes failed direct retrieval but had official indexed content; these cases are named in the regional register. Conflicting NamRA/BURS summaries are preserved as evidence-quality findings. Current Namibian privacy enactment was not conclusively established. None becomes an invented production seed value.

## Licensing and reuse

The existing `doc-test` licence remains unchanged. The supplied ERP documentation licences are recorded in the comparison, but upstream product code, commercial extensions, images, names and third-party assets retain their own terms. This roadmap links and paraphrases evidence; future implementation must record the exact licence/provenance of every reused entity/Power/asset and preserve required notices.

Research source hashes provide reproducibility. Runtime dependency updates remain deliberate: resolve latest supported versions for a build, retain the resulting receipt, and retest affected behaviour when versions change.
