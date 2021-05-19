#!/bin/bash
sudo su root
mkdir /tmp/cyberAudit
cd /tmp/cyberAudit/
git clone https://github.com/gabridc/hardening.git
git clone https://github.com/gabridc/pentesting-tools.git
mkdir Enumeration
cp pentesting-tools/Enumeration/*.sh Enumeration/
sed -i -e 's/\r$//' *.sh && sed -i -e 's/\r$//' Enumeration/*.sh



