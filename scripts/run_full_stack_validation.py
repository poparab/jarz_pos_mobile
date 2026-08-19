#!/usr/bin/env python3
"""Run the whole validation stack against staging and write a dated report.

One command, one artefact, repeatable. This is the driver the Woo suites have
had for a long time (``run_woo_staging_full_cycle.py``) and the accounting and
role suites never did — those were run by hand, which is why nobody ran them
together and why "is the system correct right now" had no single answer.

Usage::

    python scripts/run_full_stack_validation.py
    python scripts/run_full_stack_validation.py --only roles,lifecycle
    python scripts/run_full_stack_validation.py --keep-fixtures   # skips the sweep
    python scripts/run_full_stack_validation.py --dry-run         # print, do not run

Writes ``artifacts/full_stack_validation/<run_id>.json`` and ``.md``.

Exit code is 0 only when every suite passed **and** the fixture sweep left the
site clean.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
#: The workspace directory above the Flutter repo. The SSH key and the shared
#: artifacts directory both live there, alongside the sibling repos.
WORKSPACE = REPO_ROOT.parent

DEFAULT_HOST = "ubuntu@13.36.219.136"
DEFAULT_SITE = "frontend"

#: Searched in order rather than hardcoded to one path. This script lives inside
#: the tracked Flutter repo — deliberately, because the existing SSH drivers sit
#: in an untracked sibling directory and a validation suite nobody can retrieve
#: after a machine rebuild is not a repeatable suite. The cost of being tracked
#: is that the key sits one level up, outside the repo, where it belongs.
_KEY_CANDIDATES = (
    WORKSPACE / "ERPNext-stg.pem",
    REPO_ROOT / "ERPNext-stg.pem",
)
DEFAULT_OUTPUT = WORKSPACE / "artifacts" / "full_stack_validation"


def _default_key() -> Path:
    for candidate in _KEY_CANDIDATES:
        if candidate.exists():
            return candidate
    return _KEY_CANDIDATES[0]

MARKER_START = "FULL_STACK_VALIDATION_JSON_START"
MARKER_END = "FULL_STACK_VALIDATION_JSON_END"

#: Resolved on the server rather than hardcoded. Staging runs ``erp-backend-1``
#: with hyphens while parts of the documentation still say underscores; matching
#: both is cheaper than being wrong on one of them.
CONTAINER_PROBE = (
    "docker ps --format '{{.Names}}' | grep -E 'erp[-_]backend[-_]1|erp[-_]backend' | head -n 1"
)


def _ssh(host: str, key: Path, command: str, dry_run: bool = False) -> str:
    argv = [
        "ssh", "-i", str(key),
        "-o", "StrictHostKeyChecking=no",
        "-o", "ConnectTimeout=20",
        host, command,
    ]
    if dry_run:
        print("DRY RUN:", " ".join(argv))
        return ""
    proc = subprocess.run(argv, capture_output=True, text=True)
    if proc.returncode != 0 and not proc.stdout:
        raise RuntimeError(
            f"ssh failed ({proc.returncode})\ncommand: {command}\nstderr: {proc.stderr[:2000]}"
        )
    # stdout is returned even on a non-zero exit: several harnesses report
    # failures in their JSON payload and still exit 0, and at least one exits 1
    # while having produced a complete, useful report. The exit code is not the
    # verdict here — the parsed payload is.
    return proc.stdout


def _extract_report(raw: str) -> dict:
    """Slice the JSON payload out of noisy bench output.

    ``bench execute`` prints the script's own output *and then* re-prints the
    return value as JSON, so the payload appears twice in different shapes.
    The markers disambiguate; without them a naive ``json.loads`` of the tail
    silently reads the wrong copy.
    """
    start = raw.find(MARKER_START)
    end = raw.find(MARKER_END)
    if start == -1 or end == -1:
        raise RuntimeError(
            "no marker pair in bench output — the harness likely crashed before "
            f"reporting.\n--- tail ---\n{raw[-3000:]}"
        )
    payload = raw[start + len(MARKER_START):end].strip()
    return json.loads(payload)


def _kwargs_literal(only: str | None, skip: str | None, cleanup: bool) -> str:
    """Build the ``--kwargs`` value using DOUBLE quotes inside.

    Two constraints meet here and only one spelling satisfies both. ``bench
    execute`` parses this with ``ast.literal_eval``, so it must be a *Python*
    literal — ``True``, not JSON's ``true``. And the whole thing is wrapped in
    single quotes for the remote shell, so it must contain no single quotes of
    its own. Writing the dict the natural Python way (``{'cleanup': True}``)
    satisfies the first and breaks the second: the shell would end the quoted
    string at the first inner quote and hand ``bench`` a fragment.
    """
    parts = [f'"cleanup": {cleanup}']
    if only:
        keys = ", ".join(f'"{s.strip()}"' for s in only.split(",") if s.strip())
        parts.append(f'"only": [{keys}]')
    if skip:
        keys = ", ".join(f'"{s.strip()}"' for s in skip.split(",") if s.strip())
        parts.append(f'"skip": [{keys}]')
    return "{" + ", ".join(parts) + "}"


def _render_markdown(report: dict, run_id: str) -> str:
    fp = report.get("fingerprint") or {}
    lines = [
        f"# Full-stack validation — {run_id}",
        "",
        f"- **site**: `{report.get('site')}`",
        f"- **base url**: `{fp.get('base_url')}`",
        f"- **started**: {fp.get('run_started')}",
        f"- **duration**: {report.get('seconds')}s",
        f"- **total**: {report.get('passed')} passed, {report.get('failed')} failed, "
        f"{report.get('skipped', 0)} skipped",
        "",
        "## Suites",
        "",
        "| suite | status | passed | failed | skipped | seconds | what it proves |",
        "|---|---|---:|---:|---:|---:|---|",
    ]
    for suite in report.get("suites") or []:
        lines.append(
            f"| `{suite.get('key')}` | {suite.get('status')} | {suite.get('passed', 0)} | "
            f"{suite.get('failed', 0)} | {suite.get('skipped', 0)} | "
            f"{suite.get('seconds', 0)} | {suite.get('what', '')} |"
        )

    sweep = report.get("sweep") or {}
    lines += [
        "",
        "## Fixture sweep",
        "",
        f"- ran: `{sweep.get('ran')}`",
        f"- clean: `{sweep.get('clean')}`",
        f"- residue: `{sweep.get('residue') or 'none'}`",
    ]
    if sweep.get("error"):
        lines.append(f"- error: `{sweep['error']}`")

    # A skipped check also carries passed=False, so the two have to be split
    # apart here or every skip would be reported as a failure — which would make
    # the third state useless the moment it reached the report.
    failures = []
    skips = []
    for suite in report.get("suites") or []:
        if suite.get("error"):
            failures.append((suite.get("key"), suite["key"], suite["error"]))
        for check in suite.get("checks") or []:
            row = (suite.get("key"), check.get("name"), check.get("detail", ""))
            if check.get("skipped"):
                skips.append(row)
            elif not check.get("passed"):
                failures.append(row)

    def _table(rows):
        out = ["| suite | check | detail |", "|---|---|---|"]
        for suite_key, name, detail in rows:
            safe = str(detail).replace("|", "\\|")[:400]
            out.append(f"| `{suite_key}` | `{name}` | {safe} |")
        return out

    lines += ["", f"## Failures ({len(failures)})", ""]
    lines += _table(failures) if failures else ["None."]

    lines += [
        "",
        f"## Skipped ({len(skips)})",
        "",
        "_Checks that never ran because this site could not satisfy their "
        "precondition. Not passes — read them before trusting the totals._",
        "",
    ]
    lines += _table(skips) if skips else ["None."]

    lines += ["", "## Environment fingerprint", "", "```json",
              json.dumps(fp, indent=2, default=str), "```", ""]
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default=DEFAULT_HOST)
    parser.add_argument("--site", default=DEFAULT_SITE)
    parser.add_argument("--key-path", default=str(_default_key()))
    parser.add_argument("--output-dir", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--only", default=None, help="comma-separated suite keys")
    parser.add_argument("--skip", default=None, help="comma-separated suite keys")
    parser.add_argument(
        "--keep-fixtures", action="store_true",
        help="do not clean up; skips the sweep and therefore the clean-site check",
    )
    parser.add_argument("--run-id", default=None)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    key = Path(args.key_path)
    if not key.exists() and not args.dry_run:
        print(f"ERROR: ssh key not found at {key}", file=sys.stderr)
        return 2

    run_id = args.run_id or datetime.now().strftime("%Y%m%d-%H%M%S")

    # Refuse production outright, here as well as in the harness. Two
    # independent refusals is not redundancy: this one stops the command before
    # it opens a session, and does not depend on the far side being the version
    # of the code that carries the guard.
    if "13.36.132.13" in args.host or "erp.orderjarz.com" in args.host:
        print("ERROR: this suite writes documents and never runs against production.",
              file=sys.stderr)
        return 2

    print(f"[1/4] resolving backend container on {args.host} ...")
    container = _ssh(args.host, key, CONTAINER_PROBE, args.dry_run).strip()
    if not container and not args.dry_run:
        print("ERROR: could not resolve the backend container", file=sys.stderr)
        return 2
    print(f"      container = {container or '<dry-run>'}")

    kwargs = _kwargs_literal(args.only, args.skip, not args.keep_fixtures)
    # Single quotes around the kwargs, not escaped double quotes. subprocess
    # hands this string to ssh as one argv element and ssh replays it through
    # the *remote* shell, so any escaping has to survive one shell parse on the
    # far side and none on this one.
    remote = (
        f"docker exec {container} bench --site {args.site} execute "
        f"jarz_pos.scripts.full_stack_validation.run --kwargs '{kwargs}'"
    )

    print(f"[2/4] running full_stack_validation ({kwargs}) ...")
    raw = _ssh(args.host, key, remote, args.dry_run)
    if args.dry_run:
        return 0

    print("[3/4] extracting report ...")
    report = _extract_report(raw)

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    json_path = out_dir / f"{run_id}.json"
    md_path = out_dir / f"{run_id}.md"
    json_path.write_text(json.dumps(report, indent=2, default=str), encoding="utf-8")
    md_path.write_text(_render_markdown(report, run_id), encoding="utf-8")

    print(f"[4/4] wrote {json_path}")
    print(f"      wrote {md_path}")

    failed = int(report.get("failed") or 0)
    bad = report.get("suites_bad") or []
    print()
    skipped = int(report.get("skipped") or 0)
    print(f"RESULT: {report.get('passed')} passed, {failed} failed, {skipped} skipped")
    if skipped:
        print("        skipped = never ran on this site; not a pass. See the report.")
    if bad:
        print(f"NEEDS ATTENTION: {', '.join(bad)}")
    # Deliberately not `return proc.returncode`: several harnesses report
    # failures in JSON and still exit 0.
    return 1 if (failed or bad) else 0


if __name__ == "__main__":
    sys.exit(main())
