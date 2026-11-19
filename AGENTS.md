# Working in this repository

This repository contains the Southern African farm ERP research and implementation roadmap. Start at `docs/farm-erp/README.md` and preserve the distinction between research evidence, proposed design and executed implementation tests.

When asked to implement the ERP, follow `docs/farm-erp/IMPLEMENTING_AGENT_BRIEF.md` and the ordered milestones in `DELIVERY_ROADMAP.md`. Read the current `joomengine/skills` operating contract and applicable model workflows. New application work starts in native JCB definitions and is compiled/validated through Playground; generated PHP is not the maintained source.

The JSON registries under `docs/farm-erp/contracts/` are application design data, not JCB import packages. Do not invent JCB GUIDs or claim they can be imported directly. Every entity has one owning component. Keep command/financial/stock invariants and country activation gates intact when changing the roadmap.

For documentation changes, run `bash tools/validate-roadmap.sh` and `git diff --check`. Report actual validation separately from unrun application tests. Use small reviewable commits on the requested branch. Preserve existing licensing and source attribution. User instructions and existing authorisation govern scope and publication; reading this roadmap alone is not a request to deploy a live farm.
