# Incident 002: ADMIN01 IPv4 activation failure

## Outcome and scope

Resolved and reboot-tested on 30 October 2026 (user session date, Asia/Kuala_Lumpur). ADMIN01 regained its static address, default route, and SSH access to WEB01. The user confirmed all three persisted after reboot without manually activating the connection. Recovery duration was not measured.

This was an unplanned configuration problem encountered during preparation for an alternate-source SSH firewall test. That test remains incomplete: “Network is unreachable” was not evidence of an OPNsense block.

## Symptoms and evidence

The initial SSH attempt to 10.77.40.10 returned:

```text
ssh: connect to host 10.77.40.10 port 22: Network is unreachable
```

WEB01 was also reported powered off at that point. Subsequent investigation found a separate ADMIN01 configuration failure.

User-pasted command output established:

- enp0s3 had UP and LOWER_UP flags, with current MAC 08:00:27:f9:79:23.
- No IPv4 address was assigned to enp0s3; only the loopback IPv4 address appeared, and no IPv4 routes were reported.
- NetworkManager showed an externally connected enp0s3 connection, while the saved netplan-enp0s3 profile was inactive.
- The saved profile contained 10.77.30.10/24 and gateway 10.77.30.1, but ipv4.method was auto.
- Activating it failed with “IP configuration could not be reserved.”
- NetworkManager logs repeatedly showed a DHCPv4 transaction with a 45-second timeout, followed by ip-config-unavailable and no lease.

Diagnostic commands:

```bash
ip -br link
ip -br -4 addr
ip -4 route
nmcli device status
nmcli connection show
nmcli -f ipv4.method,ipv4.addresses,ipv4.gateway,ipv4.may-fail,ipv6.method,ipv6.may-fail connection show netplan-enp0s3
sudo journalctl -b --no-pager -n 60 NM_CONNECTION=1eef7e45-3b9d-3043-bee3-fc5925c90273 + NM_DEVICE=enp0s3
```

The pasted journal showed October 29 local timestamps; the VM's timezone and clock agreement were not established for this incident. Those timestamps are not used to calculate duration.

## Configuration cause

Three Netplan files were present:

| File | Relevant settings |
| --- | --- |
| 00-installer-config.yaml | enp0s3 DHCPv4/DHCPv6 enabled, set-name enp0s3, old MAC match 08:00:27:25:f0:89 |
| 01-network-manager-all.yaml | Global NetworkManager renderer |
| 90-NM-1eef7e45-3b9d-3043-bee3-fc5925c90273.yaml | enp0s3 static IPv4 address, gateway and DNS; initially no explicit dhcp4: false |

Netplan merges definitions from differently named YAML files. Adding a static address in a later file does not, by itself, override dhcp4: true from an earlier file. This explains the combined DHCP and static-address profile. See [Netplan's multiple-file processing rules](https://netplan.readthedocs.io/en/stable-0.106/netplan-generate/).

The old MAC match was another stale setting removed by disabling the installer file; its independent contribution to the failure was not isolated. The logs directly establish DHCP timeouts, not an IPv4 duplicate-address event or an IPv6 timeout.

An earlier attempt to change ipv4.method to manual with nmcli did not produce a lasting manual profile: the next inspection still reported auto. The exact mechanism of that unsuccessful change was not captured. The effective repair addressed the underlying Netplan files.

## Repair performed

Commands were run from ADMIN01's terminal inside its VirtualBox console.

First, back up the configuration and remove the stale installer file from the active .yaml set:

```bash
sudo cp -a /etc/netplan "/root/netplan-backup-$(date +%Y%m%d-%H%M%S)"
sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.disabled
```

Then explicitly disable DHCPv4 and inspect the merged Ethernet definition:

```bash
sudo netplan set ethernets.enp0s3.dhcp4=false
sudo netplan get ethernets.enp0s3
```

The pasted output confirmed NetworkManager, match: {}, address 10.77.30.10/24, DNS and gateway 10.77.30.1, and dhcp4: false. DHCPv6 remained enabled.

Generate and apply:

```bash
sudo netplan generate && sudo netplan apply
```

Netplan emitted gateway4 deprecation warnings but completed. The route installed successfully. Migration to routes syntax remains a maintenance task.

## Recovery validation

Before reboot, the user pasted:

```text
manual
enp0s3           UP             10.77.30.10/24
default via 10.77.30.1 dev enp0s3 proto static metric 100
10.77.30.0/24 dev enp0s3 proto kernel scope link src 10.77.30.10 metric 100
```

Normal SSH access from ADMIN01 to labadmin@10.77.40.10 then succeeded, as reported by the user.

After exiting SSH, saving open work, and rebooting ADMIN01, the user confirmed:

1. enp0s3 retained 10.77.30.10/24.
2. The default route remained via 10.77.30.1.
3. A fresh SSH login to WEB01 succeeded without manual connection activation.

The validation used:

```bash
ip -br -4 addr show dev enp0s3
ip -4 route
ssh -o ConnectTimeout=10 -o IdentityAgent=none -o IdentitiesOnly=yes -i ~/.ssh/web01_lab_ed25519 labadmin@10.77.40.10
```

Pre-reboot configuration and logs are user-pasted evidence. SSH success and post-reboot checks are user confirmations, not independently captured screenshots. A requested gateway ping result was not separately reported.

## Recovery safeguards and follow-up

The original files remain in the timestamped /root/netplan-backup-* directory on ADMIN01, and the old installer file remains as .yaml.disabled. These backups were not uploaded. Restoring the entire old configuration would also restore the known conflict; inspect the backup before using it for recovery.

- Resume the alternate-source SSH test only with ADMIN01, OPNsense, and WEB01 running and normal SSH working.
- Pair a failed test connection with the matching firewall log before recording a firewall-policy pass.
- Replace deprecated gateway4 syntax in a separate change and verify the default route afterward.
- Review IPv6 policy separately; this repair does not establish IPv6 segmentation.
- For future network changes, inspect the merged Netplan configuration and include a reboot test when persistence matters.

Related: [Real VM lab](../real-vm-lab.md).
