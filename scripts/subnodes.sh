#!/bin/sh
# /etc/init.d/subnodes_ap
# starts up ap0 interface and hostapd for broadcasting a wireless network

NAME=subnodes
DESC="Brings up mesh and wireless access point for connecting to web server running on the device."
DAEMON_PATH=/home/pi/$NAME
DAEMONOPTS="sudo NODE_ENV=production nodemon subnode.js"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
PHY_AP="phy0"
PHY_MESH="phy1"

	case "$1" in
		start)
			echo "Starting $NAME access point..."
			# bring down hostapd + dnsmasq to ensure wlan0 is brought up first
			service hostapd stop
			service dnsmasq stop
			
			# associate the ap0 interface to a physical devices
			iw phy $PHY_AP interface add ap0 type __ap

			# associate mesh0 interface to a second physical device
			iw phy $PHY interface add mesh0 type adhoc
			ifconfig mesh0 mtu 1532
			iwconfig mesh0 mode ad-hoc essid SSID ap 02:12:34:56:78:90 channel 3
			ifconfig mesh0 down

			# add the interface to batman
			batctl if add mesh0
			batctl ap_isolation 1

			# bring up the BATMAN adv interface
			ifconfig mesh0 up
			ifconfig bat0 up

			# start the hostapd and dnsmasq services
			service hostapd restart
			service dnsmasq restart

			# start the node.js chat application
			cd $DAEMON_PATH
			PID=`$DAEMONOPTS > /dev/null 2>&1 & echo $!`
			#echo "Saving PID" $PID " to " $PIDFILE
				if [ -z $PID ]; then
					printf "%s\n" "Fail"
				else
					echo $PID > $PIDFILE
					printf "%s\n" "Ok"
				fi
			;;
		status)
			printf "%-50s" "Checking $NAME..."
			if [ -f $PIDFILE ]; then
				PID=`cat $PIDFILE`
				if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
					printf "%s\n" "Process dead but pidfile exists"
				else
					echo "Running"
				fi
			else
				printf "%s\n" "Service not running"
			fi
		;;
		stop)
			printf "%-50s" "Shutting down $NAME..."
				PID=`cat $PIDFILE`
				cd $DAEMON_PATH
			if [ -f $PIDFILE ]; then
				kill -HUP $PID
				printf "%s\n" "Ok"
				rm -f $PIDFILE
			else
				printf "%s\n" "pidfile not found"
			fi

			ifconfig br0 down
			ifconfig bat0 down
			ifconfig ap0 down
			ifconfig mesh0 down

			service hostapd stop
            service dnsmasq stop
		;;

		restart)
			$0 stop
			$0 start
		;;

*)
		echo "Usage: $0 {status|start|stop|restart}"
		exit 1
esac
