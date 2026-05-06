# Woo Customer Import And ERP Source Of Truth Plan

## Status

- Investigation complete.
- Production baseline captured on 2026-05-06.
- Partial local mitigation already exists in jarz_pos/utils/customer_address_utils.py, but it only improves address reuse and picker behavior. It does not yet establish ERP-owned canonical customer and address data.
- No full hardening, cleanup, or backfill implementation has been applied yet.

## Clarified Business Direction

- WooCommerce may send customer and address data into ERPNext.
- ERPNext must become the only canonical source of truth after import.
- ERPNext may consolidate equivalent addresses, but only within the same customer boundary.
- Two different customers may have identical address text, but they must still have separate ERP Address rows.
- Under no circumstances may an address be attached to the wrong customer or appear in another customer's picker.
- Backend and frontend logic must be tightened first.
- After the logic is hardened and validated, a controlled sync and repair pass will fix the existing deviations from WooCommerce into ERPNext.

## Executive Summary

The current customer and address sync is not deterministic enough to keep ERPNext customer master data clean.

There are two different problems happening at the same time:

1. Customer identity is not always resolved safely enough during inbound Woo sync.
2. Address sync behaves like append and dedupe heuristics instead of a strict controlled import into ERPNext-owned master data.

That is why ERPNext currently ends up with:

- wrong customer merges
- extra legacy addresses
- missing current Woo addresses
- duplicate rows for the same physical address
- customer pickers that show a partially cleaned view while the underlying master data remains dirty

The target model is not a pure Woo mirror.

The target model is:

- WooCommerce is an upstream input channel.
- ERPNext becomes the system of record for customer master data and address master data after import.
- jarz_woocommerce_integration owns safe inbound identity resolution, import metadata, and repair tooling.
- jarz_pos consumes only ERP-owned canonical customer and address data and must not create unsafe duplicates or cross-customer leakage.
- A one-time cleanup and backfill will repair the existing customer and address graph only after the rules are hardened and tested.

## Current Production Baseline

Audit date: 2026-05-06

Comparison method:

- Match customer records by Customer.woo_customer_id
- Compare Woo billing and shipping addresses against active ERPNext Address rows linked to the matched Customer
- Normalize address text for comparison, but keep logical role differences visible

Current production numbers:

- Woo customers: 5260
- ERP customers with woo_customer_id: 4266
- Matched by woo_customer_id: 4263
- Matched customers with at least one Woo address: 4232
- Exact address matches: 1869, or 44.16%
- Deviated address matches: 2363, or 55.84%
- Customers missing at least one current Woo address in ERP: 1700, or 40.17%
- Customers with extra unique ERP addresses beyond Woo: 2363, or 55.84%
- Customers with duplicate ERP address rows: 248, or 5.86%
- Customers where ERP has more address rows than Woo logical addresses: 1102, or 26.04%
- Total missing current Woo addresses in ERP: 1844
- Total extra unique ERP addresses in ERP: 4230
- Total duplicate row surplus: 490
- Woo customers not linked in ERP: 997
- Woo-only customers that already have an address in Woo: 548
- ERP records linked to Woo IDs no longer present in Woo: 3

Worst offenders from the live audit:

- Woo customer 3610: Woo has 2 logical addresses, ERP has 235 rows for the same customer, including 233 duplicate-surplus rows.
- Woo customer 6: Woo has 1 address, ERP has 97 rows and 96 unique addresses.
- Woo customer 5: Woo has 1 address, ERP has 79 unique addresses.
- Woo customer 3629: Woo has 2 addresses, ERP has 46 rows and 45 unique addresses.

This baseline shows that the dominant failure mode is not only missing addresses. The bigger problem is uncontrolled address accumulation and identity drift on the ERP side.

## What ERPNext Source Of Truth Means

For this project, ERP-owned customer truth should mean the following for every imported Woo-linked customer:

1. Exactly one active ERP Customer master is associated with a given Woo customer ID.
2. Woo customer ID is the inbound identity key, not the permanent owner of the ERP master record after import.
3. ERP stores the canonical customer identity and canonical address set under ERP-controlled rules.
4. ERP may consolidate duplicate or equivalent imported addresses, but only within that same customer.
5. No address row may ever be reused across different customers by automatic logic, even when the text is identical.
6. If two different customers genuinely share the same physical address text, ERP still keeps separate Address rows for each customer.
7. Old imported addresses may be archived, quarantined, or hidden from active pickers once ERP determines they are stale or redundant.
8. POS and ERP APIs must always read and write the ERP canonical customer and address set, not a guessed Woo mirror.

Important boundary:

This plan targets correct ERP-owned customer master data and address master data. It does not assume we should rewrite every historical submitted accounting document in production. Historical document relinking must be handled conservatively and only where it is safe.

## Main Risks We Must Prevent

These are the failures this plan is explicitly designed to stop:

- one Woo customer being matched to the wrong ERP customer
- one ERP customer accumulating dozens of stale or duplicate addresses
- one customer's address appearing in another customer's picker
- same-address heuristics collapsing different addresses incorrectly
- cross-customer address reuse because two rows happen to look similar
- frontend flows masking dirty master data instead of enforcing clean ownership

## Root Causes

### 1. Bulk customer sync does not always use Woo customer ID as the primary key

In jarz_woocommerce_integration/services/customer_bulk_sync.py, the bulk customer path calls _ensure_customer(...) without passing woo_customer_id as the named unique identifier.

That allows the resolver to fall back to weaker heuristics such as:

- username
- phone
- email
- customer_name

For common names like Ahmed, Mohamed, Sara, or Menna, that is enough to create or reuse the wrong ERP customer record.

### 2. Automated customer resolution still allows display-name fallback

In jarz_woocommerce_integration/services/customer_sync.py, _ensure_customer(...) still allows a final fallback on customer_name.

That fallback is too dangerous for automated Woo import. It is acceptable for manual review tooling, but it is not safe for ERP-owned customer truth.

### 3. Address upsert is keyed too loosely

Current inbound address matching relies mainly on address_type plus address_line1.

That is not strict enough because:

- two different addresses can share the same line1 but differ in city, state, postcode, or country
- the same address can move between billing and shipping roles over time
- the same physical address can be reformatted across sync runs

Customer boundary plus full normalized payload is the correct matching key, not role plus line1 only.

### 4. Inbound sync ignores some valid Woo addresses

The inbound sync currently skips address creation when Woo address_1 is blank, even if address_2 is populated.

This creates a mismatch because the outbound customer payload logic already has a fallback that can use address_line2 when address_line1 is blank.

The system therefore accepts some addresses in one direction but drops them in the other.

### 5. Same-address detection is too weak

Current logic treats billing and shipping as the same address when address_1 matches.

That is too weak because two roles may share line1 and still differ in:

- address_2
- city
- state
- postcode
- country

Same-address detection must compare the full normalized payload, not only line1.

### 6. Legacy addresses accumulate instead of being pruned

ERP currently keeps old linked addresses around and the current import logic does not aggressively retire or quarantine stale Woo-derived rows.

That produces the exact behavior shown in the audit:

- dozens of old addresses linked to one customer
- duplicate rows for the same address
- current Woo addresses buried inside a large stale address set

### 7. There is no hard customer-boundary rule for imported addresses

The system does not yet treat the customer boundary as sacred enough during dedupe and reuse decisions.

That is the most dangerous class of failure because even a good dedupe algorithm becomes unacceptable if it can cause one customer's address to appear under another customer.

### 8. The current jarz_pos address fix is a presentation improvement, not full canonicalization

The local changes in jarz_pos/utils/customer_address_utils.py improve these things:

- stable customer address selection
- deduped picker output
- reuse of existing matching addresses during save

That is useful and should still land, but it does not solve the whole problem because it operates on top of already-drifted master data.

### 9. No recurring audit enforces drift back to zero

There is currently no hard daily or post-sync audit that says:

- how many Woo-linked customers drifted
- which ones drifted
- whether the drift was missing, extra, duplicate, collision-driven, or cross-customer contamination

Without a scheduled audit and threshold alert, the system can slowly diverge again after cleanup.

## Non-Negotiable Invariants For The Final Design

These rules should be treated as hard constraints, not optional improvements.

### Customer identity invariants

- Automated Woo import never resolves a customer by display name.
- Exact woo_customer_id remains the first lookup key whenever a canonical Woo link already exists.
- Phone is the approved merge key when multiple Woo customer IDs belong to the same real customer.
- Email or username collisions without the same normalized phone must go to a review queue instead of silent merge.
- No automated process may merge two ERP customers solely because their names or addresses look similar.

### Address ownership invariants

- Every imported active ERP Address row in this flow must belong to exactly one Customer.
- Address matching uses a full normalized fingerprint, not line1 only.
- Address dedupe is allowed only inside the same customer boundary.
- Cross-customer address reuse is forbidden, even when the text is identical.
- Imported addresses must carry metadata proving where they came from and which customer they belong to.
- Any stale imported address is retired or archived under the same customer only.
- Customer pickers and address pickers must never surface another customer's address.

### Sync invariants

- Running the same import twice produces the same result.
- A repeated inbound import of the same Woo customer must not create a new ERP customer or a new ERP address unless the data is materially different.
- Equivalent addresses for the same customer collapse deterministically to one canonical ERP address.
- A changed Woo address updates or creates the correct ERP customer-owned address without polluting other customers.
- Line2-only addresses are treated as valid source addresses.
- The import state can always be audited from ERP import metadata.

### Product invariants

- POS users work against canonical ERP customer and address data.
- Customer pickers show only ERP canonical addresses for the selected customer.
- If an import conflict or ownership conflict exists, the UI must surface that clearly instead of guessing.
- Frontend saves must never be allowed to attach another customer's address to the current customer.

## Recommended Architecture

## 1. Treat Woo as an upstream input channel, not the owner of ERP master data

For customers that originate from Woo, Woo provides inbound source data only:

- customer name
- email
- phone
- billing address
- shipping address

After import, ERPNext should own:

- the canonical customer master
- the canonical address set per customer
- duplicate consolidation within the customer boundary
- archival of stale imported addresses
- all downstream operational use in POS, accounting, and internal workflows

## 2. Introduce an import-control layer in jarz_woocommerce_integration

The safest design is to stop using the linked Address graph as the only control surface.

Recommended import-control structures:

- a customer import snapshot per Woo customer
- up to two inbound address roles per Woo customer: billing and shipping
- conflict and review status attached to the import snapshot

This can be implemented as either:

- a dedicated integration DocType plus child table owned by jarz_woocommerce_integration, or
- a lighter custom-field model on Customer and Address if we want a smaller first implementation

Recommended fields in the import snapshot:

- woo_customer_id
- woo_username
- raw Woo first_name and last_name
- raw Woo email
- raw Woo phone
- sync hash for customer identity payload
- last fetched timestamp
- last applied timestamp
- import status
- conflict status

Recommended fields per inbound address role:

- role: billing or shipping
- raw Woo address_1
- raw Woo address_2
- raw Woo city
- raw Woo state
- raw Woo postcode
- raw Woo country
- normalized fingerprint
- same_as_other_role flag
- projected ERP Address name, if one exists
- last applied timestamp

Reason for this design:

ERP Customer and Address rows remain the business truth, but the import-control layer is needed so inbound Woo data can be matched, deduped, audited, and replayed safely without corrupting ERP masters.

## 3. Deterministically canonicalize imported data into ERP Customer and Address

The import rules should be strict and repeatable.

Recommended metadata on ERP Address rows:

- custom_is_woo_imported
- custom_woo_customer_id
- custom_woo_address_role
- custom_woo_address_fingerprint
- custom_woo_last_synced_at
- custom_woo_archived, if we want soft retirement before deletion

Canonicalization rules:

1. Upsert the ERP customer using Woo customer ID as the inbound identity key.
2. Import addresses only inside that resolved customer boundary.
3. Use full normalized fingerprint for change detection.
4. Update an existing customer-owned address when the incoming payload is equivalent.
5. Create a new address only when the incoming payload is materially different for that same customer.
6. Archive or disable stale imported rows that ERP decides are no longer canonical.
7. If billing and shipping are identical, allow a single canonical visible address for that customer.
8. Never attach an imported address to another customer based on loose matching.

Recommended canonicalization behavior:

- Keep one canonical active ERP row per unique address for the same customer when roles are distinct.
- If billing and shipping are identical, allow one visible address record for that customer while preserving import-role metadata.
- Never create a new active row just because formatting changed while the normalized fingerprint stayed equivalent.
- Never reuse a row that belongs to another customer, even if the normalized fingerprint is identical.

## 4. Tighten jarz_pos frontend and API behavior

jarz_pos should consume only the ERP canonical state.

That means:

- customer pickers load addresses only for the selected customer
- address saves resolve the canonical ERP customer first
- dedupe decisions are made only inside that customer scope
- ambiguous cases are blocked and surfaced to the user instead of auto-merged
- frontend should prefer hard failure over silent data corruption

## Ownership By App

### jarz_woocommerce_integration owns

- import-control snapshot and metadata
- customer identity resolution for Woo import
- deterministic inbound address canonicalization rules
- cleanup and backfill tools
- reconciliation audit and conflict queue
- scheduled drift monitoring

### jarz_pos owns

- customer-facing APIs and picker behavior
- ERP-owned customer and address mutation APIs
- blocking or flagging any action that would break customer and address ownership integrity
- UI messaging when an import conflict exists or a customer or address needs review

This keeps the Woo app responsible for safe inbound ingestion while the POS app remains a consumer and editor of ERP-owned canonical state.

## Detailed Execution Plan

## Phase 0. Freeze New Drift And Add Observability

Objective:

Stop the problem from growing while implementation is in progress.

Tasks:

1. Add a repeatable audit command or script that outputs:
   - matched customers
   - exact matches
   - missing addresses
   - extra addresses
   - duplicate row surplus
   - suspected customer-identity collisions
   - suspected cross-customer address contamination
2. Save the production baseline as an artifact so improvement can be measured after each stage.
3. Add a feature flag for strict customer and address ownership rules, for example strict_customer_address_ownership.
4. Add temporary guardrails in jarz_pos APIs and inbound import logic so imported customers cannot silently create duplicate or cross-customer address contamination.

Exit criteria:

- we can reproduce the current drift report at any time
- new duplicate or cross-customer address contamination is no longer silently accumulating

## Phase 1. Harden Customer Identity Resolution

Objective:

Make Woo customer ID the first authoritative inbound identity key, with phone as the approved merge key when Woo IDs differ.

Tasks:

1. Update every inbound Woo customer sync path to pass woo_customer_id explicitly.
   - This includes the bulk sync path in jarz_woocommerce_integration/services/customer_bulk_sync.py.
2. Remove display-name fallback from automated Woo sync.
   - Manual repair tools may still use name as a suggestion, but production import should not.
3. Enforce deterministic lookup order: exact Woo ID first, then normalized phone, then constrained username or email only when they do not conflict with another Woo identity.
4. Backfill missing canonical woo_customer_id values only from safe matches.
   - safe means exact Woo ID mapping, or exact unique email and no conflicting active Woo ID when phone does not already decide the merge
5. Introduce a conflict queue for ambiguous non-phone matches.
   - same email used by multiple Woo customers without the same normalized phone
   - same username used by multiple Woo customers without the same normalized phone
   - existing ERP customer already linked to a different Woo ID and different normalized phone

Exit criteria:

- all automated import paths resolve by exact Woo customer ID first
- same normalized phone converges to the same ERP customer deterministically
- no automated sync path falls back to customer_name
- ambiguous non-phone identity cases are surfaced instead of silently merged

## Phase 2. Define The Canonical Address Contract

Objective:

Define one deterministic normalization and fingerprinting contract used everywhere.

Tasks:

1. Create one normalization function shared by all inbound import code.
2. Normalize these fields consistently:
   - address_1
   - address_2
   - city
   - state
   - postcode
   - country
3. Preserve raw Woo values separately from normalized values.
4. Treat line2-only addresses as valid.
5. Treat same-address detection as full-payload equality, not line1 equality.
6. Define role behavior clearly:
   - billing missing, shipping present
   - shipping missing, billing present
   - both present and equal
   - both present and different
   - both blank
7. Explicitly define that identical addresses across different customers still remain separate ERP Address rows.

Recommended rule:

The import layer should keep the raw role payload exactly as Woo returned it. ERP canonicalization should decide what the active ERP address set looks like, but only inside the same customer boundary.

Exit criteria:

- one function can compute a stable fingerprint for any Woo address role
- same-address and changed-address decisions are deterministic across all sync paths
- identical address text across different customers never collapses into one shared ERP row

## Phase 3. Build The Import Control And ERP Canonicalization Engine

Objective:

Replace append-style syncing with deterministic import, canonicalization, and prune behavior.

Tasks:

1. Persist the inbound Woo customer snapshot.
2. Persist up to two inbound address roles per Woo customer.
3. Upsert the ERP Customer using Woo ID as the primary inbound identity key.
4. Canonicalize ERP Address rows strictly within that customer boundary.
5. Update ERP Address data when the fingerprint changes.
6. Prune or archive stale imported addresses when the active source data changes.
7. Mark imported addresses so later cleanup and audits can distinguish:
   - imported rows
   - archived imported rows
   - ERP-only local rows
8. Ensure the same sync run is idempotent.

Recommended canonicalization behavior:

- Keep one canonical active row per unique address for the same customer when roles are distinct.
- If billing and shipping are identical, allow one visible address record for that customer while preserving role metadata.
- Never create a new active row just because address formatting changed while the normalized fingerprint stayed equivalent.
- Never reuse a row that belongs to another customer, even if the normalized fingerprint is identical.

Exit criteria:

- a repeated sync of the same customer does not add rows
- changing Woo input updates the correct ERP customer-owned row instead of appending a new active row
- duplicate addresses are consolidated only within the same customer
- no active address can leak across customer boundaries

## Phase 4. Repair POS And ERP Write Paths So Drift Cannot Reappear

Objective:

Stop local edits from immediately breaking ERP canonical data after cleanup.

Tasks:

1. Audit all jarz_pos customer and address mutation surfaces, especially:
   - create_customer
   - save_customer_shipping_address
   - update_default_address
   - any manager or admin customer edit path
2. For imported Woo-linked customers, all edits must preserve ERP ownership rules:
   - resolve the canonical ERP customer first
   - dedupe only within that customer
   - never reuse another customer's address
3. If identity or address ownership is ambiguous, block the edit and send it to review instead of guessing.
4. Make picker views and detail views consume only the canonical active ERP addresses for that customer.
5. If offline address editing exists, do not treat offline local changes as canonical truth.

Recommended policy:

Favor hard block over silent auto-merge. A blocked save is acceptable. Cross-customer address contamination is not.

Exit criteria:

- POS cannot create duplicate or cross-customer address contamination
- every successful customer or address edit preserves ERP ownership and canonicalization rules

## Phase 5. One-Time Cleanup And Backfill

Objective:

Repair the current production customer and address graph safely.

This phase should run only after Phases 1 through 4 are implemented and validated in staging.

### 5.1 Classify every Woo-linked customer into a repair bucket

Recommended buckets:

- exact already
- address-only drift
- extra legacy imported addresses
- missing current Woo address in ERP
- duplicate-row cleanup only
- suspected customer-identity collision
- suspected cross-customer address contamination
- Woo customer exists but ERP customer missing
- ERP customer linked to Woo ID that no longer exists in Woo

### 5.2 Safe automatic repair for straightforward buckets

Safe auto-repair cases:

- current customer identity is correct
- only the imported address set is wrong
- extra imported rows are stale and can be archived
- missing imported rows can be rebuilt from Woo source data
- duplicate rows can be consolidated by fingerprint within the same customer

Automatic actions:

- rebuild import snapshot from Woo
- rebuild ERP canonical addresses from the snapshot under customer-boundary rules
- archive stale imported rows
- disable or unlink archived rows from active customer picker surfaces

### 5.3 High-risk repair for suspected identity collisions or cross-customer contamination

Collision indicators:

- one customer with unusually high unique address count
- generic customer names with many distinct locations
- one ERP customer whose address history spans clearly unrelated regions and profiles
- previous syncs that matched by name, phone, or email before Woo ID was consistently applied
- one address row that appears to have been reused across multiple customers

Recommended repair flow:

1. Create the correct customer master for the Woo customer ID if needed.
2. Rebuild or clone only the addresses that truly belong to that correct customer master.
3. Reassign only safe open or non-submitted documents automatically.
4. Do not mass-rewrite submitted accounting documents unless there is a document-level migration plan and explicit approval.
5. Attach alias or legacy metadata so historical lookup remains traceable.
6. Send ambiguous historical cases to a manual review queue.

Recommended practical rule:

Current master-data ownership should be fixed first. Historical transaction re-assignment should be a separate controlled exercise unless the affected documents are still operationally open.

### 5.4 Create missing ERP customers for Woo-only records

For the 997 Woo customers not currently linked in ERP:

- create ERP customer masters from the import snapshot
- import and canonicalize current addresses under ERP ownership rules
- verify unique Woo ID binding before go-live

### 5.5 Resolve ERP-only stale links

For the 3 ERP customer records linked to Woo IDs that are no longer found in Woo:

- verify whether the Woo record was deleted, merged, or mislinked
- remove or quarantine the stale link if it is invalid
- keep the ERP customer history intact if it represents historical activity

Exit criteria:

- all safe buckets auto-repaired
- only true ambiguous collisions remain in manual review
- the live drift audit shows zero safe drift after backfill

## Phase 6. Testing Strategy

Objective:

Prove the import and canonicalization engine is correct before touching production.

### Unit tests in jarz_woocommerce_integration

Add focused tests for:

- bulk customer sync passes woo_customer_id correctly
- automated sync never falls back to display-name match
- same-phone collisions merge to the same ERP customer deterministically
- email-only collisions create review events or a hard block instead of silent merge
- line2-only inbound address remains valid
- same billing and shipping by full payload collapses correctly for the same customer
- same line1 with different city or postcode does not collapse incorrectly
- identical addresses under two different customers do not collapse into one shared row
- repeat sync is idempotent
- stale imported address rows are pruned or archived
- blank Woo role is handled deterministically

### Integration tests across standard ERP docs and POS flows

Add tests for:

- projected Address metadata correctness
- only the active ERP canonical addresses appear in address pickers for Woo-linked customers
- non-canonical rows do not pollute canonical picker output
- save_customer_shipping_address never selects another customer's address
- manager or admin customer edit paths block ambiguity instead of guessing

### Repair tooling tests

Add tests for:

- dry-run classification buckets
- duplicate-row consolidation
- safe address-only rebuild
- collision bucket detection
- cross-customer contamination detection

### Staging validation

1. Refresh staging from production data.
2. Run the dry-run audit and verify the numbers match the expected baseline shape.
3. Apply the hardening code with strict mode off.
4. Run backfill in dry-run mode.
5. Inspect the largest outliers manually.
6. Run the actual backfill.
7. Rerun the audit.
8. Verify that only intentional manual-review conflicts remain.

Exit criteria:

- staging audit falls to zero safe drift
- no unexpected customer splits or address loss
- POS flows still work against the repaired data

## Phase 7. Rollout Plan

Objective:

Deploy with a reversible sequence and measurable checkpoints.

### Deployment rule

All changes must follow the normal Git path:

- local edit
- commit
- push
- pull and deploy on staging
- validate on staging
- pull and deploy on production

No server-only source changes.

### Recommended rollout sequence

1. Land identity hardening and canonicalization logic behind feature flags.
2. Deploy to staging with strict ownership rules still off.
3. Run production-clone audit on staging.
4. Run dry-run repair and inspect conflict buckets.
5. Run real repair on staging.
6. Run full audit again and confirm safe drift is zero.
7. Enable strict ownership rules on staging.
8. Smoke-test POS customer creation, customer editing, address selection, and Woo sync.
9. Deploy the same commits to production with strict ownership rules off.
10. Run production dry-run audit and snapshot the results.
11. Run production repair.
12. Rerun production audit.
13. If safe drift is zero, enable strict ownership rules in production.
14. Monitor daily audits and sync logs.

## Acceptance Criteria

The project should not be considered complete until all of the following are true.

### ERP master-data correctness

- For every Woo-linked customer outside the explicit manual-review queue, ERP customer identity and active address ownership are correct.
- Every Woo-linked customer resolves by Woo customer ID, not by display name.
- ERP has no active duplicate addresses for those customers unless the addresses are truly distinct.
- ERP is not missing any source address that should exist after import.
- ERP does not attach any address to the wrong customer.

### Product behavior

- POS address pickers show the canonical current ERP address set for the selected customer.
- POS cannot create silent duplicate or cross-customer address contamination.
- If an import or ownership check fails, the user sees a clear failure and ERP does not pretend the save succeeded.

### Operational behavior

- Running the same sync twice produces no new rows.
- Daily drift audit stays at zero safe drift.
- Any remaining problems appear in an explicit conflict queue, not in silent background divergence.

## Risks And Mitigations

### Risk: repairing identity collisions can affect historical documents

Mitigation:

- keep customer-master repair separate from broad historical document rewrite
- auto-move only clearly safe open documents
- archive and review ambiguous historical cases manually

### Risk: cleaning addresses could remove information users still want to reference

Mitigation:

- archive stale imported addresses first instead of hard-deleting immediately
- retain a reversible snapshot until post-rollout audit is clean

### Risk: Woo API limits or long backfill runtime

Mitigation:

- paginate in chunks
- checkpoint progress
- rerunnable idempotent jobs
- dry-run before full run

### Risk: offline address edits reintroduce drift

Mitigation:

- block offline edits for Woo-linked customers in strict ERP-owned mode
- do not treat queued local edits as canonical until explicitly reviewed

### Risk: a smaller partial fix lands and is mistaken for full resolution

Mitigation:

- keep the distinction explicit between:
  - UI dedupe improvements
  - safe ERP-owned master-data canonicalization

## Rollback Strategy

The first production rollout should be reversible.

Recommended rollback design:

1. Keep strict ownership rules behind a flag.
2. Archive rather than immediately destroy stale imported rows during the first rollout.
3. Keep import snapshots so ERP Address rows can be rebuilt deterministically.
4. If production behavior is wrong, disable strict ownership rules first, then restore archived rows if needed.

Rollback should not require manual recreation of customer state.

## Recommended Order Of Work

If I were executing this now, I would do the work in this exact order:

1. Land the current jarz_pos local address reuse and picker cleanup changes because they reduce immediate user pain.
2. Harden identity resolution in jarz_woocommerce_integration so Woo ID is always the primary inbound key.
3. Add import metadata and deterministic ERP-owned address canonicalization.
4. Block or reroute risky customer and address edits in jarz_pos.
5. Build the dry-run audit and repair buckets.
6. Run staging repair on a fresh production clone.
7. Validate POS behavior on staging.
8. Run production repair.
9. Enable strict ERP-owned import rules.
10. Monitor daily drift reports until the metric remains stable at zero safe drift.

## Definition Of Done

This project is done only when these statements are true at the same time:

- the production audit no longer shows safe drift for Woo-linked customers
- POS no longer creates new duplicate or cross-customer address contamination
- customer identity is bound to Woo customer ID consistently
- address import and ERP canonicalization are deterministic and idempotent
- any remaining edge cases are isolated in a manual conflict queue rather than hidden in normal customer data

## Open Questions For Final Decisions

1. After ERPNext becomes the canonical source of truth, do you want future Woo customer edits to continue updating ERP automatically under the strict rules, or should they go to a review queue unless explicitly approved? : sync the changed ones  under strict rules.
2. For stale imported addresses after cleanup, do you want them archived and hidden first, or hard-deleted after a validation window? hard delete the wrong ones.
3. When the same phone or email appears under multiple Woo customer IDs, should the system fully block automatic import until manual review, or create a separate ERP customer with a conflict flag and no automatic merge? merge any with same phone numer as the phone is the key here.
4. After ERP data is cleaned and canonicalized, do you want ERPNext to push corrected customer and address data back to WooCommerce, or should Woo remain unchanged for the first rollout? don't change the woo and it suppose the woo doesn't need to change because the data originally coming from it.