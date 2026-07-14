#!/usr/bin/env bash
#
# check-xsd-drift.sh — read-only drift check between this repository and a
# brickfox Core checkout. Does NOT modify anything and does NOT push.
#
# Compares the published (whitelisted) schemas in ./xsd against the Core source
# at BFcore/brick/modules/XmlExchange/xsd/. Prints a diff summary and exits
# non-zero if they differ, so it can drive a warn-only CI job (allow_failure: true).
#
# Usage:
#   bin/check-xsd-drift.sh /path/to/core
#   CORE_PATH=/path/to/core bin/check-xsd-drift.sh
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CORE_PATH="${1:-${CORE_PATH:-}}"

if [ -z "$CORE_PATH" ]; then
  echo "ERROR: provide the Core checkout path (arg 1 or \$CORE_PATH)." >&2
  exit 2
fi

CORE_XSD="$CORE_PATH/BFcore/brick/modules/XmlExchange/xsd"
if [ ! -d "$CORE_XSD" ]; then
  echo "ERROR: Core XSD dir not found: $CORE_XSD" >&2
  exit 2
fi

# Published (whitelisted) schemas — must match README / CHANGELOG.
SCHEMAS=(
  baseProducts products productsUpdate productDelete productsAssignments
  bundles shopProductUpdate articleNotDelete
  categories brands manufacturers orders orderstatus
)

drift=0
for name in "${SCHEMAS[@]}"; do
  published="$REPO_ROOT/xsd/$name.xsd"
  source="$CORE_XSD/$name.xsd"
  if [ ! -f "$source" ]; then
    echo "MISSING IN CORE: $name.xsd"
    drift=1
    continue
  fi
  if [ ! -f "$published" ]; then
    echo "MISSING IN REPO: $name.xsd"
    drift=1
    continue
  fi
  if ! diff -q "$published" "$source" >/dev/null; then
    echo "DRIFT: $name.xsd differs from Core"
    drift=1
  fi
done

if [ "$drift" -eq 0 ]; then
  echo "OK: all ${#SCHEMAS[@]} published schemas match Core ($CORE_XSD)."
else
  echo ""
  echo "Drift detected. Update xsd/, VERSION and CHANGELOG.md, then commit." >&2
fi
exit "$drift"
