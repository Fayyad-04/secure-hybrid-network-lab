# secure-hybrid-network-lab
This project builds and operates a secure hybrid network for a fictional small business. It will cover network segmentation, cloud connectivity, infrastructure automation, monitoring, and recovery.

Current milestone: build a local segmented network and verify employee, guest, and administrator access policies.

Current stage: Packet Tracer office-network simulation. VLAN segmentation, inter-VLAN routing, and IPv4 access controls are implemented. Connectivity and access-policy tests are documented as passing. SSH management, cloud connectivity, automation, monitoring, and recovery remain planned.

## Project documentation

- [Rebuild the Packet Tracer lab](docs/lab-setup.md): topology, device connections, IP addressing, VLAN creation, routing, ACLs, verification, and rollback.
- [Connectivity tests and evidence](docs/connectivity-test.md): baseline and post-ACL results, configuration screenshots, and pending browser captures.
- [Router configuration](configs/R1-running-config.txt) and [switch configuration](configs/SW1-running-config.txt).
- [Packet Tracer project](labs/packet-tracer/office-network-v1.pkt).

The original Packet Tracer application version still needs to be recorded in the rebuild guide. Browser screenshots remain pending; the test document distinguishes recorded outcomes from uploaded evidence.
