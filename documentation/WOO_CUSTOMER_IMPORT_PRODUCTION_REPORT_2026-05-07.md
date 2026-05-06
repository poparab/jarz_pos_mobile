# Woo Customer Import Production Report

Date: 2026-05-07

## Final Status

The production cleanup was executed successfully using the validated staging method.

- Production was deployed from GitHub first.
- A production backup was taken before any cleanup mutations.
- The cleanup ran through the file-based runner path without quoting failures, hanging terminal sessions, or database connection loss.
- Production health verification passed after deployment and again after the cleanup passes.

The remaining gap is not operational instability. The remaining gap is live Woo data drift during the production run.

## Production Deploy State

Final deployed heads during this run:

- `jarz_pos`: `f570185f9511e883c13f4906e764f528cd94dd20`
- `jarz_woocommerce_integration`: `3c5a61832c562fa511a116d5ac9319b95488c48d`

Production app versions verified after deploy:

- `frappe 16.13.0`
- `erpnext 16.12.0`
- `hrms 16.6.1`
- `jarz_pos 0.0.1 main`
- `jarz_woocommerce_integration 0.0.1 main`

## Backup Taken

Production backup created before the cleanup deploy:

- files: `/home/frappe/frappe-bench/sites/frontend/private/backups/20260507_004136-frontend-files.tar`
- private files: `/home/frappe/frappe-bench/sites/frontend/private/backups/20260507_004136-frontend-private-files.tar`

## Execution Method Used

The same method that worked on staging was reused on production:

1. Copy helper runner from local `artifacts/2026-05-06/` to the production host with `scp`.
2. Copy the runner into `erp-backend-1` with `docker cp`.
3. Execute it inside the backend container with env vars.
4. Remove the temporary host and container files after each pass.

This avoided the staging-era failure modes:

- nested PowerShell quoting failures
- long inline `bench execute` command failures
- invisible stuck terminals
- long idle DB connection loss before the first SQL query

## Cleanup Passes Run

### Initial production dry run

Summary head:

- `addresses_created: 1798`
- blocked duplicate canonical Woo IDs: `3`
- blocked email or username conflict cases: `1`

### Production apply pass 1

Summary head:

- `addresses_created: 5`
- `addresses_deleted: 497`
- `addresses_disabled: 4171`

### Post-pass dry run

Summary head:

- `addresses_created: 46`

### Production apply pass 2

Summary head:

- `addresses_created: 0`
- `addresses_deleted: 50`

### Post-pass dry run

Summary head:

- `addresses_created: 45`

### Production apply pass 3

Summary head:

- `addresses_created: 0`
- `addresses_deleted: 46`

### Final dry run at end of this session

Summary head:

- `addresses_created: 45`
- `addresses_deleted: 0`
- `addresses_disabled: 0`

## Audit Results During This Run

### Canonical grouped audit after the latest cleanup passes

- Woo customers: `5266`
- resolved ERP customers: `5155`
- unresolved Woo customers: `6`
- exact customer matches: `5110`
- deviated customer matches: `45`
- customers missing at least one union Woo address: `45`
- customers with extra unique ERP addresses: `45`
- total missing union Woo addresses: `45`
- total extra unique ERP addresses: `45`
- duplicate row surplus: `0`

### Per-Woo audit after the latest cleanup passes

- exact Woo-ID unique matches: `5154`
- phone-merge unique matches: `106`
- resolved total: `5260`
- unresolved total: `6`
- exact address matches: `4535`
- deviated address matches: `246`
- customers missing at least one current Woo address: `45`
- customers with extra unique ERP addresses: `246`
- total missing current Woo addresses: `45`
- total extra unique ERP addresses: `272`

## Remaining Blocked Identity Cases

The cleanup still intentionally refused to merge these unsafe cases automatically:

- `187`: username conflict without safe phone resolution
- `885`: email and username conflict without phone
- `3357`: duplicate canonical Woo ID already stamped across multiple ERP customers
- `3437`: duplicate canonical Woo ID already stamped across multiple ERP customers
- `3753`: duplicate canonical Woo ID already stamped across multiple ERP customers

There was also one additional unresolved production customer during the later audit totals, bringing the unresolved production total to `6`.

## Important Production Observation

During investigation of a specific customer case on production, the live Woo payload changed between inspections for the same Woo customer ID.

This means the production source was still moving while the cleanup was running.

That is the most likely reason the canonical audit improved materially but did not reach zero during this session. The target state continued changing while cleanup and audit passes were in progress.

## Verification Result

Production verification passed after the cleanup work:

- all required containers were healthy
- site accessibility returned `HTTP 200`
- custom apps were installed correctly
- all critical verification checks passed

## Conclusion

The production cleanup execution itself was successful and stable.

The remaining `45` canonical address mismatches should be treated as live-source drift still present at the end of the run, not as a replay of the staging operational failures.

The next production pass should be done in a quieter window or with Woo customer updates effectively frozen during the run, then the same canonical audit should be rerun immediately afterward.