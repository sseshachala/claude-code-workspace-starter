#!/usr/bin/env bash
# Tests for the timestamped backup behavior in install.sh

set -euo pipefail

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; ((PASS++)) || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Test the backup_file helper function in isolation ─────────────────────────
source_backup_fn() {
  # Extract and eval just the backup_file function from install.sh
  eval "$(grep -A 8 '^backup_file()' "$SCRIPT_DIR/install.sh")"
}

echo ""
echo "=== Test 1: backup_file creates a timestamped backup ==="
TMPDIR_TEST="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_TEST"' EXIT

source_backup_fn
echo "original content" > "$TMPDIR_TEST/CLAUDE.md"

BAK="$(backup_file "$TMPDIR_TEST/CLAUDE.md")"

if [[ -f "$BAK" ]]; then
  pass "Backup file was created: $(basename "$BAK")"
else
  fail "Backup file was NOT created"
fi

# Verify timestamp pattern CLAUDE.md.bak.YYYYMMDDHHMMSS
if [[ "$(basename "$BAK")" =~ ^CLAUDE\.md\.bak\.[0-9]{14}$ ]]; then
  pass "Backup filename matches timestamped pattern"
else
  fail "Backup filename does NOT match pattern: $(basename "$BAK")"
fi

if [[ "$(cat "$BAK")" == "original content" ]]; then
  pass "Backup contains original content"
else
  fail "Backup content mismatch"
fi

echo ""
echo "=== Test 2: Two consecutive backups produce two distinct files ==="
TMPDIR_TEST2="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_TEST" "$TMPDIR_TEST2"' EXIT

echo "version1" > "$TMPDIR_TEST2/CLAUDE.md"
BAK1="$(backup_file "$TMPDIR_TEST2/CLAUDE.md")"

sleep 1  # ensure different timestamp

echo "version2" > "$TMPDIR_TEST2/CLAUDE.md"
BAK2="$(backup_file "$TMPDIR_TEST2/CLAUDE.md")"

if [[ "$BAK1" != "$BAK2" ]]; then
  pass "Two backups have different filenames"
else
  fail "Two backups have the SAME filename (overwrite risk)"
fi

if [[ -f "$BAK1" && -f "$BAK2" ]]; then
  pass "Both backup files exist"
else
  fail "One or both backup files missing"
fi

if [[ "$(cat "$BAK1")" == "version1" && "$(cat "$BAK2")" == "version2" ]]; then
  pass "Both backups contain their respective content"
else
  fail "Backup content mismatch: bak1='$(cat "$BAK1")' bak2='$(cat "$BAK2")'"
fi

echo ""
echo "=== Test 3: install.sh uses timestamped backup (no .bak plain file) ==="
# Simulate what install.sh does for the CLAUDE.md backup
TMPDIR_TEST3="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_TEST" "$TMPDIR_TEST2" "$TMPDIR_TEST3"' EXIT

# Check that the install.sh script does NOT use the old plain .bak pattern
if grep -qE 'cp .* CLAUDE\.md\.bak"$' "$SCRIPT_DIR/install.sh"; then
  fail "install.sh still uses the old plain .bak pattern"
else
  pass "install.sh does NOT use the old plain .bak pattern"
fi

# Check that install.sh calls backup_file for CLAUDE.md
if grep -q 'backup_file.*CLAUDE\.md' "$SCRIPT_DIR/install.sh"; then
  pass "install.sh calls backup_file for CLAUDE.md"
else
  fail "install.sh does NOT call backup_file for CLAUDE.md"
fi

echo ""
echo "=== Test 4: backup_file function exists in install.sh ==="
if grep -q '^backup_file()' "$SCRIPT_DIR/install.sh"; then
  pass "backup_file function is defined in install.sh"
else
  fail "backup_file function is NOT defined in install.sh"
fi

echo ""
echo "================================"
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "================================"
echo ""

[[ $FAIL -eq 0 ]]
