# Woo Customer Import Staging Report

Date: 2026-05-06

## Scope Implemented

This staging cycle implemented the first hardening slice for customer and address import behavior, aligned with the current business rules:

- ERPNext is the canonical source of truth after import.
- WooCommerce remains an upstream source only.
- Phone is treated as the practical merge key for customer identity.
- Address dedupe is allowed only inside the same customer boundary.
- Cross-customer address reuse is forbidden.
- Wrong or stale imported addresses are intended to be removed during the later cleanup phase.

## Custom App Changes Deployed

### jarz_woocommerce_integration

Commit deployed to staging:

- `e76f170` Harden Woo customer identity and address import

Implemented behavior:

- bulk customer sync now passes `woo_customer_id` into `_ensure_customer(...)`
- automated customer import no longer reuses existing ERP customers by display name
- customer identity resolution now prefers:
  1. exact `woo_customer_id`
  2. phone match
  3. username match when the Woo ID does not conflict
  4. email match when the Woo ID does not conflict
  5. create new ERP customer
- same-phone customers continue to merge to the same ERP customer, matching the current decision that phone is the key
- inbound address matching now uses a full normalized payload instead of `address_type + address_line1` only
- full-address comparison now includes:
  - line1
  - line2
  - city
  - state
  - postcode
  - country
- billing and shipping are treated as the same address only when the full normalized payload matches
- line2-only inbound addresses are now treated as valid source addresses
- imported addresses are matched only inside the same customer boundary

### jarz_pos

Commit deployed to staging:

- `1843096` Stabilize customer shipping address selection

Implemented behavior:

- customer address lists are deduped for picker use
- canonical shipping choices stay tied to the same customer only
- duplicate legacy address names can resolve back to the canonical customer-owned address
- saving a customer shipping address now reuses a matching existing customer address instead of blindly inserting another duplicate row

## Local Validation

### Woo-focused local tests

Executed inside local v16 backend container:

- `TestCustomerWooIdRuntime.test_ensure_customer_backfills_canonical_woo_customer_id_on_email_match`
- `TestCustomerWooIdRuntime.test_ensure_customer_uses_phone_as_primary_merge_key`
- `TestCustomerWooIdRuntime.test_ensure_customer_does_not_reuse_email_match_with_conflicting_woo_id`
- `TestCustomerBulkSync`
- `TestCustomerAddressCanonicalization`

Result:

- `8 tests passed`

### jarz_pos local tests

Executed inside local v16 backend container:

- `jarz_pos.tests.test_customer_address_utils`

Result:

- `6 tests passed`

## Staging Deployment Verification

### Deployed heads on staging

- `jarz_pos`: `184309649985851aacc731d5277ea9ae7a1efc9e`
- `jarz_woocommerce_integration`: `e76f1705aaa8c901f76e056c1242720fc8b07406`

### Installed app versions on staging

- `frappe 16.13.0`
- `erpnext 16.12.0`
- `hrms 16.4.7`
- `jarz_pos 0.0.1 main (1843096)`
- `jarz_woocommerce_integration 0.0.1 main (e76f170)`

### Focused staging backend tests

Executed inside `erp-backend-1` on staging:

- targeted Woo identity tests
- targeted Woo bulk-sync and address canonicalization tests
- `jarz_pos.tests.test_customer_address_utils`

Result:

- `14 tests passed`

### Live staging smoke check

- `GET https://erpstg.orderjarz.com/api/method/ping`
- result: `200`
- body: `{\"message\":\"pong\"}`

## What This Fixes Now

- new inbound Woo customer imports are less likely to merge by weak name heuristics
- same-phone customer records continue to converge to one ERP customer as requested
- same-address detection is stricter and no longer collapses rows just because `address_1` matches
- line2-only source addresses are no longer silently dropped
- customer-facing address picker behavior is more stable and less duplicate-prone
- saving shipping addresses in `jarz_pos` now prefers reuse of the correct customer-owned address

## What This Does Not Fix Yet

- historical cleanup and backfill of all existing production customer/address drift has not been run yet
- no production data repair has been executed yet
- no dedicated alias model exists yet for tracking multiple Woo customer IDs that may collapse into one ERP customer by phone
- stale and wrong imported addresses have not yet been hard-deleted in production
- conflict queue and recurring drift audit automation are still pending follow-up work

## Production Gate Assessment

Current status:

- code hardening implemented
- local validation passed
- staging deployment passed
- staging focused tests passed
- staging HTTP smoke passed

Recommendation before production:

1. Keep this as a hardening release first.
2. Do not treat it as the full cleanup release yet.
3. Before production backfill or cleanup, prepare the next slice for:
   - audit command/report automation
   - safe classification of duplicate and contaminated customer/address graphs
   - hard-delete rules for wrong imported addresses
   - optional manual review handling for non-phone identity conflicts

## Summary

The implemented staging slice is successful.

It hardens future Woo-to-ERP customer and address imports, tightens same-customer address reuse, preserves the current business rule that phone is the merge key, and reduces the risk of duplicate or wrongly collapsed addresses.

It is a valid base for the next phase: audit-driven cleanup and repair of the existing deviated data before any production cleanup wave.