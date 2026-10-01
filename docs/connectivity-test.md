# Connectivity Tests

## Routing Baseline — Before ACLs

The purpose of this test is to verify that inter-VLAN routing is
working correctly before implementing access control lists (ACLs).

R1's four VLAN gateway subinterfaces were verified as up/up.

### Router Interface Verification

The following screenshot confirms that the VLAN subinterfaces on R1
are operational.

![R1 VLAN subinterfaces](../labs/evidence/router-interface.png)

### Connectivity Results

| Source | Destination | Test | Expected | Actual |
|---|---|---|---|---|
| Employee PC | 10.77.10.1 | Ping | Success | Passed, 0% loss |
| Employee PC | 10.77.40.10 | Ping | Success | Passed, 0% loss |
| Guest PC | 10.77.20.1 | Ping | Success | Passed, 0% loss |
| Guest PC | 10.77.40.10 | Ping | Success | Passed, 0% loss |
| Admin PC | 10.77.30.1 | Ping | Success | Passed, 0% loss |
| Admin PC | 10.77.40.10 | Ping | Success | Passed, 0% loss |

### Employee Connectivity Evidence

![Employee connectivity test](../labs/evidence/EMPLOYEE-ping.png)

### Guest Connectivity Evidence

![Guest connectivity test](../labs/evidence/GUEST-ping.png)

### Admin Connectivity Evidence

![Admin connectivity test](../labs/evidence/ADMIN-ping.png)

### Result

All three PCs successfully reached their respective default gateways
and the web server at 10.77.40.10.

Before ACLs were applied, guest-to-server ping succeeded. After ACLs were applied, guest access was blocked as recorded below..

This establishes the routing baseline before security restrictions
are applied.

## After applying ACLs

| Source | Test | Expected | Actual |
|---|---|---|---|
| Employee | HTTP to 10.77.40.10 | Page loads | Page loads |
| Employee | Ping 10.77.10.1 | Success | Success |
| Employee | Ping 10.77.40.10 | Blocked | Blocked |
| Employee | Ping 10.77.30.10 | Blocked | Blocked |
| Guest | HTTP to 10.77.40.10 | Fails | Fails |
| Guest | Ping 10.77.20.1 | Success | Success |
| Guest | Ping 10.77.40.10 | Blocked | Blocked |
| Guest | Ping 10.77.10.10 | Blocked | Blocked |
| Guest | Ping 10.77.30.10 | Blocked | Blocked |
| Admin | HTTP to 10.77.40.10 | Page loads | Page loads |
| Admin | Ping 10.77.40.10 | Success | Success |

### Verified configuration

- EMPLOYEE-IN is applied inbound on R1 Gi0/0.10.
- GUEST-IN is applied inbound on R1 Gi0/0.20.
- Permit and deny counters show matching traffic.
- R1 configuration was saved to startup-config.

### Current limitations

- IPv4 ACLs filter traffic entering R1 from employee and guest VLANs.
- Traffic within the same VLAN does not pass through these ACLs.
- Administrator and server VLANs do not yet have inbound ACLs.
- Internet connectivity and cloud integration are not implemented.
