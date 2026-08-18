#!/usr/bin/env bash
# Run on a Proxmox VE host. Lists every LXC container and VM with its
# ID, name, IP, and MAC (if reachable) in a table, one section per guest type.
set -uo pipefail

BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

SEP="────────────────────────────────────────────────────────────────"

print_section() {
  echo -e "${BOLD}${CYAN}$1${RESET}"
  echo -e "${DIM}${SEP}${RESET}"
}

print_header() {
  printf "${BOLD}%-6s %-20s %-16s %-18s${RESET}\n" "ID" "NAME" "IP" "MAC"
  echo -e "${DIM}${SEP}${RESET}"
}

# Row color: green = running with an IP resolved, yellow = running but no
# IP could be resolved (agent/MAC issue), dim = not running.
print_row() {
  local id="$1" name="$2" ip="$3" mac="$4" status="$5"
  local color="$DIM"
  if [[ "$status" == "running" ]]; then
    [[ "$ip" == "("* ]] && color="$YELLOW" || color="$GREEN"
  fi
  printf "${color}%-6s %-20s %-16s %-18s${RESET}\n" "$id" "$name" "$ip" "$mac"
}

extract_vm_ip() {
  # Filters the guest agent's network-get-interfaces JSON down to the
  # interface matching one of this VM's real NIC MACs (net0, net1, ...),
  # instead of grabbing every IP reported — VMs running Docker/Podman
  # report dozens of bridge/veth IPs that aren't the actual host-facing
  # address. Uses python3 (already present on any Debian-based Proxmox
  # host) rather than jq, to avoid a new dependency.
  local id="$1"
  shift
  local macs=("$@")
  [[ ${#macs[@]} -eq 0 ]] && return 1

  timeout 10 qm guest cmd "$id" network-get-interfaces 2>/dev/null | python3 -c '
import json, sys
macs = [m.lower() for m in sys.argv[1:]]
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(1)
by_mac = {i.get("hardware-address", "").lower(): i for i in data}
for mac in macs:
    iface = by_mac.get(mac)
    if not iface:
        continue
    for addr in iface.get("ip-addresses", []):
        if addr.get("ip-address-type") == "ipv4":
            print(addr["ip-address"])
            sys.exit(0)
sys.exit(1)
' "${macs[@]}"
}

print_section "LXC containers"
print_header
if command -v pct &>/dev/null; then
  pct list 2>/dev/null | awk 'NR>1{print $1, $2, $NF}' | while read -r id status name; do
    mac="$(pct config "$id" 2>/dev/null | grep -oP 'net\d+:.*hwaddr=\K[0-9A-Fa-f:]{17}' | head -1)"
    [[ -z "$mac" ]] && mac="-"

    if [[ "$status" == "running" ]]; then
      ip="$(timeout 5 pct exec "$id" -- hostname -I 2>/dev/null | tr -s ' \n' ' ' | sed 's/[[:space:]]*$//')"
      [[ -z "$ip" ]] && ip="(sin IP)"
    else
      ip="($status)"
    fi

    print_row "$id" "$name" "$ip" "$mac" "$status"
  done
else
  echo "(pct no encontrado — no es un host Proxmox?)"
fi

echo
print_section "VMs"
print_header
if command -v qm &>/dev/null; then
  qm list 2>/dev/null | awk 'NR>1{print $1, $2, $3}' | while read -r id name status; do
    mapfile -t macs < <(qm config "$id" 2>/dev/null | grep -oP '^net\d+:\s*[a-zA-Z0-9]+=\K[0-9A-Fa-f:]{17}')
    mac="${macs[0]:--}"

    if [[ "$status" == "running" ]]; then
      ip="$(extract_vm_ip "$id" "${macs[@]}")"
      [[ -z "$ip" ]] && ip="(sin agent/IP)"
    else
      ip="($status)"
    fi

    print_row "$id" "$name" "$ip" "$mac" "$status"
  done
else
  echo "(qm no encontrado — no es un host Proxmox?)"
fi
