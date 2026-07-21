#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Controlled remote Bash runner with preview as the safe default.
# Executor Bash remoto controlado com pré-visualização como padrão seguro.

set -Eeuo pipefail

HOSTS_FILE="${HOSTS_FILE:-}"
COMMAND_FILE="${COMMAND_FILE:-}"
REMOTE_USER="${REMOTE_USER:-}"
SSH_PORT="${SSH_PORT:-22}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-5}"
SSH_IDENTITY_FILE="${SSH_IDENTITY_FILE:-}"
RUN_MODE="${RUN_MODE:-preview}"
CONFIRM_REMOTE_EXECUTION="${CONFIRM_REMOTE_EXECUTION:-}"
MAX_COMMAND_BYTES="${MAX_COMMAND_BYTES:-65536}"

usage() {
    cat <<'USAGE'
Usage:
  HOSTS_FILE=/path/to/private_hosts.txt \
  COMMAND_FILE=/path/to/private_command.sh \
  ./scripts/cluster_run.sh

Modes:
  RUN_MODE=preview
      Validates the inventory and command file, then lists the target scope.
      This is the default and does not establish SSH connections.

  RUN_MODE=execute CONFIRM_REMOTE_EXECUTION=YES
      Sends the command file to each authorized target through SSH.

Environment:
  HOSTS_FILE               Required private inventory.
  COMMAND_FILE             Required Bash command file.
  REMOTE_USER              Optional SSH user.
  SSH_PORT                 Optional SSH port. Default: 22.
  CONNECT_TIMEOUT          Connection timeout. Default: 5 seconds.
  SSH_IDENTITY_FILE        Optional readable identity file.
  RUN_MODE                 preview or execute. Default: preview.
  CONFIRM_REMOTE_EXECUTION Must equal YES for execute mode.
  MAX_COMMAND_BYTES        Maximum command file size. Default: 65536.

Safety:
  - authentication is non-interactive;
  - known-host verification remains enabled;
  - command contents are not printed by preview mode;
  - direct sudo commands are rejected;
  - execution is sequential and reports each result;
  - this tool is not a security sandbox.

Use the dedicated privileged runner when administrative execution is required.
Do not store private inventories, command files or captured output in this
public repository.
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

[[ -n "$COMMAND_FILE" ]] ||
    fail "COMMAND_FILE is required"

[[ -f "$COMMAND_FILE" && -r "$COMMAND_FILE" ]] ||
    fail "COMMAND_FILE must be a readable regular file"

[[ -s "$COMMAND_FILE" ]] ||
    fail "COMMAND_FILE must not be empty"

if [[ -n "$REMOTE_USER" ]]; then
    [[ "$REMOTE_USER" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] ||
        fail "REMOTE_USER contains unsupported characters"
fi

[[ "$SSH_PORT" =~ ^[1-9][0-9]*$ ]] ||
    fail "SSH_PORT must be a positive integer"

[[ "$CONNECT_TIMEOUT" =~ ^[1-9][0-9]*$ ]] ||
    fail "CONNECT_TIMEOUT must be a positive integer"

[[ "$MAX_COMMAND_BYTES" =~ ^[1-9][0-9]*$ ]] ||
    fail "MAX_COMMAND_BYTES must be a positive integer"

SSH_PORT=$((10#$SSH_PORT))
CONNECT_TIMEOUT=$((10#$CONNECT_TIMEOUT))
MAX_COMMAND_BYTES=$((10#$MAX_COMMAND_BYTES))

(( SSH_PORT >= 1 && SSH_PORT <= 65535 )) ||
    fail "SSH_PORT must be between 1 and 65535"

(( CONNECT_TIMEOUT >= 1 && CONNECT_TIMEOUT <= 60 )) ||
    fail "CONNECT_TIMEOUT must be between 1 and 60 seconds"

(( MAX_COMMAND_BYTES >= 1 && MAX_COMMAND_BYTES <= 1048576 )) ||
    fail "MAX_COMMAND_BYTES must be between 1 and 1048576"

case "$RUN_MODE" in
    preview|execute)
        ;;
    *)
        fail "RUN_MODE must be preview or execute"
        ;;
esac

if [[ -n "$SSH_IDENTITY_FILE" ]]; then
    [[ -f "$SSH_IDENTITY_FILE" && -r "$SSH_IDENTITY_FILE" ]] ||
        fail "SSH_IDENTITY_FILE must be a readable regular file"
fi

command_bytes=$(wc -c < "$COMMAND_FILE")
command_bytes="${command_bytes//[[:space:]]/}"

[[ "$command_bytes" =~ ^[0-9]+$ ]] ||
    fail "could not determine COMMAND_FILE size"

(( command_bytes <= MAX_COMMAND_BYTES )) ||
    fail "COMMAND_FILE exceeds MAX_COMMAND_BYTES"

if grep -Eq '^[[:space:]]*sudo([[:space:]]|$)' "$COMMAND_FILE"; then
    fail "direct sudo commands are not allowed by this runner"
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

printf '[scope] mode=%s targets=%d command_bytes=%d\n' \
    "$RUN_MODE" "${#hosts[@]}" "$command_bytes"

for host in "${hosts[@]}"; do
    printf '[target] %s\n' "$host"
done

if [[ "$RUN_MODE" == "preview" ]]; then
    printf '[preview] no SSH connections or remote commands were executed\n'
    exit 0
fi

[[ "$CONFIRM_REMOTE_EXECUTION" == "YES" ]] ||
    fail "execute mode requires CONFIRM_REMOTE_EXECUTION=YES"

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

readonly REMOTE_ENTRYPOINT='bash --noprofile --norc -se'

failures=0

for host in "${hosts[@]}"; do
    target="$host"

    if [[ -n "$REMOTE_USER" ]]; then
        target="${REMOTE_USER}@${host}"
    fi

    printf '[run] target=%s\n' "$host"

    if ssh "${ssh_args[@]}" "$target" "$REMOTE_ENTRYPOINT" \
        < "$COMMAND_FILE"; then
        printf '[ok] target=%s\n' "$host"
    else
        printf '[failed] target=%s\n' "$host" >&2
        (( failures += 1 ))
    fi
done

if (( failures > 0 )); then
    printf '[summary] targets=%d failed=%d\n' \
        "${#hosts[@]}" "$failures" >&2
    exit 1
fi

printf '[summary] targets=%d failed=0\n' "${#hosts[@]}"
