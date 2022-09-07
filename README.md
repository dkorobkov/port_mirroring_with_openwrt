# port_mirroring_with_openwrt
A quick HOWTO for port mirroring with OpenWRT on Atheros

The task was to intercept Ethernet communications of industrial sensor. The slight difference from standard packet capture cases is that this setup had to be fully transparent, not changing packets TTL, or NATing, or routing. More, preliminary information about sensor IP address etc was unavailable so preconfiguring a capture device was not an option. I had to quickly reconnect the sensor through my device so that interception was unnoticed.

<table>
  <tr><img src="https://github.com/dkorobkov/port_mirroring_with_openwrt/blob/master/0.jpg">
<tr><img src="https://github.com/dkorobkov/port_mirroring_with_openwrt/blob/master/01.png">
<tr><img src="https://github.com/dkorobkov/port_mirroring_with_openwrt/blob/master/1.png">
</table>

One option for the setup was to build a passive hub as described e.g. here: https://www.eeweb.com/circuit-projects/building-a-passive-ethernet-hub

<img src="https://github.com/dkorobkov/port_mirroring_with_openwrt/blob/master/2.gif">

This won't work in my case as connecting cable was very long and weakening signal was unacceptable.

Using a simple unmanaged switch won't work because packets from sensor to server do not appear on the port where sniffer is connected. This is a well known problem and a workaround for it is to use port mirroring (usually available in L2 managed switches) or an ancient hub, hardly available nowadays. L2 switch is too big and too expensive.

Luckily, I had an old $15 TP-Link TL-WR740N that can run OpenWRT and is based on Atheros AR9331 that has a built-in switch with port mirroring. Main problem was to set it up so it does not interfere communications.

If OpenWRT does not fit into router memory it is possible to remove LuCI and use serial or SSH console. I am using 
serial console (3.3V 115200). 

eth1 is WAN (blue) port, eth0 is 5-port switch with 4 external (yellow) ports and one port connected to CPU internally.

## Steps:

1. Install OpenWRT 18.06.7 (others will work, too)

2. Disable firewall (easier) or set it up to have access to LuCI and console from WAN (eth1) port. Connect a laptop that will be used as OpenWRT console to router WAN (blue) port and ensure that console is available over SSH. It will also be better to disable IPv6 (prevents ICMP noise from router)

>root@OpenWrt:/# /etc/init.d/firewall stop

3. In LuCI, set LAN interface to "Unmanaged". This will prevent assigning IP addresses or any visibility problems:
<img src="https://github.com/dkorobkov/port_mirroring_with_openwrt/blob/master/3.png">

4. In console, use swconfig dev eth0 show to check which physical port corresponds to which logical one. I had 2,3,4,1 instead of 1,2,3,4 embossed on router housing. (swconfig is SWitch CONFIGurator, obviously we apply it to device eth0) To check, connect your laptop to one yellow port by one and repeat the command to see "link:up" or "link:down":
<img src="https://github.com/dkorobkov/port_mirroring_with_openwrt/blob/master/4.png">
Port 0 is CPU and is not available from outside.

5. Choose the port to connect your Wireshark and set it up. I chose port 2:

>root@OpenWrt:/# swconfig dev eth0 set enable_vlan 0
>
>root@OpenWrt:/# swconfig dev eth0 set mirror_monitor_port 2

Connect a laptop with Wireshark to this port.

6. Choose the port to mirror (we will connect DUT, Device Under Testing to this port). I chose port 4:

>root@OpenWrt:/# swconfig dev eth0 set port 4 enable_mirror_rx 1
>
>root@OpenWrt:/# swconfig dev eth0 set port 4 enable_mirror_tx 1

<img src="https://github.com/dkorobkov/port_mirroring_with_openwrt/blob/master/5.png">

7. Connect your device to port 4 and server to any free LAN port. Run  swconfig dev eth0 show and reinitialize any values set above if needed (sometimes the switch will feel link up/down and probably reconfigure itself. I did not waste time on making these settings permanent).

8. Enjoy.

More on networking CLI can be found in https://openwrt.org/docs/guide-user/base-system/basic-networking

