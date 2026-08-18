#!/usr/bin/env bash
# Run on a Proxmox VE host. Lists every LXC container and VM with its
# ID, name, and IP (if reachable) in a table, one section per guest type.
set -uo pipefail

SEP="────────────────────────────────────────────────────"

print_header() {
  printf "%-6s %-20s %-25s\n" "ID" "NAME" "IP"
  echo "$SEP"
}

echo "LXC containers"
echo "$SEP"
print_header
if command -v pct &>/dev/null; then
  pct list 2>/dev/null | awk 'NR>1{print $1, $2, $NF}' | while read -r id status name; do
    if [[ "$status" == "running" ]]; then
      ip="$(timeout 5 pct exec "$id" -- hostname -I 2>/dev/null | tr -s ' \n' ' ' | sed 's/[[:space:]]*$//')"
      [[ -z "$ip" ]] && ip="(sin IP)"
    else
      ip="($status)"
    fi
    printf "%-6s %-20s %-25s\n" "$id" "$name" "$ip"
  done
else
  echo "(pct no encontrado — no es un host Proxmox?)"
fi

echo
echo "$SEP"
echo "VMs"
echo "$SEP"
print_header
if command -v qm &>/dev/null; then
  qm list 2>/dev/null | awk 'NR>1{print $1, $2, $3}' | while read -r id name status; do
    if [[ "$status" == "running" ]]; then
      ip="$(timeout 5 qm guest cmd "$id" network-get-interfaces 2>/dev/null \
        | grep -oP '"ip-address":"\K[^"]+' | grep -v '^127\.' | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
      [[ -z "$ip" ]] && ip="(sin agent/IP)"
    else
      ip="($status)"
    fi
    printf "%-6s %-20s %-25s\n" "$id" "$name" "$ip"
  done
else
  echo "(qm no encontrado — no es un host Proxmox?)"
fi
