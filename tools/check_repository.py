"""Portable repository checks. Does not simulate Roblox or certify gameplay."""
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote

root = Path(__file__).resolve().parents[1]
errors = []
required = ["default.project.json", "assets/Neighborhood.model.json",
            "builds/TheNeighborhood.rbxl", "docs/specification/roblox_codex.txt"]
for name in required:
    if not (root / name).is_file():
        errors.append(f"Missing required file: {name}")
json_count = 0
for path in root.rglob("*.json"):
    if ".git" in path.parts:
        continue
    try:
        json.loads(path.read_text(encoding="utf-8-sig"))
        json_count += 1
    except (ValueError, OSError) as exc:
        errors.append(f"Invalid JSON {path.relative_to(root)}: {exc}")
guides = ["README.md", "docs/INDEX.md", "docs/BUILDING.md", "docs/ARCHITECTURE.md",
          "docs/TESTING.md", "docs/RELEASE.md", "docs/ASSETS.md"]
link_count = 0
for name in guides:
    path = root / name
    if not path.is_file():
        errors.append(f"Missing guide: {name}")
        continue
    for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
        target = target.strip("<>").split("#", 1)[0]
        if not target or re.match(r"[a-zA-Z]+:", target):
            continue
        link_count += 1
        if not (path.parent / unquote(target)).exists():
            errors.append(f"Broken local link in {name}: {target}")
for error in errors:
    print(error, file=sys.stderr)
print(f"Checked {json_count} JSON files, {len(guides)} guides, {link_count} local links.")
sys.exit(1 if errors else 0)
