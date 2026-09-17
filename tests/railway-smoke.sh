#!/usr/bin/env bash
# shellcheck disable=SC2015
# Live test of a deployed template: the flows the local smoke covers, over HTTPS.
#
#   DEGOOG_PASSWORD_FILE=./settings-password tests/railway-smoke.sh https://<app-domain>
#
# The settings password is read from a file (never an argument, never printed).
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
[ $# -ge 1 ] || { sed -n '3,6p' "$0"; exit 2; }
APP_URL=${1%/}; export APP_URL
: "${DEGOOG_PASSWORD_FILE:?set DEGOOG_PASSWORD_FILE}"
DEGOOG_PASSWORD=$(tr -d '\n' < "$DEGOOG_PASSWORD_FILE"); export DEGOOG_PASSWORD
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'rm -rf "$TEST_TMP"' EXIT

section "availability over HTTPS"
wait_for_code "$APP_URL/readyz" 200 300 && pass "/readyz returns 200 over HTTPS" || die "not ready"
assert_eq "the home page is served" "200" "$(http_code "$APP_URL/")"

section "search returns aggregated results over HTTPS"
out=$(curl -s --max-time 90 "$APP_URL/search?q=railway%20app")
assert_contains "the search page renders" "<title>degoog" "$out"
assert_contains "the search returns results" "result" "$out"

section "the settings/extensions area is password-protected over HTTPS"
assert_eq "reading settings without a session is rejected" "401" "$(http_code "$APP_URL/api/settings/general")"
badbody=$(curl -s --max-time 20 -X POST "$APP_URL/api/settings/auth" -H 'Content-Type: application/json' --data '{"password":"definitely-wrong"}')
if grep -q '"ok":true' <<<"$badbody"; then fail "a wrong settings password authenticated"; else pass "a wrong settings password is rejected"; fi
jar="$TEST_TMP/jar"
settings_auth "$jar" && pass "the settings password authenticates" || fail "settings auth failed with the correct password"
assert_eq "settings are readable with a session" "200" "$(http_code -b "$jar" "$APP_URL/api/settings/general")"

summary
