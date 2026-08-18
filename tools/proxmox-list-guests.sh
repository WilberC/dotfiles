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
extract_vm_ip() {
  # Filters the guest agent's network-get-interfaces JSON down to the
  # interface matching one of this VM's real NIC MACs (net0, net1, ...),
  # instead of grabbing every IP reported — VMs running Docker/Podman
  # report dozens of bridge/veth IPs that aren't the actual host-facing
  # address. Uses python3 (already present on any Debian-based Proxmox
  # host) rather than jq, to avoid a new dependency.
  local id="$1"
  mapfile -t macs < <(qm config "$id" 2>/dev/null | grep -oP '^net\d+:\s*[a-zA-Z0-9]+=\K[0-9A-Fa-f:]{17}')
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

if command -v qm &>/dev/null; then
  qm list 2>/dev/null | awk 'NR>1{print $1, $2, $3}' | while read -r id name status; do
    if [[ "$status" == "running" ]]; then
      ip="$(extract_vm_ip "$id")"
      [[ -z "$ip" ]] && ip="(sin agent/IP)"
    else
      ip="($status)"
    fi
    printf "%-6s %-20s %-25s\n" "$id" "$name" "$ip"
  done
else
  echo "(qm no encontrado — no es un host Proxmox?)"
fi
