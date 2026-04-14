# Contract Fixtures

JSON snapshots captured from the staging API. Each file represents the `message` payload
of a single successful API call.

## Updating Fixtures

Run the snapshot updater (requires `STAGING_USER` and `STAGING_PASSWORD` env vars):

```bash
cd jarz_pos
STAGING_USER=your@email STAGING_PASSWORD=yourpass dart test/contracts/snapshot_updater.dart
```

This will overwrite all `*.json` files in this directory with fresh data from staging.

## Usage in Tests

Contract tests load these files and attempt to deserialize them into Dart models.
A deserialization failure = API contract was broken.
