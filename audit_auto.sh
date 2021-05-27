#!/bin/bash

source binaries_location.sh


# scp root@<ip>:/root/audit/software_list.csv .
# scp audit.sh root@<ip>:/root/audit/audit.sh

#Documentation: Readme.md


CIS_Version=$1
echo $CIS_Version


scriptsLocation="Enumeration/"
echo  $(ls $scriptsLocation)
for script in $(ls $scriptsLocation)
do
    source ${scriptsLocation}${script}

	while IFS= read line 
	do 
	
		script_parameter=$(echo $line | awk -F "=" '{print $1}')

		echo -e "\n${service};${script_parameter};${!script_parameter}\r" #>> $report/Parameters_value.txt

	done < ${scriptsLocation}${script}



done




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



