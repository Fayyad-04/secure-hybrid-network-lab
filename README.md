# secure-hybrid-network-lab
This project builds and operates a secure hybrid network for a fictional small business. It will cover network segmentation, cloud connectivity, infrastructure automation, monitoring, and recovery.

Current milestone: build a local segmented network and verify employee, guest, and administrator access policies.

Current stage: Packet Tracer office-network simulation. VLAN segmentation, inter-VLAN routing, and IPv4 access controls are implemented. Connectivity and access-policy tests are documented as passing. Cloud connectivity, automation, monitoring, and recovery remain planned.

## Project documentation

- [Rebuild the Packet Tracer lab](docs/lab-setup.md): topology, device connections, IP addressing, VLAN creation, routing, ACLs, verification, and rollback.
- [Connectivity tests and evidence](docs/connectivity-test.md): baseline and post-ACL results, configuration screenshots, and browser and ping evidence.
- [Router configuration](configs/R1-running-config.txt) and [switch configuration](configs/SW1-running-config.txt).
- [Packet Tracer project](labs/packet-tracer/office-network-v1.pkt).

Packet Tracer version: **9.0.1.0858** (recorded by the lab author). Browser and post-ACL ping screenshots are linked in the test document. The updated guest screenshot confirms that its own gateway responds while pings to the server, employee, and admin hosts are blocked.

- [Restricted SSH administration](docs/ssh-management.md): administrator-only access to R1, SSH configuration, and verification evidence.
