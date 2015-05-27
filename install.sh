#! /bin/bash
#
# Raspberry Pi network configuration / AP, MESH install script
# Sarah Grant
# took guidance from a script by Paul Miller : https://dl.dropboxusercontent.com/u/1663660/scripts/install-rtl8188cus.sh
# Updated 10 May 2015
#
# TO-DO
# - allow a selection of radio drivers
# - fix addressing to avoid collisions below (peek at pirate box)
# - remove dependency on batctl for bat0 interface. currently, bat0 interface is needed for the bridge, should the user decide to set up an AP.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SOME DEFAULT VALUES
#
# BRIDGE
BRIDGE_IP=192.168.3.1
BRIDGE_NETMASK=255.255.255.0

# WIRELESS RADIO DRIVER
RADIO_DRIVER=nl80211

# ACCESS POINT
AP_COUNTRY=US
AP_SSID=subnodes
AP_CHAN=1

# DNSMASQ STUFF
DHCP_START=192.168.3.101
DHCP_END=192.168.3.254
DHCP_NETMASK=255.255.255.0
DHCP_LEASE=1h

# MESH POINT
MESH_SSID=meshnode

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CHECK USER PRIVILEGES
(( `id -u` )) && echo "This script *must* be ran with root privileges, try prefixing with sudo. i.e sudo $0" && exit 1

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# BEGIN INSTALLATION PROCESS
#
echo "////////////////////////"
echo "// Welcome to Subnodes!"
echo "// ~~~~~~~~~~~~~~~~~~~~~"
echo ""

read -p "This installation script will configure your Raspberry Pi as a BATMAN ADV mesh node, wireless access point and web server running Node.js. Make sure you have two USB wifi radios connected to your Raspberry Pi before proceeding. Press any key to continue..."
echo ""
#
# CHECK USB WIFI HARDWARE IS FOUND
# also, i will need to check for one device per network config for a total of two devices
if [[ -n $(lsusb | grep RT5370) ]]; then
    echo "The RT5370 device has been successfully located."
else
    echo "The RT5370 device has not been located, check it is inserted and run script again when done."
    exit 1
fi
# check that iw list does not fail with 'nl80211 not found'
echo -en "checking that nl80211 USB wifi radio is plugged in...				"
iw list > /dev/null 2>&1 | grep 'nl80211 not found'
rc=$?
if [[ $rc = 0 ]] ; then
	echo ""
	echo -en "[FAIL]\n"
	echo "Make sure you are using a wifi radio that runs via the nl80211 driver."
	exit $rc
else
	echo -en "[OK]\n"
fi
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SOFTWARE INSTALL
#
# update the packages
echo "Updating apt-get and installing iw package, batctl, bridge-utils, hostapd and dnsmasq..."
apt-get update && apt-get install -y iw batctl bridge-utils hostapd dnsmasq
echo ""
echo "Installing Node.js..."
wget http://node-arm.herokuapp.com/node_latest_armhf.deb
sudo dpkg -i node_latest_armhf.deb
echo ""
echo "Enabling the batman-adv kernel..."
echo ""
# add the batman-adv module to be started on boot
sed -i '$a batman-adv' /etc/modules
modprobe batman-adv;
echo ""
echo "Please answer the following questions. Hitting return will continue with the default 'No' option"
read -p "Bridge IP [$BRIDGE_IP]: " -e t1
if [ -n "$t1" ]; then BRIDGE_IP="$t1";fi

read -p "Bridge Subnet Mask [$BRIDGE_NETMASK]: " -e t1
if [ -n "$t1" ]; then AP_CHAN="$t1";fi

# ask how they want to configure their mesh point
read -p "Mesh Point SSID [$MESH_SSID]: " -e t1
if [ -n "$t1" ]; then MESH_SSID="$t1";fi

# ask how they want to configure their access point
read -p "Wifi Country [$AP_COUNTRY]: " -e t1
if [ -n "$t1" ]; then AP_COUNTRY="$t1";fi

read -p "Wifi Channel Name [$AP_CHAN]: " -e t1
if [ -n "$t1" ]; then AP_CHAN="$t1";fi

read -p "Wifi SSID [$AP_SSID]: " -e t1
if [ -n "$t1" ]; then AP_SSID="$t1";fi

read -p "DHCP starting address [$DHCP_START]: " -e t1
if [ -n "$t1" ]; then DHCP_START="$t1";fi

read -p "DHCP ending address [$DHCP_END]: " -e t1
if [ -n "$t1" ]; then DHCP_END="$t1";fi

read -p "DHCP netmask [$DHCP_NETMASK]: " -e t1
if [ -n "$t1" ]; then DHCP_NETMASK="$t1";fi

read -p "DHCP length of lease [$DHCP_LEASE]: " -e t1
if [ -n "$t1" ]; then DHCP_LEASE="$t1";fi

# create hostapd init file
echo -en "Creating default hostapd file...			"
cat <<EOF > /etc/default/hostapd
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF
rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	echo ""
	exit $rc
else
	echo -en "[OK]\n"
fi

# create hostapd configuration with user's settings
echo -en "Creating hostapd.conf file...				"
cat <<EOF > /etc/hostapd/hostapd.conf
interface=ap0
bridge=br0
driver=$RADIO_DRIVER
country_code=$AP_COUNTRY
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHAN
beacon_int=100
auth_algs=1
wpa=0
macaddr_acl=0
wmm_enabled=1
ap_isolate=1
EOF
rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	exit $rc
else
	echo -en "[OK]\n"
fi

# backup the existing interfaces file
echo -en "Creating backup of network interfaces configuration file... 			"
cp /etc/network/interfaces /etc/network/interfaces.bak
rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	exit $rc
else
	echo -en "[OK]\n"
fi

# CONFIGURE /etc/network/interfaces
echo -en "Creating new network interfaces configuration file with your settings... 	"
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

iface ap0 inet static
	address 10.0.0.1
	netmask 255.255.255.0

# create bridge
iface br0 inet static
  bridge_ports bat0 ap0
  bridge_stp off
  address $BRIDGE_IP
  netmask $BRIDGE_NETMASK

iface default inet dhcp
EOF
rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	echo ""
	exit $rc
else
	echo -en "[OK]\n"
fi

# CONFIGURE dnsmasq
echo -en "Creating dnsmasq configuration file... 			"
cat <<EOF > /etc/dnsmasq.conf
interface=br0
address=/#/$BRIDGE_IP
address=/apple.com/0.0.0.0
dhcp-range=$DHCP_START,$DHCP_END,$DHCP_NETMASK,$DHCP_LEASE
EOF
rc=$?
if [[ $rc != 0 ]] ; then
	echo -en "[FAIL]\n"
	echo ""
	exit $rc
else
	echo -en "[OK]\n"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# COPY OVER THE SUBNODES START UP SCRIPT + enable services
#
clear
update-rc.d hostapd enable
update-rc.d dnsmasq enable
cp scripts/subnodes.sh /etc/init.d/subnodes
chmod 755 /etc/init.d/subnodes
update-rc.d subnodes defaults

# INSTALLING node.js chat room
echo "Installing chat room..."
# go back to our subnodes directory
cd /home/pi/subnodes/

# download subnodes app dependencies
sudo npm install
sudo npm install -g nodemon
echo "Done!"

read -p "Do you wish to reboot now? [N] " yn
	case $yn in
		[Yy]* )
			reboot;;
		Nn]* ) exit 0;;
	esac
