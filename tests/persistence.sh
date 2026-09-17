#!/usr/bin/env bash
# shellcheck disable=SC2015
# Persistence: settings live in /app/data (server-settings.json etc.). Authenticate, write a settings value, take
# the stack down keeping the volume, bring it back, and confirm the value survived. Standalone.
set -euo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd); export REPO_ROOT
# shellcheck source=tests/lib.sh
. "$REPO_ROOT/tests/lib.sh"
trap 'compose logs --no-color --tail 100 || true; compose down -v --remove-orphans >/dev/null 2>&1 || true; rm -rf "$TEST_TMP"' EXIT

section "bring the stack up"
compose up -d --pull always >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/readyz" 200 180 || die "app never became ready"

section "before restart"
jar="$TEST_TMP/jar"
settings_auth "$jar" || die "settings auth failed"
marker="railway-persist-$(date +%s).example"
assert_eq "a settings value is written" "200" \
  "$(http_code -b "$jar" -X POST "$APP_URL/api/settings/general" -H 'Content-Type: application/json' --data "$(jq -nc --arg v "$marker" '{domainBlockList:$v}')")"
assert_contains "the value reads back" "$marker" "$(curl -s -b "$jar" --max-time 20 "$APP_URL/api/settings/general")"

section "full restart (volume preserved)"
compose down >/dev/null 2>&1
compose up -d >/dev/null 2>&1 || die "compose up failed"
wait_for_code "$APP_URL/readyz" 200 180 && pass "ready again after restart" || die "not ready after restart"

section "after restart"
jar2="$TEST_TMP/jar2"
settings_auth "$jar2" || die "settings auth failed after restart"
assert_contains "the settings value survived the restart" "$marker" "$(curl -s -b "$jar2" --max-time 20 "$APP_URL/api/settings/general")"

summary
