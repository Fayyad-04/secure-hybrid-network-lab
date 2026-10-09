# secure-hybrid-network-lab
This project builds and operates a secure hybrid network for a fictional small business. It will cover network segmentation, cloud connectivity, infrastructure automation, monitoring, and recovery.

Current milestone: office-network segmentation, restricted management, and a documented controlled trunk-outage recovery exercise.

Current stage: Packet Tracer office-network simulation. VLAN segmentation, inter-VLAN routing, IPv4 access controls, and restricted SSH administration of R1 and SW1 are implemented. Connectivity and access-policy tests are documented as passing. A controlled VLAN 40 trunk-outage recovery exercise is documented. Cloud connectivity, automation, monitoring, and broader recovery capabilities remain planned.

## Project documentation

- [Controlled trunk-outage incident report](docs/incidents/001-server-vlan-trunk-outage.md): fault diagnosis, repair, recovery validation, and evidence limitations. Recovery duration was not measured.

- [Rebuild the Packet Tracer lab](docs/lab-setup.md): topology, device connections, IP addressing, VLAN creation, routing, ACLs, verification, and rollback.
- [Connectivity tests and evidence](docs/connectivity-test.md): baseline and post-ACL results, configuration screenshots, and browser and ping evidence.
- [Router configuration](configs/R1-running-config.txt) and [switch configuration](configs/SW1-running-config.txt).
- [Packet Tracer project](labs/packet-tracer/office-network-v1.pkt).

Packet Tracer version: **9.0.1.0858** . Browser and post-ACL ping screenshots are linked in the test document. The updated guest screenshot confirms that its own gateway responds while pings to the server, employee, and admin hosts are blocked.

- [Restricted SSH administration](docs/ssh-management.md): restricted administrator access to R1 and SW1, SSH configuration, verification evidence, and the SW1 export limitation.
