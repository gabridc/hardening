#!/bin/bash

#BINARIES
FIREWALL_CMD=$(which firewall-cmd)
SYSTEMCTL=$(which systemctl)
IPTABLES=$(which iptables)
RPM=$(which rpm)
STAT=$(which stat)
SERVICE=$(which service)
JOURNALCTL=$(which journalctl)
CROND=$(which crond)


#FILES

auditRulesLocation=$(whereis audit.rules | awk '{print $2}') 