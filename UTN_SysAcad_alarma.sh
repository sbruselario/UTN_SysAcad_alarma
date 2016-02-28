#!/bin/bash
#
# sbruselario@frro.utn.edu.ar
#
# Requiere instalado: mpg123 (para reproducir sonido en mp3)
#
#

############################## VARIABLES
alarma="http://d.mimp3.me/d/346248992_504668942/ray-parker-jr-ghostbusters-ost.mp3"
espera=300 #demora en segundos entre consultas para no matar al servidor
VAR1=""
VAR2=""


############################## FUNCIONES
function logo {
	echo -e "\n\n\t   _____            ___                  __   __  _________   __"
	echo -e     "\t  / ___/__  _______/   | _________ _____/ /  / / / /_  __/ | / /"
	echo -e     "\t  \__ \/ / / / ___/ /| |/ ___/ __ '/ __  /  / / / / / / /  |/ / "
	echo -e     "\t ___/ / /_/ (__  ) ___ / /__/ /_/ / /_/ /  / /_/ / / / / /|  /  "
	echo -e     "\t/____/\__, /____/_/  |_\___/\__,_/\__,_/   \____/ /_/ /_/ |_/   "
	echo -e     "\t     /____/   Alarma inscripción cursado+examen	      "
	echo -e "\n\n"
}





############################## MAIN
clear

	logo

	echo -n "Ingrese número de legajo: "
	read LEGAJO
	echo -n "Ingrese contraseña: "
	read -s PASSWORD
	while [[ "$OPCION" != "C" && "$OPCION" != "E" && "$OPCION" != "c" && "$OPCION" != "e" ]] 
	do
		echo -e -n "\n(C)ursado o (E)xamen?: "
		read OPCION
		if [[ ( "$OPCION" == "C" || "$OPCION" == "c" ) ]] 
		then 
			OPC="materiasCursado" 
			OPCTXT="cursado"
		fi
		if [[ ( "$OPCION" == "E" || "$OPCION" == "e") ]] 
		then 
			OPC="materiasExamen" 
			OPCTXT="examen"
		fi
	done
		
while true
do  
  	clear
	logo
	echo -e -n "Legajo:" $LEGAJO "- "
	date
	
	echo -e "\nLogeando..."  
	VAR1=$(wget "http://alumnos.frro.utn.edu.ar/menuAlumno.asp" --post-data "legajo=$LEGAJO&password=$PASSWORD" -q -t 2 --timeout=10 --no-check-certificate --keep-session-cookies --save-cookies /tmp/cookies -O - )


	if [[ ( "$VAR1" == *"ERROR"*  &&  "$VAR1" == *"Facultad Regional Rosario"* ) || ( $LEGAJO == "" ) || ( $PASSWORD == "" ) || ( "$VAR1" !=  *"Facultad Regional Rosario"* ) ]]
	then
		echo -e "\n-->Ups!\n\t-Legajo o contraseña incorrecto?\n\t-Servidor caído?\n\t-Problemas del primer mundo?\n\n"
		exit 1	
	else
		echo -e "Chequeando inscripción a $OPCTXT...\n"  
		VAR2=$(wget "http://alumnos.frro.utn.edu.ar/$OPC.asp?refrescar" -q -t 2 --timeout=10 --no-check-certificate --keep-session-cookies --load-cookies /tmp/cookies -O - )

		if [[ ( "$VAR2" != *"ERROR:"*  &&  "$VAR2" == *"Facultad Regional Rosario"* && "$VAR2" != *"loginbutton"*) ]]
		then
			#pongo a reproducir la alarma
			mpg123 --loop -1 -b 1024 $alarma &>/dev/null &
			#abro SysAcad en el navegador de internet ;)
			xdg-open http://alumnos.frro.utn.edu.ar/ &>/dev/null &
			clear
			logo
			echo -e -n "Legajo:" $LEGAJO "- "
			date
			echo -e "\n\t¡INSCRIPCIONES ABIERTAS!\n\nPresione enter para detener la alarma."
				
			read key
			
				pkill mpg123
				clear
				logo
				echo -e "Buen $OPCTXT!\n" #ponele
				exit 1
						
			exit 1
			
		fi
	fi

	#demora entre consultas 
	for (( c=$espera; c>=-1; c-- ))
	do
		sleep 1
		echo -e -n "\r\033[KNO SE PUEDE INSCRIBIR ----> $c segundos para volver a consultar..."
	done


done

exit 1

