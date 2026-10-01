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

Before ACLs were applied, guest-to-server ping succeeded. After ACLs were applied, guest access was blocked as recorded below.

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

### ACL configuration evidence

The screenshots below document rule matches and where the ACLs are applied. Match counters support verification of traffic filtering; they do not identify every test or prove that an HTTP page rendered.

![R1 extended ACL rules and match counters](../labs/evidence/Access-lists.png)

![EMPLOYEE-IN applied inbound on R1 Gi0/0.10](../labs/evidence/Employee-In.png)

![GUEST-IN applied inbound on R1 Gi0/0.20 and configuration saved](../labs/evidence/Guest-In.png)

### Browser evidence — capture pending

The results in the table above are the lab author's recorded observations. Separate screenshots of employee HTTP success, guest HTTP failure, and admin HTTP success have not yet been uploaded. The existing ping screenshots belong to the pre-ACL baseline.

Capture these from the current secured Packet Tracer lab:

1. Keep HTTP enabled on WEB-SERVER. From each PC, open **Desktop > Web Browser**, enter `http://10.77.40.10`, and click **Go** to issue a fresh request.
2. Capture the device name, address bar, and loaded page or failure message together. A previously displayed page is not evidence of a fresh successful request.
3. For the guest test, wait for the request to fail. Compare with a fresh successful employee/admin request so a stopped HTTP service is not mistaken for ACL enforcement. Check `show access-lists` after the guest request.
4. Save and upload the following PNG files into `labs/evidence/` using Windows/GitHub, not the router CLI:

| Screenshot filename | Expected observation | Evidence status |
|---|---|---|
| employee-http-allowed.png | Employee loads the server webpage | Pending capture |
| guest-http-blocked.png | Guest request fails | Pending capture |
| admin-http-allowed.png | Admin loads the server webpage | Pending capture |

After uploading the images, replace the pending status and add these Markdown image references below this section. They are shown as code until the files exist, avoiding broken image links:

```markdown
![Employee HTTP request succeeds](../labs/evidence/employee-http-allowed.png)
![Guest HTTP request fails](../labs/evidence/guest-http-blocked.png)
![Admin HTTP request succeeds](../labs/evidence/admin-http-allowed.png)
```

### Current limitations

- IPv4 ACLs filter traffic entering R1 from employee and guest VLANs.
- Traffic within the same VLAN does not pass through these ACLs.
- Administrator and server VLANs do not yet have inbound ACLs.
- Internet connectivity and cloud integration are not implemented.

For reconstruction steps, see the [Packet Tracer rebuild guide](lab-setup.md).
