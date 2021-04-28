#!/bin/bash

# scp root@<ip>:/root/audit/software_list.csv .
# scp audit.sh root@<ip>:/root/audit/audit.sh


function audit(){

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

host=$(echo $HOSTNAME)
rm *zip
zip -q $host *.txt *.csv

}

audit