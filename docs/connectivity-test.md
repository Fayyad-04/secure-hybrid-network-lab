# Connectivity Tests

## Routing Baseline — Before ACLs

The purpose of this test is to verify that inter-VLAN routing is
working correctly before implementing access control lists (ACLs).

R1's four VLAN gateway subinterfaces were verified as up/up.

| Source      | Destination | Test | Expected | Actual          |
| Employee PC | 10.77.10.1  | Ping | Success  | Passed, 0% loss |
| Employee PC | 10.77.40.10 | Ping | Success  | Passed, 0% loss |
| Guest PC    | 10.77.20.1  | Ping | Success  | Passed, 0% loss |
| Guest PC    | 10.77.40.10 | Ping | Success  | Passed, 0% loss |
| Admin PC    | 10.77.30.1  | Ping | Success  | Passed, 0% loss |
| Admin PC    | 10.77.40.10 | Ping | Success  | Passed, 0% loss |

### Result

All three PCs successfully reached their respective default gateways
and the web server at 10.77.40.10.

Guest-to-server communication is currently allowed because ACL-based
access restrictions have not yet been implemented.

This establishes a working routing baseline that can be compared with
the results after ACLs are configured.
