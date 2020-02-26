#!/bin/bash

echo "220 My Server Simple Mail Transfer Service Ready"
echo 'Login : '
read user
echo 'Password : ' 
read pass


while read line;
do 
	ligne=( $line )
	user=${user:0:-1}
	pass=${pass:0:-1}
	echo $ligne
	echo $user
	echo ${ligne[1]}
	echo $pass
	
	if [ "$ligne" = "$user" ] 
	then
		if [ "${ligne[1]}" = "$pass" ]
		then
			while read -d $'\r' line; 
			do
				# split into an array
				args=( $line )
				if [ ${args^^} = "HELO" ]
				then
					if [ ${args[1]} -z ]
					then
						echo "501 Syntax: HELO hostname"
					else
						etat="helo"
						identity=${args[1]}
						echo "250 My Server"
					fi
				elif [ ${args^^} = "QUIT" ]
				then
					echo "221 2.0.0 Bye"
					exit
				elif [ ${args^^} = "MAIL" ]
				then
					ligne=${args[1]}
					partie1=${ligne:0:4}
					partie1=${partie1^^}
					partie2=${ligne:4}
					partie1+=$partie2
					ligne=$partie1
					if [[ $ligne == "FROM:<"?*">" || $ligne == "FROM:<>" ]]
					then
						sender=${ligne:6:-1}
						echo "250 2.1.0 $sender Sender Ok"
						etat="mail"

					elif [ $etat = "mail" ]
					then
						echo "503 5.5.1 Error: nested MAIL command"
		
					else
						echo "501 5.5.4 Syntax: MAIL FROM:<address>"
					fi
		
				elif [ ${args^^} = "RCPT" ] 
				then
					ligne=${args[1]}
					partie1=${ligne:0:2}
					partie1=${partie1^^}
					partie2=${ligne:2}
					partie1+=$partie2
					ligne=$partie1
					if [[ $ligne == "TO:<"?*">" || $ligne == "TO:<>" ]]
					then
						if [ $etat = "mail" ]
						then
							from=${ligne:4:-1}
							if [[ $from == ?*"@"?*"."?* ]]
							then
								etat="rcpt"
								personne=$(echo $from | cut -f1 -d@)
								domaine=$(echo $from | cut -f2 -d@)

								if [[ $domaine = "condaminet.tp.info.unicaen.fr" ]]
								then
									mailPourNous=true
									if [ -d "/home/"$personne ]
									then
										mkdir "/home/"$personne"/maildir/" 2>/dev/null
										adresseDEcriture="/home/"$personne"/maildir/"`date +%s`".txt"
									fi
								elif [[ $domaine = "tpmail.info.unicaen.fr" ]]
								then
									adresseDEcriture="/var/tmp.txt"					
								fi
					
								echo "250 2.1.5 $from Receiver Ok"
							else
								echo "550 5.1.1 Invalid recipient."
							fi
						else
							echo "503 5.5.0 need MAIL before RCPT"
						fi
					else
						echo "501 5.5.2 syntax error in parameters scanning"
					fi	
		
				elif [ ${args^^} = "DATA" ]
				then
					if [ $etat = "rcpt" ]
					then
						date=$(date +%c)
						ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
						echo "FROM" $sender $date > $adresseDEcriture
						echo "Return-path: <"$sender">" >> $adresseDEcriture
						echo "Envelope-to: "$from >> $adresseDEcriture
						echo "Delevery-date: "$date >> $adresseDEcriture
						echo "Received: from ["$ip"]"
						echo "by" $HOSTNAME "with smtp" >> $adresseDEcriture
						echo "(envelope-from <"$sender">)" >> $adresseDEcriture
						echo "for "$from";"$date >> $adresseDEcriture
						echo "354 enter mail, end with '.' on a line by itself"

						while read -d $'\r' line; do
							if [ $line = "." ]
							then
								if [ $line = ".." ]
								then
									echo "." >> $adresseDEcriture
								else
									echo "250 2.0.0 mail accepted for delivery"
									etat="helo"
									break
								fi
							else
								echo $line >> $adresseDEcriture
							fi
						done
						if [[ $domaine = "tpmail.info.unicaen.fr" ]]
						then
							compteur=0
							(sleep 3
							echo "helo"$identity
							sleep 1
							echo "MAIL FROM:<"$sender">"
							sleep 1
							echo "RCPT TO:<"$from">"
							sleep 1
							echo "DATA"
							sleep 1
							while read line  
							do   
								if [ $compteur -gt 7 ]
								then
									echo -e "$line"  
								fi
								compteur=$compteur+1
							done < file.txt
							echo ".") | telnet tpmail.info.unicaen.fr 25
							echo "mail transfered"
						fi
					elif [ $etat = "helo" ]
					then 
						echo "503 5.5.0 need MAIL before DATA"
					elif [ $etat = "mail" ]
					then
						echo "503 5.5.0 need RCPT before DATA"
					else
						echo "503 5.5.0 polite people say HELO first"
					fi
				elif [ ${args^^} = "HELP" ]
				then
					if [ ${args[1]} -z ]
					then
						echo "214 serveur SMTP"
						echo "214 list of command:"
						echo "214  HELO	 MAIL 	RCPT 	DATA"
						echo "214  HELP	 RSET 	VRFY 	NOOP"
					else
						echo "504  HELP topic unknown"
			
					fi
				elif [ ${args^^} = "RSET" ]
				then
					rm $adresseDEcriture
					etat = "debut"
				elif [ ${args^^} = "VRFY" ]
				then
					if [ ${args[1]} -z ]
					then
						echo "501 Syntax: VRFY user"
					else
						if [ -d "/home/"${args[1]} ]
						then
							echo " existe mais je ne connais pas le code"
						else
							echo "252 user doesn't exist"
						fi
					fi
				elif [ ${args^^} = "NOOP" ]
				then
					echo "250 2.0.0 Ok"
				else
					echo "502 5.5.2 Error: command not recognized";
				fi
			done
			exit
		else
			echo "Invalid password for user "$user
			exit
		fi
	fi
done < temp.txt
echo "Unknown user"

