# Rebuild the Packet Tracer office network

This guide reconstructs the current IPv4 office-network simulation from a blank Packet Tracer workspace. It is based on the saved configurations and project test records; this guide has not yet been independently replayed in Packet Tracer.

## Prerequisites and version

- Cisco Packet Tracer on Windows.
- Original Packet Tracer application version: **9.0.1.0858**, recorded by the lab author. The IOS versions in the configuration exports are not the Packet Tracer application version.
- Devices: one Cisco **1941** router (R1), one **2960** switch (SW1), three PC-PT devices, and one Server-PT.
- R1's exported configuration identifies a Cisco 1941. Earlier planning suggested a 2911; this guide follows the actual router export.
- To inspect the existing simulation instead, download and open [office-network-v1.pkt](../labs/packet-tracer/office-network-v1.pkt). Its current saved state must be verified in Packet Tracer.

Commands in the device sections go in that device's **CLI** tab. Repository paths such as `configs/R1-running-config.txt` are filenames on GitHub or your computer, not router commands. If prompted for the initial configuration dialog, answer `no`. Press Enter to accept the filename after `copy running-config startup-config`.

## 1. Place and connect devices

Rename the devices as shown. Use copper straight-through cables.

| Device and interface | SW1 interface |
|---|---|
| R1 GigabitEthernet0/0 | GigabitEthernet0/1 |
| EMPLOYEE-PC FastEthernet0 | FastEthernet0/1 |
| GUEST-PC FastEthernet0 | FastEthernet0/2 |
| ADMIN-PC FastEthernet0 | FastEthernet0/3 |
| WEB-SERVER FastEthernet0 | FastEthernet0/4 |

```text
                     R1 (1941)
                       Gi0/0
                         |
                  802.1Q trunk
                         |
                       Gi0/1
                     SW1 (2960)
          Fa0/1     Fa0/2     Fa0/3     Fa0/4
            |        |         |         |
         Employee  Guest     Admin    Web server
          VLAN 10 VLAN 20    VLAN 30    VLAN 40
```

## 2. Configure SW1

Create the VLANs explicitly. Port assignments in a running-config export alone are not a complete replacement for the switch's VLAN database.

```text
enable
configure terminal
hostname SW1
vlan 10
 name EMPLOYEES
exit
vlan 20
 name GUEST
exit
vlan 30
 name MANAGEMENT
exit
vlan 40
 name SERVERS
exit
interface fastEthernet0/1
 description EMPLOYEE-PC
 switchport mode access
 switchport access vlan 10
exit
interface fastEthernet0/2
 description GUEST-PC
 switchport mode access
 switchport access vlan 20
exit
interface fastEthernet0/3
 description ADMIN-PC
 switchport mode access
 switchport access vlan 30
exit
interface fastEthernet0/4
 description WEB-SERVER
 switchport mode access
 switchport access vlan 40
exit
interface gigabitEthernet0/1
 description TRUNK-TO-R1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40
 no shutdown
exit
end
copy running-config startup-config
```

An access port carries one VLAN for its attached device. The trunk carries VLANs 10, 20, 30, and 40 to R1. VLAN 1 remains the default native VLAN; the four lab VLANs are tagged.

## 3. Configure R1's VLAN gateways

```text
enable
configure terminal
hostname R1
interface gigabitEthernet0/0
 description LINK-TO-SW1
 no shutdown
exit
interface gigabitEthernet0/0.10
 description EMPLOYEES-GATEWAY
 encapsulation dot1Q 10
 ip address 10.77.10.1 255.255.255.0
exit
interface gigabitEthernet0/0.20
 description GUEST-GATEWAY
 encapsulation dot1Q 20
 ip address 10.77.20.1 255.255.255.0
exit
interface gigabitEthernet0/0.30
 description MANAGEMENT-GATEWAY
 encapsulation dot1Q 30
 ip address 10.77.30.1 255.255.255.0
exit
interface gigabitEthernet0/0.40
 description SERVERS-GATEWAY
 encapsulation dot1Q 40
 ip address 10.77.40.1 255.255.255.0
exit
end
copy running-config startup-config
```

Each subinterface is associated with its VLAN by `encapsulation dot1Q`. The physical interface has no IP address. All four networks are directly connected, so no static routes are required between them.

## 4. Configure endpoint addresses

On each endpoint, open **Desktop > IP Configuration > Static**. Leave DNS unset for these IP-based tests.

| Device | VLAN | IP address | Subnet mask | Default gateway |
|---|---|---|---|---|
| EMPLOYEE-PC | 10 | 10.77.10.10 | 255.255.255.0 | 10.77.10.1 |
| GUEST-PC | 20 | 10.77.20.10 | 255.255.255.0 | 10.77.20.1 |
| ADMIN-PC | 30 | 10.77.30.10 | 255.255.255.0 | 10.77.30.1 |
| WEB-SERVER | 40 | 10.77.40.10 | 255.255.255.0 | 10.77.40.1 |

## 5. Verify the baseline and enable HTTP

On SW1, run `show vlan brief` and `show interfaces trunk`. Verify access-port assignments and that Gi0/1 is trunking with all four VLANs forwarding.

On R1, run `show ip interface brief` and `show ip route`. All four VLAN subinterfaces should be up/up, with a connected route for each /24 subnet.

On each PC, open **Desktop > Command Prompt** and ping its gateway and `10.77.40.10`. Before ACLs, all should succeed. Repeat an initial ping if ARP resolution causes a transient loss; investigate persistent failures.

On WEB-SERVER, open **Services > HTTP** and set HTTP to **On**. Keep the default page. On each PC, open **Desktop > Web Browser**, enter `http://10.77.40.10`, and click **Go**. All three should load the page before ACLs. Record results before continuing; do not apply restrictions to hide an existing connectivity failure.

## 6. Apply the access policy on R1

Employees may access only the server's HTTP service and ping their own gateway. Guests may ping their own gateway; other IPv4 traffic entering R1 from guests is denied. There is no internet uplink in this lab.

```text
enable
configure terminal
ip access-list extended EMPLOYEE-IN
 permit tcp 10.77.10.0 0.0.0.255 host 10.77.40.10 eq 80
 permit icmp 10.77.10.0 0.0.0.255 host 10.77.10.1 echo
 deny ip any any
exit
ip access-list extended GUEST-IN
 permit icmp 10.77.20.0 0.0.0.255 host 10.77.20.1 echo
 deny ip any any
exit
interface gigabitEthernet0/0.10
 ip access-group EMPLOYEE-IN in
exit
interface gigabitEthernet0/0.20
 ip access-group GUEST-IN in
exit
end
copy running-config startup-config
```

The wildcard `0.0.0.255` matches the source /24 subnet. Rules are evaluated in order. `in` filters traffic as it enters R1 from that VLAN. Server HTTP replies enter through VLAN 40 and do not traverse the employee inbound ACL. The ACL display may show `www` instead of port `80`; these are equivalent here.

These are stateless IPv4 filters. They do not isolate devices within the same VLAN or provide a complete stateful firewall. Management and server VLANs have no inbound ACLs at this checkpoint.

## 7. Test and save

Follow the complete [connectivity test matrix](connectivity-test.md). Expected highlights:

- Employee HTTP to the server succeeds, but employee ping to the server fails.
- Guest HTTP and ping to the server fail; guest gateway ping succeeds.
- Admin HTTP and ping to the server succeed.

On R1, run:

```text
show access-lists
show ip interface gigabitEthernet0/0.10
show ip interface gigabitEthernet0/0.20
```

Confirm the inbound ACL names and counter changes after fresh requests. Counters alone do not prove that a browser rendered a page.

Save the .pkt file using **File > Save**. Saving startup-config inside a simulated device does not replace saving the Packet Tracer project file.

For readable configuration exports, run `show running-config` in privileged EXEC mode (`R1#` or `SW1#`), page through the complete output, and copy it into a text file outside the device CLI. Review credentials before publishing. See the saved [R1 export](../configs/R1-running-config.txt) and [SW1 export](../configs/SW1-running-config.txt).

## Troubleshooting and rollback

- A `>` prompt is user EXEC mode; enter `enable` before `show running-config`.
- A red router uplink may mean Gi0/0 is shut down. Check the cable endpoints and `no shutdown`.
- If inter-VLAN traffic fails before ACLs, check IP addresses, masks, gateways, VLAN memberships, trunk allowed VLANs, and subinterface tags.
- If employee HTTP fails after ACLs, confirm HTTP is enabled, use `http://`, check the inbound ACL association and permit counter, and verify the server gateway.
- Use the local R1 CLI to detach the ACLs temporarily if you need to reproduce the unrestricted baseline:

```text
enable
configure terminal
interface gigabitEthernet0/0.10
 no ip access-group EMPLOYEE-IN in
exit
interface gigabitEthernet0/0.20
 no ip access-group GUEST-IN in
exit
end
```

Detaching the ACLs restores unrestricted routing between these networks. Reapply the two `ip access-group` commands from step 6, retest, and save before treating the secured checkpoint as restored.

## Evidence and remaining work

See [connectivity tests](connectivity-test.md) for recorded outcomes, linked browser and ping screenshots, including verified guest host-ping evidence. SSH administration, cloud connectivity, automation, monitoring, and recovery remain future milestones.
