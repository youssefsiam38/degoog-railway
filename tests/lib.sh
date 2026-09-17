#!/usr/bin/env bash
# shellcheck disable=SC2015
# Shared helpers for degoog-railway tests. Source this file; do not execute it.
# The settings password is never echoed. The settings area is gated by a session obtained with the password.

: "${APP_URL:=http://localhost:${DEGOOG_TEST_PORT:-14444}}"
: "${TEST_TIMEOUT:=300}"
: "${DEGOOG_PASSWORD:=${DEGOOG_TEST_SETTINGS_PASSWORD:-local-test-only-settings-password}}"

TEST_TMP="${TEST_TMP:-$(mktemp -d)}"
export TEST_TMP
_PASS=0; _FAIL=0

pass() { _PASS=$((_PASS+1)); printf '  PASS  %s\n' "$*"; }
fail() { _FAIL=$((_FAIL+1)); printf '  FAIL  %s\n' "$*" >&2; }
die()  { printf 'FATAL: %s\n' "$*" >&2; exit 1; }
section() { printf '\n== %s ==\n' "$*"; }
summary() { printf '\n%d passed, %d failed\n' "$_PASS" "$_FAIL"; [ "$_FAIL" -eq 0 ]; }

assert_eq() { if [ "$2" = "$3" ]; then pass "$1 ($3)"; else fail "$1: expected [$2] got [$3]"; fi; }
assert_contains() { if grep -q -- "$2" <<<"$3"; then pass "$1"; else fail "$1: missing [$2]"; fi; }

http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 30 "$@" || true; }

wait_for_code() {
  local url=$1 want=$2 timeout=${3:-$TEST_TIMEOUT} start code
  start=$(date +%s)
  while :; do
    code=$(http_code "$url")
    [ "$code" = "$want" ] && return 0
    if [ $(( $(date +%s) - start )) -ge "$timeout" ]; then printf 'timed out waiting for %s -> %s (last %s)\n' "$url" "$want" "$code" >&2; return 1; fi
    sleep 3
  done
}

compose() { docker compose -f "$REPO_ROOT/compose.yaml" "$@"; }

# settings_auth JARFILE -> 0 if the password authenticates (writes the session cookie to JARFILE), else non-zero.
settings_auth() {
  local jar=$1 body
  body=$(curl -s -c "$jar" --max-time 30 -X POST "$APP_URL/api/settings/auth" -H 'Content-Type: application/json' \
    --data "$(jq -nc --arg p "$DEGOOG_PASSWORD" '{password:$p}')")
  grep -q '"ok":true' <<<"$body"
}
