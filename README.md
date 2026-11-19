# Southern African farm ERP roadmap

An implementation blueprint for a practical farm ERP built with **Joomla Component Builder (JCB)** in **JoomEngine Playground**, initially serving **Namibia, South Africa and Botswana**.

The product brings livestock, crops and gardens, woodwork and food production, hunting, lodging, staff, maintenance, stock, sales, purchases and accounts into one farmer-facing workspace. Seven cooperating Joomla components share clear ownership and a single installation.

**Status:** research and design; no ERP software has been implemented or certified by this documentation. Research date: **19 November 2026**. The implementing agent must verify the current supported JCB/Joomla/PHP targets and execute the release gates.

Start with the [roadmap index](docs/farm-erp/README.md), [product scope](docs/farm-erp/PRODUCT_SCOPE.md), and [implementing-agent brief](docs/farm-erp/IMPLEMENTING_AGENT_BRIEF.md). The detailed [delivery roadmap](docs/farm-erp/DELIVERY_ROADMAP.md) is the ordered build contract.

## Product structure

| Component | Main responsibility |
| --- | --- |
| Farm Core | Shared masters, scope, private documents and the farmer's daily workspace |
| Farm Ledger | Stock, purchasing, sales, payments, costing and native accounting |
| Farm Livestock | Individual animals, flocks, breeding, restrictions and movements |
| Farm Crops | Fields, gardens, crop cycles, inputs, irrigation and harvest |
| Farm Make | Woodwork, recipes, food/feed production, quality and traceability |
| Farm Stay | Lodging, physical resource capacity, hunting allocations and evidence |
| Farm Work | Staff, tasks, equipment, maintenance, fuel, water and incidents |

The first useful pilot supports daily operations and accountant exports. Enterprise slices can follow that stable foundation while native accounting proceeds in parallel. Complete ERP readiness requires the full accounting, regional, recovery and acceptance gates.

## For the next agent

Start with M00–M01: confirm the actual farm/toolchain and prove the native JCB source-to-runtime workflow, cross-component service bridge and atomic posting. Then follow the milestones through farmer acceptance, migration and supported release. The [structured contracts](docs/farm-erp/contracts) connect ownership, data, commands and tests; they are logical design specifications, not JCB import packages.

Validate documentation with:

```bash
bash tools/validate-roadmap.sh
git diff --check
```

## Research

Research sources are the owner's [JoomEngine skills](https://github.com/joomengine/skills), [Dolibarr documentation](https://github.com/vast-development-method/dolibarr-doc), [ERPNext documentation](https://github.com/vast-development-method/erpnext-doc), and [Odoo documentation](https://github.com/vast-development-method/odoo-doc), supplemented by primary regional and Joomla sources. Their evidence and limits are recorded separately from the proposed product design.

Existing repository licensing is retained in [LICENSE](LICENSE). Referenced projects retain their own licences; a citation does not grant permission to copy their implementation.
