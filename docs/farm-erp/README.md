# Roadmap index

This is a design and delivery contract for a new JCB-native application. Proposed architecture and acceptance targets are requirements, not claims about existing JCB features or completed ERP behaviour.

## Reading order

| Audience / task | Read |
| --- | --- |
| Farmer and product owner | [Product scope](PRODUCT_SCOPE.md), [farmer experience](FARMER_EXPERIENCE.md), [farm scenarios](research/FARM_OPERATING_SCENARIOS.md) |
| Lead implementing agent | [Agent brief](IMPLEMENTING_AGENT_BRIEF.md), [roadmap](DELIVERY_ROADMAP.md), [decisions](DECISIONS_AND_OPEN_QUESTIONS.md) |
| JCB author | [Build guide](jcb/JCB_PLAYGROUND_BUILD_GUIDE.md), [capability matrix](jcb/JCB_CAPABILITY_AND_RISK_MATRIX.md) |
| Architect | [Architecture](ARCHITECTURE.md), [domain model](DOMAIN_MODEL.md), [contracts](INTEGRATION_CONTRACTS.md) |
| Accountant and stock controller | [Finance, stock and costing](FINANCE_STOCK_AND_COSTING.md), [regional requirements](research/SOUTHERN_AFRICA_REQUIREMENTS.md) |
| Test / deployment owner | [Acceptance plan](ACCEPTANCE_AND_TEST_PLAN.md), [security, operations and migration](SECURITY_OPERATIONS_AND_MIGRATION.md) |
| Research reviewer | [ERP comparison](research/ERP_REFERENCE_COMPARISON.md), [workflow patterns](research/ERP_WORKFLOW_PATTERNS.md), [source register](sources/SOURCE_REGISTER.md), [research progress](RESEARCH_PROGRESS.md) |

## Structured specifications

The JSON files in [contracts](contracts) are **design registries**, not importable JCB package records and not implemented APIs. They provide stable identifiers for component ownership, entities, milestones and acceptance cases. The JCB author maps them to the current native model contracts; inventing JCB GUIDs or serialisation from these files is prohibited.

Run `bash tools/validate-roadmap.sh` from the repository root to check their consistency and local document links. This validates documentation; it does not compile or exercise an ERP.

## Evidence vocabulary

- **Source inspected:** supported by the exact cited source revision; does not imply a runtime test here.
- **Reference observation:** the supplied blueprint reports behaviour; its qualification/provenance limits still apply.
- **Product decision:** this roadmap chooses a design or constraint for the new product.
- **Proof gate:** implementation must demonstrate the behaviour before dependent work proceeds.
- **Country sign-off:** an accountable local reviewer confirms rules and effective dates before the affected regulated feature is activated.

The minimum pilot and the complete intended ERP are separate release gates. A pilot that exports to an accountant is useful, but it is not represented as a finished accounting/payroll product.
