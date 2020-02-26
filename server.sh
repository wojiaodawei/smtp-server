#!/bin/sh

if [ $# -eq 0 ]
then
	while true
		do nc.traditional -l -p 4567 -e first_contact.sh
	done
else
	if [ $1 = "-pass" ]
	then
		if [ $# -lt 2 ]
		then
			echo "-pass option needs an argument fichier_txt"
			exit
		else
			cat $2 > temp.txt
			while true
				do nc.traditional -l -p 4567 -e first_contact_with_login.sh 
			done
		fi
	fi
fi
