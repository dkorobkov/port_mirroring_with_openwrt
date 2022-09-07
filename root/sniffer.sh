#!/bin/sh
#/etc/init.d/firewall stop
/sbin/swconfig dev eth0 set enable_vlan 0
/sbin/swconfig dev eth0 set mirror_monitor_port 2
/sbin/swconfig dev eth0 port 4 set enable_mirror_rx 1
/sbin/swconfig dev eth0 port 4 set enable_mirror_tx 1
/sbin/swconfig dev eth0 show

