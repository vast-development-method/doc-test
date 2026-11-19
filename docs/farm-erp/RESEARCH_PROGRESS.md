# Southern African farm ERP — research progress

Started: 19 November 2026.

## Objective

Specify a practical, stable farm ERP for Namibia, South Africa and Botswana, built as cooperating Joomla components through Joomla Component Builder (JCB) in JoomEngine Playground. Produce an implementation roadmap another agent can follow from initial definitions through installation, testing, migration and operation.

## Work in progress

- Inspect the JCB and Playground skills and establish the supported source-of-truth and build workflow.
- Compare the supplied Dolibarr, ERPNext and Odoo documentation with pinned source references.
- Research local livestock, crops, manufacturing, hunting, lodging, workforce, finance and infrastructure requirements using primary sources.
- Define component ownership, shared contracts, data models, accounting and stock invariants, security, usability and deployment constraints.
- Convert the design into phased build instructions, acceptance scenarios and release gates.
- Review consistency, validate links and publish research increments on this branch.

This branch initially contains a research scaffold. Findings will be added as successive commits. No production ERP implementation or validated legal compliance is claimed.

## Sources supplied by the owner

- https://github.com/joomengine/skills
- https://github.com/vast-development-method/dolibarr-doc
- https://github.com/vast-development-method/erpnext-doc
- https://github.com/vast-development-method/odoo-doc

## Working boundaries

The product targets three initial country packs and the NAD, ZAR and BWP currencies. The architecture will distinguish a usable farm pilot from later full ERP capabilities. Regulatory rules remain dated, configurable and subject to country-specific professional verification before deployment.
