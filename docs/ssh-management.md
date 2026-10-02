# Restricted SSH Administration

## Objective

Allow the administrator workstation at 10.77.30.10 to manage R1
through SSH. Reject remote terminal access from other source IPs
and disable Telnet on R1's VTY lines.

This milestone was implemented in Cisco Packet Tracer 9.0.1.0858.

## Management settings

| Setting | Value |
|---|---|
| Router management address used for testing | 10.77.30.1 |
| Authorized workstation | 10.77.30.10 |
| SSH username | netadmin |
| Account privilege level | 15 |
| SSH version | 2 |
| Authentication timeout | 60 seconds |
| Authentication retries | 2 |
| Idle session timeout | 5 minutes |
| VTY access list | SSH-ADMIN |

## Configuration procedure

These commands are entered in R1's CLI. Replace
`YOUR_LAB_PASSWORD` with a unique lab-only password before running
the username command. The placeholder is not a working credential.

```text
enable
configure terminal
hostname R1
ip domain-name lab.example
username netadmin privilege 15 secret YOUR_LAB_PASSWORD
crypto key generate rsa
```

When prompted for the RSA key size, enter `2048`.

Continue:

```text
ip ssh version 2
ip ssh time-out 60
ip ssh authentication-retries 2

ip access-list standard SSH-ADMIN
 permit host 10.77.30.10
 deny any
exit

line vty 0 4
 login local
 transport input ssh
 access-class SSH-ADMIN in
 exec-timeout 5 0
exit

end
copy running-config startup-config
```

These are setup instructions for a router without an existing SSH
configuration. Do not regenerate existing RSA keys merely to
verify SSH.

## How the restriction works

- `login local` authenticates sessions against R1's local user database.
- `transport input ssh` permits SSH and excludes Telnet on the VTY lines.
- `access-class SSH-ADMIN in` permits remote terminal access only
  from source IP 10.77.30.10.
- `exec-timeout 5 0` closes idle sessions after five minutes.
- The employee and guest interface ACLs remain in place.

The VTY ACL matches the source IP, not the identity of a physical
computer. The username and password provide an additional
authentication requirement.

## Verification procedure

From ADMIN-PC at 10.77.30.10:

```text
ipconfig
ssh -l netadmin 10.77.30.1
```

After authentication, run:

```text
show ip interface brief
exit
```

Then test Telnet:

```text
telnet 10.77.30.1
```

To test the VTY source restriction independently of the employee
and guest interface ACLs:

1. Close the active SSH session.
2. Temporarily change ADMIN-PC's address to 10.77.30.11.
3. Keep the subnet mask and default gateway unchanged.
4. Attempt SSH to 10.77.30.1.
5. Restore ADMIN-PC to 10.77.30.10.
6. Confirm SSH succeeds again.

On R1's local CLI, inspect:

```text
show ip ssh
show access-lists SSH-ADMIN
show running-config
```

## Recorded results

| Test | Expected | Observed |
|---|---|---|
| SSH from 10.77.30.10 | Allowed with valid credentials | Login succeeded; reached R1# |
| Execute a command over SSH | Command succeeds | show ip interface brief displayed router interfaces |
| SSH from temporary address 10.77.30.11 | Rejected | Connection refused |
| Restore 10.77.30.10 and retry SSH | Allowed | Login succeeded |
| Telnet from 10.77.30.10 | No usable login session | Connection immediately closed without a login prompt |
| SSH protocol verification | Version 2 | show ip ssh reports version 2.0 |
| VTY configuration verification | SSH only, restricted source | Required VTY settings confirmed |

Packet Tracer displayed “Open” before closing the Telnet connection.
The observed result is recorded as an immediately closed session.
The `transport input ssh` configuration confirms that only SSH is
allowed on these VTY lines.

## Evidence

### Authorized SSH and Telnet test

The screenshot includes ADMIN-PC's 10.77.30.10 address, a successful
SSH session, remote command execution, and the closed Telnet attempt.

![Authorized SSH and Telnet test](../labs/evidence/ssh-admin-success-telnet.png)

### Unauthorized source test

The lab operator reports that ADMIN-PC temporarily used
10.77.30.11 for this attempt. The screenshot shows the refusal
but does not display the source IP.

![SSH attempt from temporary unauthorized address](../labs/evidence/ssh-unauthorized-source.png)

### SSH settings and ACL counters

Permit and deny counters show matching traffic. Counter values
are packet matches, not counts of successful logins.

![SSH version and management ACL](../labs/evidence/ssh-settings-acl.png)

### VTY configuration

![SSH-only VTY configuration](../labs/evidence/ssh-vty-config.png)

## Scope and limitations

- This milestone covers remote administration of R1 only.
- SW1 management access has not yet been configured.
- The VTY ACL restricts source addresses; it does not bind SSH
  exclusively to R1's 10.77.30.1 destination address.
- A source-IP restriction alone does not establish device identity.
- The lab uses local authentication and a full-privilege administrator
  account. Centralized authentication and finer authorization are
  future improvements.
- The tests were performed by the lab author in Packet Tracer.

## Saved artifacts

R1's configuration was saved with
`copy running-config startup-config`.

The Packet Tracer project must also be saved through File > Save.
Configuration exports published to GitHub must have credentials
and password hashes redacted.
