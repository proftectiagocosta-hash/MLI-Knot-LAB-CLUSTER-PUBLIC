#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Read-only SSH connectivity and node metadata check.
# Verificação SSH somente leitura de conectividade e metadados dos nós.

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"

HOSTS_FILE="${HOSTS_FILE:-}"
REMOTE_USER="${REMOTE_USER:-}"
SSH_PORT="${SSH_PORT:-22}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-5}"
SSH_IDENTITY_FILE="${SSH_IDENTITY_FILE:-}"

usage() {
    cat <<'USAGE'
Usage:
  HOSTS_FILE=/path/to/private_hosts.txt [options] ./scripts/cluster_check.sh

Environment:
  HOSTS_FILE          Required inventory with one SSH host per line.
  REMOTE_USER         Optional SSH user. SSH configuration is used when empty.
  SSH_PORT            Optional SSH port. Default: 22.
  CONNECT_TIMEOUT     Connection timeout in seconds. Default: 5.
  SSH_IDENTITY_FILE   Optional path to a private identity file.

Inventory:
  Empty lines and comments beginning with # are ignored.
  Hosts must be plain DNS names or IPv4-style host values.
  Do not include users, ports, shell arguments or commands in inventory lines.

Operation:
  Authentication is non-interactive.
  Existing known-host verification is mandatory.
  The remote check reads only hostname, kernel and uptime information.

Example:
  HOSTS_FILE=examples/cluster_hosts.example.txt ./scripts/cluster_check.sh

The bundled example uses non-resolving .invalid names. Point HOSTS_FILE to
an authorized private inventory for an actual environment.
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

[[ -f "$HOSTS_FILE" ]] ||
    fail "HOSTS_FILE is not a regular file"

[[ -r "$HOSTS_FILE" ]] ||
    fail "HOSTS_FILE is not readable"

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
        fail "SSH_IDENTITY_FILE is not a readable regular file"
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

readonly REMOTE_CHECK='
set -eu

node_name=$(hostname 2>/dev/null || printf "%s" "unavailable")
kernel=$(uname -sr 2>/dev/null || printf "%s" "unavailable")

if [ -r /proc/uptime ]; then
    uptime_seconds=$(cut -d. -f1 /proc/uptime)
else
    uptime_seconds=unavailable
fi

printf "hostname=%s\n" "$node_name"
printf "kernel=%s\n" "$kernel"
printf "uptime_seconds=%s\n" "$uptime_seconds"
'

failures=0

for host in "${hosts[@]}"; do
    target="$host"

    if [[ -n "$REMOTE_USER" ]]; then
        target="${REMOTE_USER}@${host}"
    fi

    printf '[check] target=%s\n' "$host"

    if ssh "${ssh_args[@]}" "$target" "$REMOTE_CHECK"; then
        printf '[ok] target=%s\n' "$host"
    else
        printf '[failed] target=%s\n' "$host" >&2
        (( failures += 1 ))
    fi
done

if (( failures > 0 )); then
    printf '[summary] checked=%d failed=%d\n' \
        "${#hosts[@]}" "$failures" >&2
    exit 1
fi

printf '[summary] checked=%d failed=0\n' "${#hosts[@]}"
