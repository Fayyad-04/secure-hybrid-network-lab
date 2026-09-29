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

Guest-to-server communication is currently allowed because ACL-based
access restrictions have not yet been implemented.

This establishes the routing baseline before security restrictions
are applied.
