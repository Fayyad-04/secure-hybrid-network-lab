# secure-hybrid-network-lab
This project builds and operates a secure hybrid network for a fictional small business. It will cover network segmentation, cloud connectivity, infrastructure automation, monitoring, and recovery.

Current milestone: Packet Tracer segmentation and recovery exercise completed; real VM firewall, management, and web-server baseline built and tested.

Current stage: real VM lab in progress. OPNsense separates management and server Internal Networks. WEB01 serves HTTP and accepts key-only SSH from ADMIN01. Specific IPv4 access and deny paths have been tested; IPv6 policy, broader firewall review, backups, cloud connectivity, automation, and monitoring remain planned.

## Project documentation

- [ADMIN01 network recovery](docs/incidents/002-admin01-netplan-ipv4-failure.md): diagnosed Netplan/DHCP configuration conflict, repaired static IPv4, and verified address, route, and SSH access after reboot.

- [Real VM lab](docs/real-vm-lab.md): topology, current firewall policy, WEB01 services and SSH hardening, verification levels, and open checks.

- [Controlled trunk-outage incident report](docs/incidents/001-server-vlan-trunk-outage.md): fault diagnosis, repair, recovery validation, and evidence limitations. Recovery duration was not measured.

- [Rebuild the Packet Tracer lab](docs/lab-setup.md): topology, device connections, IP addressing, VLAN creation, routing, ACLs, verification, and rollback.
- [Connectivity tests and evidence](docs/connectivity-test.md): baseline and post-ACL results, configuration screenshots, and browser and ping evidence.
- [Router configuration](configs/R1-running-config.txt) and [switch configuration](configs/SW1-running-config.txt).
- [Packet Tracer project](labs/packet-tracer/office-network-v1.pkt).

Packet Tracer version: **9.0.1.0858** . Browser and post-ACL ping screenshots are linked in the test document. The updated guest screenshot confirms that its own gateway responds while pings to the server, employee, and admin hosts are blocked.

- [Restricted SSH administration](docs/ssh-management.md): restricted administrator access to R1 and SW1, SSH configuration, verification evidence, and the SW1 export limitation.
