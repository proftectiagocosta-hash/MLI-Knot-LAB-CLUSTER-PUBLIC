#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Fixed, read-only readiness audit for authorized cluster nodes.
# Auditoria fixa e somente leitura da prontidão de nós autorizados.

set -Eeuo pipefail

HOSTS_FILE="${HOSTS_FILE:-}"
REMOTE_USER="${REMOTE_USER:-}"
SSH_PORT="${SSH_PORT:-22}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-5}"
SSH_IDENTITY_FILE="${SSH_IDENTITY_FILE:-}"

usage() {
    cat <<'USAGE'
Usage:
  HOSTS_FILE=/path/to/private_hosts.txt ./scripts/cluster_audit.sh

Environment:
  HOSTS_FILE          Required inventory with one SSH host per line.
  REMOTE_USER         Optional SSH user.
  SSH_PORT            Optional SSH port. Default: 22.
  CONNECT_TIMEOUT     Connection timeout in seconds. Default: 5.
  SSH_IDENTITY_FILE   Optional readable identity file.

Checks:
  - hostname command availability;
  - kernel information availability;
  - effective identity availability;
  - operating-system metadata readability;
  - uptime source readability;
  - root filesystem inspection availability.

Properties:
  - the remote check set is fixed in this script;
  - all checks are read-only;
  - command output is suppressed;
  - only pass or fail states are returned;
  - authentication is non-interactive;
  - existing known-host verification is mandatory;
  - no privilege escalation is requested;
  - no report is written to disk.

Runtime target names and results must not be committed to this public repository.
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

readonly REMOTE_AUDIT='
set -u

LC_ALL=C
export LC_ALL

failures=0

run_check() {
    check_name=$1
    shift

    if "$@" >/dev/null 2>&1; then
        printf "[pass] check=%s\n" "$check_name"
    else
        printf "[fail] check=%s\n" "$check_name"
        failures=$((failures + 1))
    fi
}

run_check hostname hostname
run_check kernel uname -sr
run_check identity id -u
run_check os_release test -r /etc/os-release
run_check uptime_source test -r /proc/uptime
run_check root_filesystem df -P /

exit "$failures"
'

failed_targets=0

printf '[audit] targets=%d checks_per_target=6\n' "${#hosts[@]}"

for host in "${hosts[@]}"; do
    target="$host"

    if [[ -n "$REMOTE_USER" ]]; then
        target="${REMOTE_USER}@${host}"
    fi

    printf '[audit] target=%s\n' "$host"

    if ssh "${ssh_args[@]}" "$target" "$REMOTE_AUDIT"; then
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
