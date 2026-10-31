# Real VM lab: firewall, management, and web server

Status: in progress. This is a separate implementation from the Packet Tracer simulation. The tests below cover specific IPv4 paths; they do not establish complete network segmentation or IPv6 policy.

## Topology and addressing

VirtualBox uses Internal Networks for the management and server segments. No tagged VLANs are configured in this phase.

| System | Interface / network | Address | Role |
| --- | --- | --- | --- |
| OPNsense 26.7 (fw01.lab.example) | em0 / VirtualBox NAT | DHCP, observed 10.0.2.15/24 | WAN |
| OPNsense | em1 / LAB-MGMT | 10.77.30.1/24 | Management gateway and DNS |
| OPNsense | em2 / LAB-SERVERS | 10.77.40.1/24 | Server gateway and DNS |
| Ubuntu ADMIN01-LAB | enp0s3 / LAB-MGMT | 10.77.30.10/24 | Administration workstation |
| Ubuntu Server 24.04.5 LTS WEB01 | enp0s3 / LAB-SERVERS | 10.77.40.10/24 | Nginx and SSH server |

ADMIN01's terminal hostname remains `ubuntu` and its local user is `fayyad`. WEB01's hostname is `web01` and its administrative user is `labadmin`. ADMIN01 and OPNsense were user-confirmed at 4 GB RAM and 2 vCPUs each. WEB01 was planned for 2 GB RAM and 2 vCPUs; those settings were not independently checked. WEB01 has a new 25 GB virtual disk with LVM; approximately 11.5 GB remains unallocated within the volume group.

On 31 October 2026, the user inspected ADMIN01's VirtualBox network settings: Adapter 1 is attached to Internal Network `LAB-MGMT`, MAC `08:00:27:f9:79:23`; Adapters 2, 3, and 4 are disabled. This confirms no additional enabled NAT adapter in the inspected settings.

## ADMIN01 network recovery

On 30 October 2026, ADMIN01's IPv4 activation failure was repaired by disabling a stale installer Netplan file and explicitly setting DHCPv4 to false. Pasted output confirmed manual IPv4, 10.77.30.10/24, and the default route via 10.77.30.1. The user confirmed normal SSH to WEB01, then confirmed the address, route, and SSH access persisted after reboot without manual activation. See the [incident report](incidents/002-admin01-netplan-ipv4-failure.md) for diagnostics, repair commands, and evidence limitations. The earlier alternate-source attempt returned network-unreachable while ADMIN01 had no IPv4 address; that attempt did not validate a firewall block. A later test with restored connectivity is recorded below.

## Firewall policy currently configured

On the SERVERS interface, enabled inbound IPv4 rules for source `10.77.40.10/32` allow DNS to `10.77.40.1/32` on TCP/UDP 53, TCP web traffic to destinations outside the `PRIVATE_NETS` alias on ports in `WEB_PORTS`, and UDP NTP to destinations outside `PRIVATE_NETS` on port 123. The intended aliases are RFC 1918 ranges for `PRIVATE_NETS` and 80/443 for `WEB_PORTS`; the user inspected both stored aliases and confirmed those types and contents. The web and NTP rules were moved from floating rules to ordinary SERVERS rules and then visually checked. On 28 October 2026, the user confirmed all three SERVERS rules remain enabled and in the intended order.

On LAN, the intended exceptions allow ADMIN01 to reach WEB01 on TCP 80 and TCP 22. A following rule blocks other LAN to SERVERS IPv4 traffic. Existing broad LAN IPv4 and IPv6 allow rules remain below these rules. The SSH connection works. On 28 October 2026, the user inspected the LAN rule order and exact addresses and confirmed they match the intended policy.

These rules allow WEB01 to reach any non-private IPv4 web or NTP destination, rather than a fixed package-mirror list. On 31 October 2026, the user ran `ip -6 addr show scope global` and `ip -6 route` on ADMIN01 and WEB01. Both global-address commands returned no addresses; each route output contained only `fe80::/64` on enp0s3. This does not demonstrate routed IPv6 connectivity between the segments. The broad LAN IPv6 allow rule remains configured and the IPv6 policy still needs review before enabling IPv6.

## Services and access

WEB01 was installed offline after an initial mirror DNS failure. Its static address, default route, and DNS were checked after installation. Nginx and curl were installed; a local service/HTTP check was user-confirmed. ADMIN01 received HTTP 200 and the Nginx welcome page from WEB01.

APT initially rejected repository metadata as “not valid yet” because WEB01's clock lagged by days. After the NTP rule was added and `systemd-timesyncd` restarted, a screenshot showed a synchronized clock, IPv4 time server `91.189.91.157`, and received packets. `apt update` then succeeded and reported 21 upgradable packages. A full package upgrade was not confirmed.

OpenSSH was installed on WEB01. ADMIN01 created a dedicated Ed25519 key at `~/.ssh/web01_lab_ed25519`; `ssh-copy-id` reported one key added. Public-key-only login succeeded. The WEB01 SSH drop-in is `/etc/ssh/sshd_config.d/00-lab-hardening.conf` with:

```text
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
AllowUsers labadmin
```

The user confirmed the expected effective settings from `sshd -T`. On 28 October 2026, the user confirmed `sshd -t` and reload completed as expected, a new key-only login succeeded, and a password-only attempt was rejected without an account-password prompt. The existing session was kept open during these checks. The private key and passphrase must remain off GitHub.

## Verification recorded so far

| Test | Result and evidence level |
| --- | --- |
| ADMIN01 to WEB01 TCP 80 | HTTP 200 and Nginx welcome page, screenshot seen in the prior session |
| ADMIN01 to WEB01 ICMP | 100% loss; firewall log matched the LAN-to-SERVERS block, screenshot seen in the prior session |
| WEB01 DNS and package downloads | Successful after SERVERS rule correction, screenshots seen in the prior session |
| WEB01 to OPNsense management HTTPS at 10.77.30.1 | Timeout and matching firewall block, previously user-confirmed |
| WEB01 NTP | Synchronized over IPv4, screenshot seen in the prior session |
| ADMIN01 to WEB01 SSH | Initial login and later new key-only login, user-confirmed |
| ADMIN01 network persistence | Static address, default route, and SSH to WEB01 passed after reboot, user-confirmed on 30 October 2026 |
| WEB01 password-only SSH | Rejected after SSH reload, user-confirmed on 28 October 2026 |
| ADMIN01 and WEB01 IPv6 baseline | No global IPv6 addresses; each showed only an enp0s3 `fe80::/64` route, user-pasted on 31 October 2026 |
| ADMIN01 temporary source 10.77.30.20 to WEB01 TCP 22 | Source route via 10.77.30.1 confirmed; SSH timed out; user subsequently found a matching block in OPNsense Live View on 31 October 2026. Temporary address removed; output showed only 10.77.30.10/24 afterward. This tests source-address matching on the same VM, not a separate host. |

“Screenshot seen” describes prior interactive evidence, not an evidence file committed to this repository. The alternate-source SSH test from ADMIN01 is user-confirmed. Tests from a separate unauthorized VM and firewall management access remain pending. A routable IPv6 test is not applicable to the observed VM configuration, but the IPv6 rule policy remains open for review.

## Next checks

1. Review LAN defaults and IPv6 rule policy. The user confirmed the intended alias contents and LAN/SERVERS IPv4 rule order on 28 October 2026; neither ADMIN01 nor WEB01 had a global IPv6 address on 31 October 2026.
2. Test SSH from a separate unauthorized VM when one is available. The temporary ADMIN01 source-address test passed on 31 October 2026.
3. Record the final OPNsense disk size. ADMIN01's additional adapters were confirmed disabled on 31 October 2026.
4. Apply and verify outstanding OS updates, then back up configuration and practice recovery.
5. Add cloud connectivity, automation, and monitoring as separate, tested phases.

Record sanitized configuration exports and carefully selected evidence only after checking for passwords, private keys, credential hashes, and other sensitive material.
