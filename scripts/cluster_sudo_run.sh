#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Controlled invocation of a preinstalled privileged helper.
# Invocação controlada de um helper privilegiado previamente instalado.

set -Eeuo pipefail

HOSTS_FILE="${HOSTS_FILE:-}"
REMOTE_USER="${REMOTE_USER:-}"
SSH_PORT="${SSH_PORT:-22}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-5}"
SSH_IDENTITY_FILE="${SSH_IDENTITY_FILE:-}"

PRIVILEGED_HELPER="${PRIVILEGED_HELPER:-}"
PRIVILEGED_ACTION="${PRIVILEGED_ACTION:-}"
EXPECTED_HELPER_SHA256="${EXPECTED_HELPER_SHA256:-}"

RUN_MODE="${RUN_MODE:-preview}"
CONFIRM_PRIVILEGED_EXECUTION="${CONFIRM_PRIVILEGED_EXECUTION:-}"

usage() {
    cat <<'USAGE'
Usage:
  HOSTS_FILE=/path/to/private_hosts.txt \
  PRIVILEGED_HELPER=/usr/local/sbin/cluster-admin-helper \
  PRIVILEGED_ACTION=status \
  EXPECTED_HELPER_SHA256=<approved-sha256> \
  ./scripts/cluster_sudo_run.sh

Modes:
  RUN_MODE=preview
      Validates local configuration and displays the target scope.
      This is the default and does not establish SSH connections.

  RUN_MODE=execute CONFIRM_PRIVILEGED_EXECUTION=YES
      Verifies and invokes the preinstalled helper on each target.

Required privileged design:
  - the helper must be a regular executable file;
  - the helper must be owned by the remote root account;
  - the helper must not be writable by group or other users;
  - its SHA-256 must match EXPECTED_HELPER_SHA256;
  - the remote privilege policy must authorize only the exact helper;
  - the helper must independently allowlist and validate every action.

Restrictions:
  - arbitrary command files are not accepted;
  - arbitrary shell text is not accepted;
  - helper arguments are limited to one validated action token;
  - no password is read, stored or transmitted;
  - non-interactive privilege invocation is mandatory;
  - this wrapper does not install the helper or modify privilege policy.

The public example path is illustrative. Deployment details, policies, helper
source, hashes, inventories and runtime results remain private.
USAGE
}

fail() {
    printf '[error] %s\n' "$*" >&2
    exit 2
}

validate_host() {
    local host="$1"
    local label
    local -a labels=()

    [[ ${#host} -le 253 ]] || return 1
    [[ "$host" != .* ]] || return 1
    [[ "$host" != *. ]] || return 1
    [[ "$host" != *..* ]] || return 1
    [[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] || return 1

    IFS='.' read -r -a labels <<< "$host"

    for label in "${labels[@]}"; do
        [[ ${#label} -ge 1 && ${#label} -le 63 ]] || return 1
        [[ "$label" =~ ^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$ ]] ||
            return 1
    done
}

if (( $# > 0 )); then
    if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        usage
        exit 0
    fi

    usage >&2
    fail "positional arguments are not accepted"
fi

[[ -n "$HOSTS_FILE" ]] ||
    fail "HOSTS_FILE is required"

[[ -f "$HOSTS_FILE" && -r "$HOSTS_FILE" ]] ||
    fail "HOSTS_FILE must be a readable regular file"

if [[ -n "$REMOTE_USER" ]]; then
    [[ "$REMOTE_USER" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] ||
        fail "REMOTE_USER contains unsupported characters"
fi

[[ "$SSH_PORT" =~ ^[1-9][0-9]*$ ]] ||
    fail "SSH_PORT must be a positive integer"

[[ "$CONNECT_TIMEOUT" =~ ^[1-9][0-9]*$ ]] ||
    fail "CONNECT_TIMEOUT must be a positive integer"

SSH_PORT=$((10#$SSH_PORT))
CONNECT_TIMEOUT=$((10#$CONNECT_TIMEOUT))

(( SSH_PORT >= 1 && SSH_PORT <= 65535 )) ||
    fail "SSH_PORT must be between 1 and 65535"

(( CONNECT_TIMEOUT >= 1 && CONNECT_TIMEOUT <= 60 )) ||
    fail "CONNECT_TIMEOUT must be between 1 and 60 seconds"

if [[ -n "$SSH_IDENTITY_FILE" ]]; then
    [[ -f "$SSH_IDENTITY_FILE" && -r "$SSH_IDENTITY_FILE" ]] ||
        fail "SSH_IDENTITY_FILE must be a readable regular file"
fi

[[ "$PRIVILEGED_HELPER" =~ ^/usr/local/sbin/cluster-admin-[a-z0-9._-]{1,64}$ ]] ||
    fail "PRIVILEGED_HELPER is outside the approved public pattern"

[[ "$PRIVILEGED_ACTION" =~ ^[a-z][a-z0-9_-]{0,31}$ ]] ||
    fail "PRIVILEGED_ACTION contains unsupported characters"

[[ "$EXPECTED_HELPER_SHA256" =~ ^[A-Fa-f0-9]{64}$ ]] ||
    fail "EXPECTED_HELPER_SHA256 must contain exactly 64 hexadecimal characters"

EXPECTED_HELPER_SHA256=$(
    printf '%s' "$EXPECTED_HELPER_SHA256" | tr 'A-F' 'a-f'
)

case "$RUN_MODE" in
    preview|execute)
        ;;
    *)
        fail "RUN_MODE must be preview or execute"
        ;;
esac

declare -a hosts=()
declare -A hosts_seen=()

while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    [[ -n "$line" ]] || continue

    validate_host "$line" ||
        fail "invalid host entry in inventory"

    if [[ -n "${hosts_seen[$line]+present}" ]]; then
        fail "duplicate host entry in inventory"
    fi

    hosts+=("$line")
    hosts_seen["$line"]=1
done < "$HOSTS_FILE"

(( ${#hosts[@]} > 0 )) ||
    fail "HOSTS_FILE contains no usable hosts"

printf '[scope] mode=%s targets=%d\n' "$RUN_MODE" "${#hosts[@]}"
printf '[scope] helper=%s action=%s checksum=provided\n' \
    "$PRIVILEGED_HELPER" "$PRIVILEGED_ACTION"

for host in "${hosts[@]}"; do
    printf '[target] %s\n' "$host"
done

if [[ "$RUN_MODE" == "preview" ]]; then
    printf '[preview] no SSH connections or privileged actions were executed\n'
    exit 0
fi

[[ "$CONFIRM_PRIVILEGED_EXECUTION" == "YES" ]] ||
    fail "execute mode requires CONFIRM_PRIVILEGED_EXECUTION=YES"

declare -a ssh_args=(
    -o BatchMode=yes
    -o ConnectionAttempts=1
    -o ConnectTimeout="$CONNECT_TIMEOUT"
    -o StrictHostKeyChecking=yes
    -o LogLevel=ERROR
    -p "$SSH_PORT"
)

if [[ -n "$SSH_IDENTITY_FILE" ]]; then
    ssh_args+=(
        -o IdentitiesOnly=yes
        -i "$SSH_IDENTITY_FILE"
    )
fi

readonly REMOTE_TEMPLATE='
set -eu

helper=__HELPER__
action=__ACTION__
expected_hash=__HASH__

if [ ! -f "$helper" ] || [ ! -x "$helper" ]; then
    printf "[error] privileged helper is unavailable\n" >&2
    exit 20
fi

owner_uid=$(stat -c %u -- "$helper")

if [ "$owner_uid" != "0" ]; then
    printf "[error] privileged helper is not root-owned\n" >&2
    exit 21
fi

if find "$helper" -prune -perm /022 -print -quit | grep -q .; then
    printf "[error] privileged helper has unsafe write permissions\n" >&2
    exit 22
fi

hash_record=$(sha256sum -- "$helper")
actual_hash=${hash_record%% *}

if [ "$actual_hash" != "$expected_hash" ]; then
    printf "[error] privileged helper checksum mismatch\n" >&2
    exit 23
fi

exec sudo -n -- "$helper" "$action"
'

remote_command="${REMOTE_TEMPLATE/__HELPER__/$PRIVILEGED_HELPER}"
remote_command="${remote_command/__ACTION__/$PRIVILEGED_ACTION}"
remote_command="${remote_command/__HASH__/$EXPECTED_HELPER_SHA256}"

if [[ "$remote_command" == *"__HELPER__"* ||
      "$remote_command" == *"__ACTION__"* ||
      "$remote_command" == *"__HASH__"* ]]; then
    fail "remote command construction failed"
fi

failed_targets=0

for host in "${hosts[@]}"; do
    target="$host"

    if [[ -n "$REMOTE_USER" ]]; then
        target="${REMOTE_USER}@${host}"
    fi

    printf '[privileged-run] target=%s action=%s\n' \
        "$host" "$PRIVILEGED_ACTION"

    if ssh "${ssh_args[@]}" "$target" "$remote_command"; then
        printf '[ok] target=%s\n' "$host"
    else
        printf '[failed] target=%s\n' "$host" >&2
        (( failed_targets += 1 ))
    fi
done

if (( failed_targets > 0 )); then
    printf '[summary] targets=%d failed=%d\n' \
        "${#hosts[@]}" "$failed_targets" >&2
    exit 1
fi

printf '[summary] targets=%d failed=0\n' "${#hosts[@]}"
