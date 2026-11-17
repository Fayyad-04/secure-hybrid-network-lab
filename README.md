# secure-hybrid-network-lab
This project builds and operates a secure hybrid network for a fictional small business. It will cover network segmentation, cloud connectivity, infrastructure automation, monitoring, and recovery.

Current milestone: Packet Tracer segmentation and recovery exercise completed; real VM baseline tested; AWS EC2-to-OPNsense WireGuard connectivity verified with HTTP access to WEB01 and a logged SSH denial.

Current stage: real VM lab in progress. OPNsense separates management and server Internal Networks. WEB01 serves HTTP and accepts key-only SSH from ADMIN01. Specific IPv4 access and deny paths have been tested; AWS EC2 now reaches WEB01 over WireGuard on TCP 80, while a TCP 22 attempt is blocked. IPv6 policy, broader firewall review, tested restoration, cloud cost verification, automation, and monitoring remain open.

## Project documentation

- [AWS hybrid connectivity with WireGuard](docs/aws-wireguard-lab.md): topology, sanitized settings, handshake and route output, tunnel ping screenshot, HTTP 200 result, logged SSH denial, and resolved setup issues.

- [ADMIN01 network recovery](docs/incidents/002-admin01-netplan-ipv4-failure.md): diagnosed Netplan/DHCP configuration conflict, repaired static IPv4, and verified address, route, and SSH access after reboot.

- [Real VM lab](docs/real-vm-lab.md): topology, current firewall policy, WEB01 services and SSH hardening, verification levels, and open checks.

- [Controlled trunk-outage incident report](docs/incidents/001-server-vlan-trunk-outage.md): fault diagnosis, repair, recovery validation, and evidence limitations. Recovery duration was not measured.

- [Rebuild the Packet Tracer lab](docs/lab-setup.md): topology, device connections, IP addressing, VLAN creation, routing, ACLs, verification, and rollback.
- [Connectivity tests and evidence](docs/connectivity-test.md): baseline and post-ACL results, configuration screenshots, and browser and ping evidence.
- [Router configuration](configs/R1-running-config.txt) and [switch configuration](configs/SW1-running-config.txt).
- [Packet Tracer project](labs/packet-tracer/office-network-v1.pkt).

Packet Tracer version: **9.0.1.0858** . Browser and post-ACL ping screenshots are linked in the test document. The updated guest screenshot confirms that its own gateway responds while pings to the server, employee, and admin hosts are blocked.

- [Restricted SSH administration](docs/ssh-management.md): restricted administrator access to R1 and SW1, SSH configuration, verification evidence, and the SW1 export limitation.
