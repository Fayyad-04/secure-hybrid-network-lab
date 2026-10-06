# Restricted SSH Administration

## Objective

Allow the administrator workstation at 10.77.30.10 to manage R1
and SW1 through SSH. Restrict remote terminal access by source IP
and disable Telnet on both devices' VTY lines.

This milestone was implemented in Cisco Packet Tracer 9.0.1.0858.

## Management settings

| Setting | Value |
|---|---|
| Router management address used for testing | 10.77.30.1 |
| Switch management address (VLAN 30 SVI) | 10.77.30.2/24 |
| Switch default gateway | 10.77.30.1 |
| Authorized workstation | 10.77.30.10 |
| SSH username | netadmin |
| Account privilege level | 15 |
| SSH version | 2 |
| Authentication timeout | 60 seconds |
| Authentication retries | 2 |
| Idle session timeout | 5 minutes |
| VTY access list | SSH-ADMIN |

## R1 configuration procedure

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

## R1 verification procedure

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

## R1 recorded results

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

## R1 evidence

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

## SW1 SSH management

The [SW1 running-config export](../configs/SW1-running-config.txt)
records VLAN 30's management SVI at `10.77.30.2 255.255.255.0`,
default gateway `10.77.30.1`, domain `lab.example`, SSH version 2,
authentication timeout 60 seconds, and two authentication retries.
Both VTY ranges (`0 4` and `5 15`) contain `login local`,
`transport input ssh`, `access-class SSH-ADMIN in`, and
`exec-timeout 5 0`. The standard `SSH-ADMIN` ACL permits host
`10.77.30.10` and denies all other sources.

### Verified login and privilege

The lab author verified SSH from ADMIN-PC (`10.77.30.10`) to SW1
using `netadmin`. Authentication went directly to `SW1#`, without
an intervening `enable` command, and `show privilege` returned
`Current privilege level is 15`.

To repeat the check from ADMIN-PC, run `ipconfig` to confirm the
source address, then `ssh -l netadmin 10.77.30.2` and authenticate.
The following records the command and output reported by the lab
author; it is not a newly captured transcript:

```text
SW1#show privilege
Current privilege level is 15
```

The existing screenshot shows an initial failed authentication
attempt, followed by a successful SSH login and commands executed
at `SW1#`. It does not display ADMIN-PC's source address or
`show privilege`; those details come from the lab author's report.

![SW1 authorized SSH login and remote commands](../labs/evidence/sw1-ssh-admin-allowed.png)

### Packet Tracer running-config observation

The lab author reports that SW1 accepted this configuration command
without an error (replace the placeholder with a unique lab-only password):

```text
username netadmin privilege 15 secret YOUR_LAB_PASSWORD
```

However, Packet Tracer's SW1 running-config continued to omit the
explicit `privilege 15` keyword. The published export preserves that
observed form, with the credential hash redacted:

```text
username netadmin secret 5 <REDACTED>
```

Do not insert `privilege 15` into the export to make it resemble the
entered command. The direct `SW1#` login and reported privilege check
establish the tested session's privilege level. This is an observation
of this lab's Packet Tracer behavior; it does not establish a general
IOS default or explain why the keyword is omitted.

### Other recorded SW1 results

| Test | Screenshot observation | Evidence |
|---|---|---|
| SSH from temporary management address 10.77.30.11 | Source IP displayed; connection refused | [Unauthorized source](../labs/evidence/sw1-ssh-unauthorized-ip-denied.png) |
| SSH from EMPLOYEE-PC, 10.77.10.10 | Source IP displayed; connection timed out | [Employee attempt](../labs/evidence/sw1-ssh-employee-denied.png) |
| SSH from GUEST-PC, 10.77.20.10 | Source IP displayed; connection timed out | [Guest attempt](../labs/evidence/sw1-ssh-guest-denied.png) |
| Telnet to 10.77.30.2 (ADMIN-PC per evidence filename) | Displays Open, then closes without a login prompt; source IP is not shown | [Telnet attempt](../labs/evidence/sw1-telnet-admin-denied.png) |

The employee and guest timeouts alone do not identify the blocking
rule: R1's inbound interface ACLs also restrict those VLANs. The
`10.77.30.11` test exercises an unauthorized source on the management
subnet. After repeating that test, restore ADMIN-PC to `10.77.30.10`
and verify SSH again; a separate SW1 restoration test is not shown
in the existing evidence.

## Scope and limitations

- This milestone covers remote administration of R1 and SW1.
- The VTY ACL restricts source addresses; it does not bind SSH
  exclusively to the tested destination addresses.
- A source-IP restriction alone does not establish device identity.
- The lab uses local authentication and a full-privilege administrator
  account. Centralized authentication and finer authorization are
  future improvements.
- The tests were performed by the lab author in Packet Tracer and
  were not independently rerun during this documentation update.

## Saved artifacts

R1's configuration was saved with
`copy running-config startup-config`.

The Packet Tracer project must also be saved through File > Save.
Configuration exports published to GitHub must have credentials
and password hashes redacted.

SW1's export is a sanitized record of running-config, not proof that
startup-config or the `.pkt` file contains the same state. After making
SW1 changes, run `copy running-config startup-config` and save the
Packet Tracer project. Persistence across a reload has not been verified
in the supplied evidence. Redacted exports are documentation, not
ready-to-paste credential configuration; configure a new lab-only secret
with the username command rather than pasting `<REDACTED>`.
