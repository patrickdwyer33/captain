#!/usr/bin/env bash
# release.sh — bump captain version in both captain and pattymarket, then push both.
#
# Usage:
#   ./scripts/release.sh           # auto-bumps patch version (e.g. 1.0.4 → 1.0.5)
#   ./scripts/release.sh 2.0.0    # explicit version for major/minor releases

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPTAIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_JSON="$CAPTAIN_ROOT/.claude-plugin/plugin.json"
PACKAGE_JSON="$CAPTAIN_ROOT/package.json"
MARKETPLACE_JSON="$CAPTAIN_ROOT/marketplace/.claude-plugin/marketplace.json"

# ── Preflight ────────────────────────────────────────────────────────────────

if [ ! -f "$MARKETPLACE_JSON" ]; then
  echo "error: marketplace submodule not initialized. Run: git submodule update --init" >&2
  exit 1
fi

# ── Determine new version ────────────────────────────────────────────────────

current=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")

if [ -n "${1:-}" ]; then
  new="$1"
else
  new=$(python3 -c "
parts = '$current'.split('.')
parts[2] = str(int(parts[2]) + 1)
print('.'.join(parts))
")
fi

echo "release: $current → $new"

# ── Update captain version files ─────────────────────────────────────────────

python3 - "$PLUGIN_JSON" "$PACKAGE_JSON" "$new" <<'PYEOF'
import sys, json
plugin_json, package_json, new_version = sys.argv[1], sys.argv[2], sys.argv[3]
for path in [plugin_json, package_json]:
    with open(path) as f:
        d = json.load(f)
    d['version'] = new_version
    with open(path, 'w') as f:
        json.dump(d, f, indent=2)
        f.write('\n')
PYEOF

# ── Update marketplace submodule ─────────────────────────────────────────────

python3 - "$MARKETPLACE_JSON" "$new" <<'PYEOF'
import sys, json
marketplace_json, new_version = sys.argv[1], sys.argv[2]
with open(marketplace_json) as f:
    d = json.load(f)
for plugin in d['plugins']:
    if plugin['name'] == 'captain':
        plugin['version'] = new_version
with open(marketplace_json, 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
PYEOF

# ── Commit and push submodule ────────────────────────────────────────────────

cd "$CAPTAIN_ROOT/marketplace"
git add .claude-plugin/marketplace.json
git commit -m "chore: bump captain to v$new"
git push origin main

# ── Commit and push captain ──────────────────────────────────────────────────

cd "$CAPTAIN_ROOT"
git add .claude-plugin/plugin.json package.json marketplace
git commit -m "chore: release v$new"
git push origin main

echo "release: v$new published ✓"
