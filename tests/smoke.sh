#!/usr/bin/env bash
# shellcheck disable=SC2015
# Smoke test: run the metasearch, then verify liveness, that a search returns aggregated results, and that the
# settings/extensions area is password-protected (so a stranger cannot install code-running extensions).
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"

STARTED=0
if [ "${DEGOOG_REUSE_STACK:-0}" != "1" ]; then
  section "bring the stack up"
  compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
  STARTED=1
  trap 'compose logs --no-color --tail 100 || true; [ "$STARTED" = 1 ] && compose down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT
else
  trap 'rm -rf "$TEST_TMP"' EXIT
fi

section "liveness"
wait_for_code "$APP_URL/readyz" 200 180 && pass "/readyz returns 200" || die "app never became ready"
assert_eq "the home page is served" "200" "$(http_code "$APP_URL/")"

section "search returns aggregated results"
out=$(curl -s --max-time 60 "$APP_URL/search?q=railway%20app")
assert_contains "the search page renders" "<title>degoog" "$out"
assert_contains "the search returns results" "result" "$out"

section "the settings/extensions area is password-protected"
assert_eq "reading settings without a session is rejected" "401" "$(http_code "$APP_URL/api/settings/general")"
wrongjar="$TEST_TMP/wrong"
badbody=$(curl -s -c "$wrongjar" --max-time 20 -X POST "$APP_URL/api/settings/auth" -H 'Content-Type: application/json' --data '{"password":"definitely-wrong"}')
if grep -q '"ok":true' <<<"$badbody"; then fail "a wrong settings password authenticated"; else pass "a wrong settings password is rejected"; fi

section "the correct password unlocks the settings"
jar="$TEST_TMP/jar"
settings_auth "$jar" && pass "the settings password authenticates" || die "settings auth failed with the correct password"
assert_eq "settings are readable with a session" "200" "$(http_code -b "$jar" "$APP_URL/api/settings/general")"

summary
