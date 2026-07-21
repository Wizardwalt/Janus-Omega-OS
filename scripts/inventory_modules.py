#!/usr/bin/env python3
"""Create a non-executing inventory of Janus Lua modules.

This tool intentionally does not run module code. It identifies files, hashes,
duplicate content, and basic metadata so production certification can happen
before a module is exposed to customers.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

DEFAULT_ROOTS = ("plugins", "modules", "core", "apocalypse_engineering")


def category_for(path: Path) -> str:
    parts = path.parts
    if len(parts) >= 2 and parts[0] in {"plugins", "modules"}:
        return parts[1]
    return parts[0]


def description_for(path: Path) -> str | None:
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()[:12]
    except OSError:
        return None
    for line in lines:
        line = line.strip()
        if line.startswith("--"):
            text = line.lstrip("-").strip()
            if len(text) > 8 and not text.lower().startswith(("category", "module #")):
                return text[:300]
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", default="reports/module-inventory.json")
    args = parser.parse_args()

    modules = []
    hashes: dict[str, list[str]] = defaultdict(list)
    for root_name in DEFAULT_ROOTS:
        root = Path(root_name)
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("*.lua")):
            data = path.read_bytes()
            digest = hashlib.sha256(data).hexdigest()
            relative_path = path.as_posix()
            hashes[digest].append(relative_path)
            modules.append({
                "id": relative_path.removesuffix(".lua").replace("/", "."),
                "path": relative_path,
                "category": category_for(path),
                "sha256": digest,
                "bytes": len(data),
                "description": description_for(path),
                "certification_status": "pending_review",
                "execution_mode": "disabled_until_certified",
            })

    duplicate_groups = [paths for paths in hashes.values() if len(paths) > 1]
    duplicate_paths = {path for paths in duplicate_groups for path in paths}
    for module in modules:
        if module["path"] in duplicate_paths:
            module["duplicate_content"] = True

    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "module_count": len(modules),
        "duplicate_content_groups": duplicate_groups,
        "modules": modules,
    }
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Inventoried {len(modules)} Lua modules -> {output}")
    print(f"Exact duplicate-content groups: {len(duplicate_groups)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
