#!/usr/bin/env bash
# Validate documentation/registry consistency. This is not a JCB or ERP test suite.
# Dependencies: Bash 4+, jq 1.6+, ripgrep, awk, sed, sort, realpath, mktemp.
# Markdown coverage: inline file destinations, reference definitions, explicit
# reference uses and the citation-ID shorthand used by this repository. Fenced
# and ordinary inline code are excluded. Heading anchors and network URLs are
# deliberately not validated; this is not a full CommonMark parser.
set -euo pipefail

allow_incomplete=0
case "${1-}" in
	'') ;;
	--allow-incomplete) allow_incomplete=1 ;;
	-h|--help)
		cat <<'HELP'
Usage: bash tools/validate-roadmap.sh [--allow-incomplete]

Checks JSON syntax; unique identities; component ownership and dependency DAG;
entity fields, common contracts, declared indexes and relationships; exact
DOMAIN_MODEL table coverage; case/milestone/command references; status/evidence
consistency; local source and Markdown file destinations; local JSON pointers;
and unresolved merge markers.

The default requires all seven contract files. --allow-incomplete is only for a
concurrent authoring checkpoint and explicitly reports omitted checks. It is not
a final validation pass.

Executed outcomes (passed/failed/completed/implemented) require evidence_files
and observed_result on that record. Files must resolve relative to its registry;
this only checks that evidence is supplied, not that its claims are true.

Not covered: installed JCB behavior, ERP runtime tests, full JSON Schema
validation, duplicate JSON object keys, Markdown heading anchors, network URLs,
or semantic proof that prose/evidence is correct.
HELP
		exit 0 ;;
	*) printf 'ERROR: unknown argument: %s\n' "$1" >&2; exit 2 ;;
esac
if (( $# > 1 )); then
	printf 'ERROR: unexpected additional arguments\n' >&2
	exit 2
fi
for dependency in jq rg awk sed sort realpath mktemp; do
	command -v "$dependency" >/dev/null || { printf 'ERROR: missing dependency: %s\n' "$dependency" >&2; exit 2; }
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd -- "$script_dir/.." && pwd)
contracts_dir="$repo_root/docs/farm-erp/contracts"
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
failures=0
skips=0
local_links=0
network_links=0
fragments_skipped=0
json_pointers=0
printf '{}\n' > "$work_dir/absent.json"

fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }
pass() { printf 'PASS: %s\n' "$*"; }
skip() { printf 'SKIP: %s\n' "$*"; skips=$((skips + 1)); }

required=(components.json domain-entities.json acceptance-cases.json roadmap.json commands.json command-envelope.schema.json country-pack.schema.json)
for name in "${required[@]}"; do
	if [[ ! -f "$contracts_dir/$name" ]]; then
		if (( allow_incomplete )); then skip "contract not written yet: $name"; else fail "required contract missing: $name"; fi
	fi
done
mapfile -t json_files < <(rg --files "$contracts_dir" -g '*.json' | sort)
if (( ${#json_files[@]} == 0 )); then fail 'no contract JSON files found'; fi
syntax_failures=0
for file in "${json_files[@]}"; do
	if ! jq empty "$file"; then fail "invalid JSON: ${file#"$repo_root/"}"; syntax_failures=$((syntax_failures + 1)); fi
done
if (( syntax_failures )); then exit 1; fi
pass "parsed ${#json_files[@]} contract JSON files"

# Missing optional-at-this-checkpoint documents become empty objects; checks
# requiring them are guarded below, while final mode still reports them missing.
registry_path() {
	if [[ -f "$contracts_dir/$1" ]]; then printf '%s\n' "$contracts_dir/$1"; else printf '%s\n' "$work_dir/absent.json"; fi
}
components_file=$(registry_path components.json)
entities_file=$(registry_path domain-entities.json)
cases_file=$(registry_path acceptance-cases.json)
roadmap_file=$(registry_path roadmap.json)
commands_file=$(registry_path commands.json)

if ! jq -nr \
	--slurpfile component_doc "$components_file" \
	--slurpfile entity_doc "$entities_file" \
	--slurpfile case_doc "$cases_file" \
	--slurpfile roadmap_doc "$roadmap_file" \
	--slurpfile command_doc "$commands_file" '
	def problem($ok; $message): if $ok then empty else $message end;
	def distinct($items): ($items | length) == ($items | unique | length);
	def nonempty: type == "string" and length > 0;
	def fieldnames($entity; $registry):
		[$entity.fields[]?.name, ($entity.common_contracts[]? as $contract | $registry.common_contracts[$contract].fields[]?)];
	def field($entity; $registry; $name):
		([$entity.fields[]? | select(.name == $name)][0] //
			if (fieldnames($entity; $registry) | index($name)) != null then $registry.common_fields[$name] else null end);
	def cycle($map; $name; $trail; $dependency_key):
		if ($trail | index($name)) != null then
			($trail | index($name)) as $start | ($trail[$start:] + [$name] | join(" -> "))
		else ($map[$name][$dependency_key] // [])[] as $next
			| select($map | has($next)) | cycle($map; $next; $trail + [$name]; $dependency_key)
		end;
	def execution_evidence($record; $label):
		if (["passed", "failed", "completed", "implemented", "verified"] | index($record.status)) != null then
			problem(($record.evidence_files | type) == "array" and ($record.evidence_files | length) > 0
				and all($record.evidence_files[]; nonempty) and ($record.observed_result | nonempty);
				$label + " declares an executed outcome without evidence_files and observed_result")
		else empty end;
	$component_doc[0] as $C | $entity_doc[0] as $D | $case_doc[0] as $A |
	$roadmap_doc[0] as $R | $command_doc[0] as $K |
	($C.components // []) as $components | ($D.entities // []) as $entities |
	($A.cases // []) as $cases | ($R.milestones // []) as $milestones | ($K.commands // []) as $commands |
	INDEX($components[]; .name) as $component_map | INDEX($entities[]; .name) as $entity_map |
	INDEX($cases[]; .id) as $case_map | INDEX($milestones[]; .id) as $milestone_map |
	[
		(($C, $D, $A, $R, $K) | .. | objects | select((.status? | type) == "string") | . as $record |
			problem((["proposed_not_implemented","design_only_not_executed","not_run","not_started","planned","in_progress","blocked","passed","failed","completed","implemented","verified"] | index($record.status)) != null;
				($record.id // $record.name // "registry record") + ": unknown status requiring an explicit evidence policy: " + $record.status),
			execution_evidence($record; $record.id // $record.name // "registry record")),
		(if $C != {} then
			problem(($C.components | type) == "array" and ($components | length) == 7; "components: expected seven component records"),
			problem(distinct([$components[].name]); "components: duplicate component name"),
			problem(([$components[].name] | sort) == (["com_farmcore","com_farmledger","com_farmlivestock","com_farmcrops","com_farmmake","com_farmstay","com_farmwork"] | sort); "components: names differ from the agreed seven owners"),
			($components[] as $component |
				problem(($component.name | nonempty); "component has an empty identity"),
				problem(distinct($component.required_dependencies); $component.name + ": duplicate dependency"),
				problem(($component.required_dependencies | sort) ==
					(if $component.name == "com_farmcore" then [] elif $component.name == "com_farmledger" then ["com_farmcore"] else ["com_farmcore","com_farmledger"] end | sort);
					$component.name + ": dependency list violates the Core/Ledger/domain contract"),
				($component.required_dependencies[] as $dependency | problem($component_map | has($dependency); $component.name + ": unknown dependency " + $dependency)),
				problem(distinct($component.owned_entities); $component.name + ": duplicate owned entity"),
				(if $D != {} then problem(($component.owned_entities | sort) == ([$entities[] | select(.owner == $component.name) | .name] | sort); $component.name + ": owned_entities differs from entity owner assignments") else empty end),
				problem(distinct([$component.capabilities[]?.name]); $component.name + ": duplicate capability name"),
				($component.capabilities[]? as $capability |
					problem((["planned","proposed_not_implemented","implemented","verified"] | index($capability.status)) != null; $component.name + ": unexpected capability status"),
					execution_evidence($capability; $component.name + "/" + $capability.name))
			),
			([$components[] | cycle($component_map; .name; []; "required_dependencies")] | unique[] | "component dependency cycle: " + .)
		else empty end),
		(if $D != {} then
			problem(($D.entities | type) == "array" and ($entities | length) > 0; "entities: expected a nonempty entities array"),
			problem($D.not_a_JCB_import == true; "entities: design registry must not be presented as a JCB import"),
			problem(distinct([$entities[].name]); "entities: duplicate entity name"),
			($D.common_fields | to_entries[] | . as $field |
				problem(($field.value.logical_type | nonempty) and ($field.value.required | type) == "boolean"; "common field " + $field.key + ": malformed type/required contract"),
				if $field.value.target then
					problem($entity_map | has($field.value.target.entity); "common field " + $field.key + ": unknown target entity"),
					(if $entity_map | has($field.value.target.entity) then
						problem(fieldnames($entity_map[$field.value.target.entity]; $D) | index($field.value.target.field); "common field " + $field.key + ": unknown target field")
					else empty end)
				else empty end),
			($D.common_contracts | to_entries[] | . as $contract |
				problem(distinct($contract.value.fields); "common contract " + $contract.key + ": duplicate field"),
				($contract.value.fields[] as $field | problem($D.common_fields | has($field); "common contract " + $contract.key + ": unknown field " + $field))),
			($entities[] as $entity | fieldnames($entity; $D) as $names |
				problem(($entity.name | nonempty); "entity has an empty identity"),
				(if $C != {} then problem($component_map | has($entity.owner); $entity.name + ": unknown owner " + $entity.owner) else empty end),
				problem(distinct($names); $entity.name + ": duplicate explicit/inherited field name"),
				problem(($entity.fields | type) == "array" and ($entity.fields | length) > 0; $entity.name + ": fields must be a nonempty array"),
				problem(distinct([$entity.relations[]?.name]); $entity.name + ": duplicate relation name"),
				problem(distinct([$entity.indexes[]?.name // empty]); $entity.name + ": duplicate named index"),
				problem($D.write_modes | has($entity.write_mode); $entity.name + ": unknown write_mode"),
				problem($D.phase_groups | has($entity.phase_group); $entity.name + ": unknown phase_group"),
				($entity.common_contracts[] as $contract | problem($D.common_contracts | has($contract); $entity.name + ": unknown common contract " + $contract)),
				($entity.fields[] as $field |
					problem(($field.name | nonempty) and ($field.logical_type | nonempty) and ($field.required | type) == "boolean"; $entity.name + ": malformed field " + ($field.name // "<unnamed>")),
					(if ($field.name | endswith("_guid")) then problem($field.logical_type == "uuid" and $field.identity_domain == "runtime_application_row"; $entity.name + "." + $field.name + ": GUID must identify an application row") else empty end),
					(if $field.identity_domain == "joomla_local_user" then problem($field.logical_type == "joomla_user_id"; $entity.name + "." + $field.name + ": Joomla actor must use numeric local user identity") else empty end)),
				(($entity.indexes // [])[] as $index |
					problem((($index.fields // $index.columns) | type) == "array" and (($index.fields // $index.columns) | length) > 0; $entity.name + ": declared index has no fields"),
					(($index.fields // $index.columns // [])[] as $field | problem($names | index($field); $entity.name + ": index names absent field " + $field))),
				($entity.relations[]? as $relation |
					problem(($relation.fields | type) == "array" and ($relation.fields | length) > 0; $entity.name + ": relation has no source fields"),
					($relation.fields[]? as $field | problem($names | index($field); $entity.name + ": relation names absent field " + $field)),
					if $relation.target_entity then
						problem(($relation.target_fields | type) == "array" and ($relation.target_fields | length) > 0 and ($relation.fields | length) == ($relation.target_fields | length); $entity.name + ": relation source/target field counts differ or target fields are absent"),
						problem($entity_map | has($relation.target_entity); $entity.name + ": unknown target " + $relation.target_entity),
						(if $entity_map | has($relation.target_entity) then
							fieldnames($entity_map[$relation.target_entity]; $D) as $target_names |
							problem($relation.target_owner == $entity_map[$relation.target_entity].owner; $entity.name + ": incorrect target owner for " + $relation.name),
							($relation.target_fields[]? as $field | problem($target_names | index($field); $entity.name + ": target field missing " + $relation.target_entity + "." + $field))
						else empty end),
						(if $relation.optional_cross_component then problem($relation.required == false; $entity.name + ": optional satellite relation is mandatory") else empty end)
					elif $relation.external_system == "Joomla" and $relation.external_entity == "user" then
						problem($relation.target_fields == ["id"]; $entity.name + ": external Joomla actor must target user.id"),
						($relation.fields[] as $name | problem(field($entity; $D; $name).logical_type == "joomla_user_id"; $entity.name + ": external actor relation has non-user field " + $name))
					elif $relation.relation_type == "typed_owner_reference" then
						problem(($relation.allowed_target_registry | nonempty); $entity.name + ": typed owner reference has no registry")
					else "entity " + $entity.name + ": unclassified relation " + ($relation.name // "<unnamed>") end)
			)
		else empty end),
		(if $A != {} then
			problem(($A.cases | type) == "array" and ($cases | length) > 0; "acceptance: cases array is empty or absent"),
			problem(distinct([$cases[].id]); "acceptance: duplicate case ID"),
			($cases[] as $case |
				problem(($case.id | nonempty); "acceptance: empty case ID"),
				problem((["not_run","in_progress","blocked","passed","failed"] | index($case.status)) != null; $case.id + ": unexpected execution status"),
				execution_evidence($case; $case.id),
				(if $C != {} then
					problem($component_map | has($case.owner_component); $case.id + ": unknown owner component"),
					($case.collaborating_components[]? as $component | problem($component_map | has($component); $case.id + ": unknown collaborating component " + $component))
				else empty end),
				(if $R != {} then
					problem($milestone_map | has($case.milestone); $case.id + ": unknown milestone " + $case.milestone),
					(if $milestone_map | has($case.milestone) then
						problem($case.release_gate.release == $milestone_map[$case.milestone].release; $case.id + ": release differs from primary milestone"),
						problem($milestone_map[$case.milestone].acceptance_case_ids | index($case.id); $case.id + ": absent from its primary milestone acceptance list")
					else empty end)
				else empty end))
		else empty end),
		(if $R != {} then
			problem(($R.milestones | type) == "array" and ($milestones | length) > 0; "roadmap: milestones array is empty or absent"),
			problem(distinct([$milestones[].id]); "roadmap: duplicate milestone ID"),
			($milestones[] as $milestone |
				problem(($milestone.id | nonempty) and ($milestone.name | nonempty); "roadmap: malformed milestone identity/name"),
				problem(distinct($milestone.depends_on); $milestone.id + ": duplicate dependency"),
				problem(distinct($milestone.acceptance_case_ids); $milestone.id + ": duplicate acceptance case"),
				problem((["not_started","not_run","planned","in_progress","blocked","completed","passed","failed"] | index($milestone.status)) != null; $milestone.id + ": unexpected status"),
				execution_evidence($milestone; $milestone.id),
				($milestone.depends_on[] as $dependency | problem($milestone_map | has($dependency); $milestone.id + ": unknown dependency " + $dependency)),
				(if $A != {} then ($milestone.acceptance_case_ids[] as $case_id | problem($case_map | has($case_id); $milestone.id + ": unknown acceptance case " + $case_id)) else empty end)
			),
			([$milestones[] | cycle($milestone_map; .id; []; "depends_on")] | unique[] | "milestone dependency cycle: " + .)
		else empty end),
		(if $K != {} then
			problem(($K.commands | type) == "array" and ($commands | length) > 0; "commands: commands array is empty or absent"),
			problem(distinct([$commands[].id]); "commands: duplicate command ID"),
			problem(distinct([$commands[].command_type]); "commands: duplicate command type"),
			($commands[] as $command |
				problem(($command.id | nonempty) and $command.id == $command.command_type; "commands: ID must equal command_type"),
				problem((["proposed_not_implemented","implemented","verified"] | index($command.status)) != null; $command.id + ": unexpected command status"),
				execution_evidence($command; $command.id),
				(if $C != {} then problem($component_map | has($command.owner_component); $command.id + ": unknown command owner") else empty end),
				(if $D != {} then
					problem($entity_map | has($command.aggregate_entity); $command.id + ": unknown aggregate entity"),
					problem($entity_map[$command.aggregate_entity].owner == $command.owner_component; $command.id + ": aggregate owner differs from command owner"),
					($command.effects[]? as $effect |
						problem($entity_map | has($effect.entity); $command.id + ": unknown effect entity " + $effect.entity),
						problem($entity_map[$effect.entity].owner == $effect.owner_component; $command.id + ": incorrect effect owner for " + $effect.entity))
				else empty end),
				problem(distinct($command.acceptance_case_ids); $command.id + ": duplicate acceptance case"),
				(if $A != {} then ($command.acceptance_case_ids[] as $case_id | problem($case_map | has($case_id); $command.id + ": unknown acceptance case " + $case_id)) else empty end))
		else empty end)
	] | unique | .[]
' > "$work_dir/registry-errors"; then
	fail 'registry validation could not complete; inspect jq errors above'
else
	while IFS= read -r message; do [[ -z "$message" ]] || fail "$message"; done < "$work_dir/registry-errors"
	if [[ ! -s "$work_dir/registry-errors" ]]; then pass 'registry identities, ownership, fields/indexes, relationships, dependencies and evidence-status rules'; fi
fi

# Exact table coverage, including every name in slash-joined Markdown rows.
if [[ -f "$contracts_dir/domain-entities.json" ]]; then
	awk '
		/^## [0-9]+\./ { split($0, heading, " "); section=heading[2]+0 }
		section >= 3 && section <= 9 && /^\| `/ {
			split($0, cells, "|"); names=cells[2];
			while (match(names, /`[^`]+`/)) {
				print substr(names, RSTART+1, RLENGTH-2);
				names=substr(names, RSTART+RLENGTH);
			}
		}
	' "$repo_root/docs/farm-erp/DOMAIN_MODEL.md" | sort > "$work_dir/prose-entities"
	jq -r '.entities[].name' "$entities_file" | sort > "$work_dir/registry-entities"
	if [[ "$(cat "$work_dir/prose-entities")" != "$(cat "$work_dir/registry-entities")" ]]; then
		fail 'DOMAIN_MODEL table names do not exactly match domain-entities.json (including duplicate rows)'
		diff -u "$work_dir/prose-entities" "$work_dir/registry-entities" >&2 || true
	else pass "DOMAIN_MODEL exactly covers $(jq '.entities | length' "$entities_file") registered entities"; fi
fi

# Decode percent-escaped file paths without evaluating input as shell code.
decode_path() {
	local rest=$1 result='' prefix hex character
	while [[ "$rest" =~ ^([^%]*)%([[:xdigit:]]{2})(.*)$ ]]; do
		prefix=${BASH_REMATCH[1]}; hex=${BASH_REMATCH[2]}; rest=${BASH_REMATCH[3]}
		case "${hex,,}" in 00|09|0a|0d) return 1 ;; esac
		printf -v character '%b' "\\x$hex"
		result+="$prefix$character"
	done
	[[ "$rest" != *'%'* ]] || return 1
	printf '%s' "$result$rest"
}

check_destination() {
	local origin=$1 target=$2 context=$3 path_part fragment='' resolved decoded
	[[ -n "$target" ]] || { fail "$context: empty destination"; return; }
	if [[ "$target" =~ ^[[:alpha:]][[:alnum:]+.-]*: || "$target" == //* ]]; then
		network_links=$((network_links + 1)); return
	fi
	path_part=${target%%#*}
	if [[ "$target" == *'#'* ]]; then fragment=${target#*#}; fi
	path_part=${path_part%%\?*}
	if [[ -z "$path_part" ]]; then resolved=$origin
	else
		if ! decoded=$(decode_path "$path_part"); then fail "$context: malformed percent-escaped file destination $target"; return; fi
		if [[ "$decoded" == /* ]]; then resolved=$(realpath -m -- "$repo_root/$decoded")
		else resolved=$(realpath -m -- "$(dirname -- "$origin")/$decoded"); fi
	fi
	if [[ ! -e "$resolved" ]]; then
		if (( allow_incomplete )) && [[ "$resolved" == "$contracts_dir/"* ]]; then skip "$context: pending contract destination $target"
		else fail "$context: file destination does not exist: $target"; fi
		return
	fi
	local_links=$((local_links + 1))
	if [[ -n "$fragment" && "$resolved" == *.json && "$fragment" == /* ]]; then
		if ! jq -e --arg pointer "$fragment" '
			($pointer | split("/")[1:] | map(gsub("~1"; "/") | gsub("~0"; "~"))) as $parts |
			reduce $parts[] as $key ({exists:true,value:.};
				if .exists == false then .
				elif (.value | type) == "object" then
					if (.value | has($key)) then {exists:true,value:.value[$key]} else {exists:false,value:null} end
				elif (.value | type) == "array" and ($key | test("^(0|[1-9][0-9]*)$")) then
					($key|tonumber) as $index | if $index < (.value|length) then {exists:true,value:.value[$index]} else {exists:false,value:null} end
				else {exists:false,value:null} end) | .exists
		' "$resolved" >/dev/null; then fail "$context: JSON pointer does not resolve: $target"; else json_pointers=$((json_pointers + 1)); fi
	elif [[ -n "$fragment" ]]; then fragments_skipped=$((fragments_skipped + 1)); fi
}

# Source references are relative to the containing registry, not repository root.
for file in "${json_files[@]}"; do
	while IFS= read -r target; do
		[[ -z "$target" ]] || check_destination "$file" "$target" "${file#"$repo_root/"} reference"
	done < <(jq -r '
		.. | objects | to_entries[] |
		select(.key as $key | ["source_document","component_registry","entity_registry","acceptance_registry","allowed_target_registry","document","source","$ref","evidence_file"] | index($key)) |
		.value | select(type == "string")
	' "$file")
	while IFS= read -r target; do
		[[ -z "$target" ]] || check_destination "$file" "$target" "${file#"$repo_root/"} source/evidence file"
	done < <(jq -r '.. | objects | (.source_documents? // empty), (.evidence_files? // empty) | .[]? | select(type == "string")' "$file")
done

normalise_label() { printf '%s' "$1" | awk '{$1=$1; print tolower($0)}'; }
extract_target() {
	local input=$1
	input=${input#"${input%%[![:space:]]*}"}
	if [[ "$input" == '<'* ]]; then
		input=${input#<}; printf '%s' "${input%%>*}"
	else printf '%s' "${input%%[[:space:]]*}"; fi
}
mapfile -t markdown_files < <(rg --files "$repo_root" -g '*.md' -g '!node_modules/**' -g '!vendor/**' | sort)
for file in "${markdown_files[@]}"; do
	# Retain original line numbers; ignore fenced code, including Mermaid.
	awk '
		/^[ \t]*```/ { if (!fence) fence="`"; else if (fence=="`") fence=""; next }
		/^[ \t]*~~~/ { if (!fence) fence="~"; else if (fence=="~") fence=""; next }
		!fence { line=$0; gsub(/`[^`]*`/, "", line); printf "%d\t%s\n", NR, line }
	' "$file" > "$work_dir/markdown-lines"
	declare -A reference_targets=()
	declare -A table_citation_ids=()
	while IFS=$'\t' read -r line_number line; do
		# Source/requirement tables also deliberately use bracketed IDs in prose.
		# They are citations to a table row, not Markdown reference definitions.
		if [[ "$line" =~ ^\|[[:space:]]*([A-Z]+-?[0-9]+)[[:space:]]*\| ]]; then
			label=$(normalise_label "${BASH_REMATCH[1]}")
			table_citation_ids["$label"]=1
		fi
		if [[ "$line" =~ ^[[:space:]]*\[([^]]+)\]:[[:space:]]*(.*)$ ]]; then
			label=$(normalise_label "${BASH_REMATCH[1]}"); target=$(extract_target "${BASH_REMATCH[2]}")
			if [[ ${reference_targets["$label"]+present} ]]; then fail "${file#"$repo_root/"}:$line_number duplicate reference label [$label]"; fi
			reference_targets["$label"]=$target
			check_destination "$file" "$target" "${file#"$repo_root/"}:$line_number reference [$label]"
		fi
	done < "$work_dir/markdown-lines"
	inline_pattern='\]\(([^)]*)\)'
	full_inline_pattern='!?\[[^][]*\]\([^)]*\)'
	explicit_pattern='\[([^][]+)\]\[([^][]*)\]'
	citation_pattern='\[(JCB-[0-9]+|[A-Z]+[0-9]{2,}|[A-Z]+-[0-9]+)\]'
	while IFS=$'\t' read -r line_number line; do
		[[ "$line" =~ ^[[:space:]]*\[[^]]+\]: ]] && continue
		rest=$line
		while [[ "$rest" =~ $inline_pattern ]]; do
			match=${BASH_REMATCH[0]}; target=$(extract_target "${BASH_REMATCH[1]}")
			check_destination "$file" "$target" "${file#"$repo_root/"}:$line_number inline link"
			rest=${rest#*"$match"}
		done
		rest=$line
		while [[ "$rest" =~ $explicit_pattern ]]; do
			match=${BASH_REMATCH[0]}; label=${BASH_REMATCH[2]:-${BASH_REMATCH[1]}}; label=$(normalise_label "$label")
			if [[ ! ${reference_targets["$label"]+present} ]]; then fail "${file#"$repo_root/"}:$line_number undefined reference [$label]"; fi
			rest=${rest#*"$match"}
		done
		# The repository uses short source IDs as shortcut reference links.
		rest=$line
		while [[ "$rest" =~ $full_inline_pattern ]]; do
			match=${BASH_REMATCH[0]}; rest=${rest/"$match"/}
		done
		while [[ "$rest" =~ $citation_pattern ]]; do
			match=${BASH_REMATCH[0]}; label=$(normalise_label "${BASH_REMATCH[1]}")
			if [[ ! ${reference_targets["$label"]+present} && ! ${table_citation_ids["$label"]+present} ]]; then fail "${file#"$repo_root/"}:$line_number undefined citation [$label]"; fi
			rest=${rest#*"$match"}
		done
	done < "$work_dir/markdown-lines"
	unset reference_targets table_citation_ids
done
pass "checked $local_links local destinations and $json_pointers JSON pointers across ${#markdown_files[@]} Markdown files and registries"

# Anchored git markers, avoiding legitimate table separators or quoted prose.
if rg -n --glob '*.md' --glob '*.json' --glob '*.sh' '^(<<<<<<<( |$)|=======$|>>>>>>>( |$)|\|\|\|\|\|\|\|( |$))' "$repo_root" > "$work_dir/merge-markers"; then
	fail 'unresolved merge conflict markers found'
	cat "$work_dir/merge-markers" >&2
else pass 'no unresolved merge conflict markers'; fi

printf 'LIMITS: skipped %s network/scheme destinations and %s heading/non-pointer fragments; no network/heading-anchor validation.\n' "$network_links" "$fragments_skipped"
printf 'LIMITS: JSON syntax and registry contracts only; full JSON Schema evaluation, duplicate object-key detection, full CommonMark parsing and semantic evidence review are separate.\n'
printf 'LIMITS: no JCB import, compilation, Playground, ERP runtime, legal compliance or production tests ran.\n'
if (( failures )); then printf 'FAILED: %s documentation consistency issue(s).\n' "$failures" >&2; exit 1; fi
if (( allow_incomplete || skips )); then printf 'CHECKPOINT ONLY: available documentation checks passed; run without --allow-incomplete for final validation.\n'
else printf 'PASSED: documentation and registry consistency checks.\n'; fi
