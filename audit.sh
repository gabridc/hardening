#!/bin/bash

source binaries_location.sh
source Enumeration/SuidFileVulnerables.sh
source Enumeration/auditd.sh
source Enumeration/network.sh
source Enumeration/firewall.sh
source Enumeration/rsyslog.sh
source Enumeration/crontab.sh
# scp root@<ip>:/root/audit/software_list.csv .
# scp audit.sh root@<ip>:/root/audit/audit.sh

#Documentation: Readme.md


CIS_Version=$1
echo $CIS_Version


function writeHeaderReport {
    echo "Write Header"
fileReport=$(echo $HOSTNAME)_$(date  +%d-%m-%y-%T)
echo "$(echo $HOSTNAME)  Hardening Report" > $fileReport.txt

}

function writeSectionReport {

    echo "" >> $fileReport.txt
    echo "-----------------------------------" >> $fileReport.txt
    echo "-----------------------------------" >> $fileReport.txt
    echo "              $1" >> $fileReport.txt
    echo "-----------------------------------" >> $fileReport.txt
    echo "-----------------------------------" >> $fileReport.txt
}

function writeReport {

    echo "$1;$2;$3;$4"
    echo "$1;$2;$3;$4" >> $fileReport.txt
}



function audit() {

hostname=$(echo $HOSTNAME) | grep localhost

if [[ -z $hostname ]];then
echo "El HOSTNAME no esta cambiado $hostname"
fi

cat /etc/redhat-release > redhat_version.txt

#El espacio antes de %{BUILDTIME} espara luego hacer el awk
rpm -qa --qf '%{NAME};%{VERSION}-%{RELEASE}.%{ARCH};%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}.rpm;%{SOURCERPM}; %{BUILDTIME:date}\n' | awk '{print ""$1" "$3"/"$4"/"$5""}' | sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' -e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g' > software_list.csv

echo "Usuarios con capacidad de login en el sistema" > users.txt
echo "---------------------------------------------" >> users.txt
cat /etc/passwd | grep -v "/sbin/nologin" | grep -v "/bin/false" >> users.txt

echo "Usuarios con capacidad de login por SSH" >> users.txt
echo "---------------------------------------------" >> users.txt
cat /etc/ssh/sshd_config | grep "AllowUsers" >> users.txt

service --status-all > services.txt 

ls -l -R /var/log > log_files.txt


sestatus > selinux.txt

}

function swNotDesired { 
    daemons=("avahi-daemon" "squid" "smb" "dovecot" "httpd" "vsftpd" "named" "nfs" "rpcbind" "slapd" "dhcpd" "cups" "ypserv")
    clients=("telnet" "ypbind" "openldap-clients")
    
    

    if [[ ${#SYSTEMCTL} -gt 0 ]]; then 
        for daemon in "${daemons[@]}"
            do
                res=$($SYSTEMCTL is-enabled "$daemon" 2>&1)

                if [[ "$res" == "enabled"  ]]; then
                    echo "El servicio $daemon esta activo" >> services.txt
                fi
            done
    elif [[ ${#SERVICE} -gt 0 ]]; then
        for daemon in "${daemons[@]}"
            do
                res=$($SERVICE "$daemon" status 2>&1)

                if [[ "$res" == "*is running*"  ]]; then
                    echo "El servicio $daemon esta activo" >> services.txt
                fi
            done
    else
        echo "Systemctl no esta instalado no puede aplicarse el chekceo swNotDesired"
    fi


}

echo "Audit"
audit
swNotDesired
#suidFileExport
auditConfig

echo "TCP Wrapper"
if [[ $CIS_Version -lt 7 ]]; then
tcpWrapper
fi

echo "Networking"
rules
netipv4
echo "Firewall"
firewalldEnabled
echo "NFTables"
#nftablesEnabled
echo "IPTABLES"
if [[ ${#FIREWALL_CMD} -eq 0 ]]; then
    iptablesEnabled
    iptablesRulesDef
fi

echo "SYSLOG"
rsyslogEnabled
rsyslogPermissions
rsyslogRules

echo "CRONTAB"
cronEnabled
cronConfPermissions


writeHeaderReport
echo "**********************************************************"
echo "               $hostname Hardening Report"
echo "**********************************************************"


writeSectionReport "AUDIT RULES"
echo "${auditrulesRes1[0]} * ${auditrulesRes1[1]} * ${auditrulesRes1[2]} * ${auditrulesRes1[3]}"
writeReport "${auditrulesRes1[0]}" "${auditrulesRes1[1]}" "${auditrulesRes1[2]}" "${auditrulesRes1[3]}"
#echo "${auditrulesRes2[0]} * ${auditrulesRes2[1]} * ${auditrulesRes2[2]} * ${auditrulesRes2[3]}"
writeReport "${auditrulesRes2[0]}" "${auditrulesRes2[1]}" "${auditrulesRes2[2]}" "${auditrulesRes2[3]}"
#echo "${auditrulesRes3[0]}" * "${auditrulesRes3[1]}" * "${auditrulesRes3[2]}" * "${auditrulesRes3[3]}"
writeReport "${auditrulesRes3[0]}" "${auditrulesRes3[1]}" "${auditrulesRes3[2]}" "${auditrulesRes3[3]}"
#echo "${auditrulesRes4[0]}" * "${auditrulesRes4[1]}" * "${auditrulesRes4[2]}" * "${auditrulesRes4[3]}"
writeReport "${auditrulesRes4[0]}" "${auditrulesRes4[1]}" "${auditrulesRes4[2]}" "${auditrulesRes4[3]}"
#echo "${auditrulesRes5[0]}" * "${auditrulesRes5[1]}" * "${auditrulesRes5[2]}" * "${auditrulesRes5[3]}"
writeReport "${auditrulesRes5[0]}" "${auditrulesRes5[1]}" "${auditrulesRes5[2]}" "${auditrulesRes5[3]}"
#echo "${auditrulesRes6[0]}" * "${auditrulesRes6[1]}" * "${auditrulesRes6[2]}" * "${auditrulesRes6[3]}"
writeReport "${auditrulesRes6[0]}" "${auditrulesRes6[1]}" "${auditrulesRes6[2]}" "${auditrulesRes6[3]}"
#echo "${auditrulesRes7[0]}" * "${auditrulesRes7[1]}" * "${auditrulesRes7[2]}" * "${auditrulesRes7[3]}"
writeReport "${auditrulesRes7[0]}" "${auditrulesRes7[1]}" "${auditrulesRes7[2]}" "${auditrulesRes7[3]}"
#echo "${auditrulesRes8[0]}" * "${auditrulesRes8[1]}" * "${auditrulesRes8[2]}" * "${auditrulesRes8[3]}"
writeReport "${auditrulesRes8[0]}" "${auditrulesRes8[1]}" "${auditrulesRes8[2]}" "${auditrulesRes8[3]}"
#echo "${auditrulesRes9[0]}" * "${auditrulesRes9[1]}" * "${auditrulesRes9[2]}" * "${auditrulesRes9[3]}"
writeReport "${auditrulesRes9[0]}" "${auditrulesRes9[1]}" "${auditrulesRes9[2]}" "${auditrulesRes9[3]}"
#echo "${auditrulesRes10[0]}" * "${auditrulesRes10[1]}" * "${auditrulesRes10[2]}" * "${auditrulesRes10[3]}"
writeReport "${auditrulesRes10[0]}" "${auditrulesRes10[1]}" "${auditrulesRes10[2]}" "${auditrulesRes10[3]}"
#echo "${auditrulesRes11[0]}" * "${auditrulesRes11[1]}" * "${auditrulesRes11[2]}" * "${auditrulesRes11[3]}"
writeReport "${auditrulesRes11[0]}" "${auditrulesRes11[1]}" "${auditrulesRes11[2]}" "${auditrulesRes11[3]}"
#echo "${auditrulesRes12[0]}" * "${auditrulesRes12[1]}" * "${auditrulesRes12[2]}" * "${auditrulesRes12[3]}"
writeReport "${auditrulesRes12[0]}" "${auditrulesRes12[1]}" "${auditrulesRes12[2]}" "${auditrulesRes12[3]}"
#echo "${auditrulesRes13[0]}" * "${auditrulesRes13[1]}" * "${auditrulesRes13[2]}" * "${auditrulesRes13[3]}"
writeReport "${auditrulesRes13[0]}" "${auditrulesRes13[1]}" "${auditrulesRes13[2]}" "${auditrulesRes13[3]}"
#echo "${auditrulesRes14[0]}" * "${auditrulesRes14[1]}" * "${auditrulesRes14[2]}" * "${auditrulesRes14[3]}"
writeReport "${auditrulesRes14[0]}" "${auditrulesRes14[1]}" "${auditrulesRes14[2]}" "${auditrulesRes14[3]}"
#echo "${auditrulesRes15[0]}" * "${auditrulesRes15[1]}" * "${auditrulesRes15[2]}" * "${auditrulesRes15[3]}"
writeReport "${auditrulesRes15[0]}" "${auditrulesRes15[1]}" "${auditrulesRes15[2]}" "${auditrulesRes15[3]}"

writeSectionReport "NETWORK"
#echo "${netipv4Rest1[0]}" * "${netipv4Rest1[1]}" * "${netipv4Rest1[2]}" * "${netipv4Rest1[3]}"
writeReport "${netipv4Rest1[0]}" "${netipv4Rest1[1]}" "${netipv4Rest1[2]}" "${netipv4Rest1[3]}"
#echo "${netipv4Rest2[0]}" * "${netipv4Rest2[1]}" * "${netipv4Rest2[2]}" * "${netipv4Rest2[3]}"
writeReport "${netipv4Rest2[0]}" "${netipv4Rest2[1]}" "${netipv4Rest2[2]}" "${netipv4Rest2[3]}"
#echo "${netipv4Rest3[0]}" * "${netipv4Rest3[1]}" * "${netipv4Rest3[2]}" * "${netipv4Rest3[3]}"
writeReport "${netipv4Rest3[0]}" "${netipv4Rest3[1]}" "${netipv4Rest3[2]}" "${netipv4Rest3[3]}"
#echo "${netipv4Rest4[0]}" * "${netipv4Rest4[1]}" * "${netipv4Rest4[2]}" * "${netipv4Rest4[3]}"
writeReport "${netipv4Rest4[0]}" "${netipv4Rest4[1]}" "${netipv4Rest4[2]}" "${netipv4Rest4[3]}"
#echo "${netipv4Rest5[0]}" * "${netipv4Rest5[1]}" * "${netipv4Rest5[2]}" * "${netipv4Rest5[3]}"
writeReport "${netipv4Rest5[0]}" "${netipv4Rest5[1]}" "${netipv4Rest5[2]}" "${netipv4Rest5[3]}"
#echo "${netipv4Rest6[0]}" * "${netipv4Rest6[1]}" * "${netipv4Rest6[2]}" * "${netipv4Rest6[3]}"
writeReport "${netipv4Rest6[0]}" "${netipv4Rest6[1]}" "${netipv4Rest6[2]}" "${netipv4Rest6[3]}"
#echo "${netipv4Rest7[0]}" * "${netipv4Rest7[1]}" * "${netipv4Rest7[2]}" * "${netipv4Rest7[3]}"
writeReport "${netipv4Rest7[0]}" "${netipv4Rest7[1]}" "${netipv4Rest7[2]}" "${netipv4Rest7[3]}"
#echo "${netipv4Rest8[0]}" * "${netipv4Rest8[1]}" * "${netipv4Rest8[2]}" * "${netipv4Rest8[3]}"
writeReport "${netipv4Rest8[0]}" "${netipv4Rest8[1]}" "${netipv4Rest8[2]}" "${netipv4Rest8[3]}"
#echo "${netipv4Rest9[0]}" * "${netipv4Rest9[1]}" * "${netipv4Rest9[2]}" * "${netipv4Rest9[3]}"
writeReport "${netipv4Rest9[0]}" "${netipv4Rest9[1]}" "${netipv4Rest9[2]}" "${netipv4Rest9[3]}"
#echo "${netipv4Rest10[0]}" * "${netipv4Rest10[1]}" * "${netipv4Rest10[2]}" * "${netipv4Rest10[3]}"
writeReport "${netipv4Rest10[0]}" "${netipv4Rest10[1]}" "${netipv4Rest10[2]}" "${netipv4Rest10[3]}"
#echo "${netipv4Rest11[0]}" * "${netipv4Rest11[1]}" * "${netipv4Rest11[2]}" * "${netipv4Rest11[3]}"
writeReport "${netipv4Rest11[0]}" "${netipv4Rest11[1]}" "${netipv4Rest11[2]}" "${netipv4Rest11[3]}"
#echo "${netipv4Rest12[0]}" * "${netipv4Rest12[1]}" * "${netipv4Rest12[2]}" * "${netipv4Rest12[3]}"
writeReport "${netipv4Rest12[0]}" "${netipv4Rest12[1]}" "${netipv4Rest12[2]}" "${netipv4Rest12[3]}"
#echo "${netipv4Rest13[0]}" * "${netipv4Rest13[1]}" * "${netipv4Rest13[2]}" * "${netipv4Rest13[3]}"
writeReport "${netipv4Rest13[0]}" "${netipv4Rest13[1]}" "${netipv4Rest13[2]}" "${netipv4Rest13[3]}"
#echo "${netipv4Rest14[0]}" * "${netipv4Rest14[1]}" * "${netipv4Rest14[2]}" * "${netipv4Rest14[3]}"
writeReport "${netipv4Rest14[0]}" "${netipv4Rest14[1]}" "${netipv4Rest14[2]}" "${netipv4Rest14[3]}"
#echo "${netipv4Rest15[0]}" * "${netipv4Rest15[1]}" * "${netipv4Rest15[2]}" * "${netipv4Rest15[3]}"
writeReport "${netipv4Rest15[0]}" "${netipv4Rest15[1]}" "${netipv4Rest15[2]}" "${netipv4Rest15[3]}"

writeSectionReport "FIREWALL"
#echo "${firewalldEnabledRest[0]}" * "${firewalldEnabledRest[1]}" * "${firewalldEnabledRest[2]}" * "${firewalldEnabledRest[3]}"
writeReport "${firewalldEnabledRest[0]}" "${firewalldEnabledRest[1]}" "${firewalldEnabledRest[2]}" "${firewalldEnabledRest[3]}"
#echo "${nftablesEnabledRest[0]}" * "${nftablesEnabledRest[1]}" * "${nftablesEnabledRest[2]}" * "${nftablesEnabledRest[3]}"
writeReport "${nftablesEnabledRest[0]}" "${nftablesEnabledRest[1]}" "${nftablesEnabledRest[2]}" "${nftablesEnabledRest[3]}"
#echo "${iptablesEnabledRest[0]}" * "${iptablesEnabledRest[1]}" * "${iptablesEnabledRest[2]}" * "${iptablesEnabledRest[3]}"
writeReport "${iptablesEnabledRest[0]}" "${iptablesEnabledRest[1]}" "${iptablesEnabledRest[2]}" "${iptablesEnabledRest[3]}"
#echo "${iptablesRulesDefRes[0]}" * "${iptablesRulesDefRes[1]}" * "${iptablesRulesDefRes[2]}" * "${iptablesRulesDefRes[3]}"
writeReport "${iptablesRulesDefRes[0]}" "${iptablesRulesDefRes[1]}" "${iptablesRulesDefRes[2]}" "${iptablesRulesDefRes[3]}"

writeSectionReport "SYSLOG"
#echo "${rsyslogEnabledRest1[0]}" * "${rsyslogEnabledRest1[1]}" * "${rsyslogEnabledRest1[2]}" * "${rsyslogEnabledRest1[3]}"
writeReport "${rsyslogEnabledRest1[0]}" "${rsyslogEnabledRest1[1]}" "${rsyslogEnabledRest1[2]}" "${rsyslogEnabledRest1[3]}"
#echo "${rsyslogEnabledRest2[0]}" * "${rsyslogEnabledRest2[1]}" * "${rsyslogEnabledRest2[2]}" * "${rsyslogEnabledRest2[3]}"
writeReport "${rsyslogEnabledRest2[0]}" "${rsyslogEnabledRest2[1]}" "${rsyslogEnabledRest2[2]}" "${rsyslogEnabledRest2[3]}"
#echo "${rsyslogPermissionsRest1[0]}" * "${rsyslogPermissionsRest1[1]}" * "${rsyslogPermissionsRest1[2]}" * "${rsyslogPermissionsRest1[3]}"
writeReport "${rsyslogPermissionsRest1[0]}" "${rsyslogPermissionsRest1[1]}" "${rsyslogPermissionsRest1[2]}" "${rsyslogPermissionsRest1[3]}"
writeReport "${rsyslogRulesRest1[0]}" "${rsyslogRulesRest1[1]}" "${rsyslogRulesRest1[2]}" "${rsyslogRulesRest1[3]}"
writeReport "${rsyslogRulesRest2[0]}" "${rsyslogRulesRest2[1]}" "${rsyslogRulesRest2[2]}" "${rsyslogRulesRest2[3]}"
writeReport "${rsyslogRulesRest3[0]}" "${rsyslogRulesRest3[1]}" "${rsyslogRulesRest3[2]}" "${rsyslogRulesRest3[3]}"

writeSectionReport "CRONTAB"
writeReport "${cronEnabledRest[0]}" "${cronEnabledRest[1]}" "${cronEnabledRest[2]}" "${cronEnabledRest[3]}"
writeReport "${cronConfPermissionsRest1[0]}" "${cronConfPermissionsRest1[1]}" "${cronConfPermissionsRest1[2]}" "${cronConfPermissionsRest1[3]}"
writeReport "${cronConfPermissionsRest2[0]}" "${cronConfPermissionsRest2[1]}" "${cronConfPermissionsRest2[2]}" "${cronConfPermissionsRest2[3]}"
writeReport "${cronConfPermissionsRest3[0]}" "${cronConfPermissionsRest3[1]}" "${cronConfPermissionsRest3[2]}" "${cronConfPermissionsRest3[3]}"

writeSectionReport "TCP WRAPPERS"
#echo "${tcpWrapperRest1[0]}" * "${tcpWrapperRest1[1]}" * "${tcpWrapperRest1[2]}" * "${tcpWrapperRest1[3]}"
writeReport "${tcpWrapperRest1[0]}" "${tcpWrapperRest1[1]}" "${tcpWrapperRest1[2]}" "${tcpWrapperRest1[3]}"
#echo "${tcpWrapperRest2[0]}" * "${tcpWrapperRest2[1]}" * "${tcpWrapperRest2[2]}" * "${tcpWrapperRest2[3]}"
writeReport "${tcpWrapperRest2[0]}" "${tcpWrapperRest2[1]}" "${tcpWrapperRest2[2]}" "${tcpWrapperRest2[3]}"
#echo "${tcpWrapperRest3[0]}" * "${tcpWrapperRest3[1]}" * "${tcpWrapperRest3[2]}" * "${tcpWrapperRest3[3]}"
writeReport "${tcpWrapperRest3[0]}" "${tcpWrapperRest3[1]}" "${tcpWrapperRest3[2]}" "${tcpWrapperRest3[3]}"
#echo "${tcpWrapperRest4[0]}" * "${tcpWrapperRest4[1]}" * "${tcpWrapperRest4[2]}" * "${tcpWrapperRest4[3]}"
writeReport "${tcpWrapperRest4[0]}" "${tcpWrapperRest4[1]}" "${tcpWrapperRest4[2]}" "${tcpWrapperRest4[3]}"
#echo "${tcpWrapperRest5[0]}" * "${tcpWrapperRest5[1]}" * "${tcpWrapperRest5[2]}" * "${tcpWrapperRest5[3]}"
writeReport "${tcpWrapperRest5[0]}" "${tcpWrapperRest5[1]}" "${tcpWrapperRest5[2]}" "${tcpWrapperRest5[3]}"
#echo "${tcpWrapperRest6[0]}" * "${tcpWrapperRest6[1]}" * "${tcpWrapperRest6[2]}" * "${tcpWrapperRest6[3]}"
writeReport "${tcpWrapperRest6[0]}" "${tcpWrapperRest6[1]}" "${tcpWrapperRest6[2]}" "${tcpWrapperRest6[3]}"
#echo "${tcpWrapperRest7[0]}" * "${tcpWrapperRest7[1]}" * "${tcpWrapperRest7[2]}" * "${tcpWrapperRest7[3]}"
writeReport "${tcpWrapperRest7[0]}" "${tcpWrapperRest7[1]}" "${tcpWrapperRest7[2]}" "${tcpWrapperRest7[3]}"
#echo "${tcpWrapperRest8[0]}" * "${tcpWrapperRest8[1]}" * "${tcpWrapperRest8[2]}" * "${tcpWrapperRest8[3]}"
writeReport "${tcpWrapperRest8[0]}" "${tcpWrapperRest8[1]}" "${tcpWrapperRest8[2]}" "${tcpWrapperRest8[3]}"