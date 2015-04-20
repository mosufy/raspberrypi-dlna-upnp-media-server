#!/bin/sh -ex
#title				:Rpi_DLNA_UPnP_Media_Server_Setup/install.sh
#description		:This script will make your Rpi as a DLNA/UPnP media server to play your local media
#url				:https://github.com/mosufy/raspberrypi-dlna-upnp-media-server
#author 			:mosufy
#date 				:20150412
#version			:0.1.0
#usage				:sudo bash install.sh

# Raspberry Pi DLNA/UPnP Media Server Installation Script
#
# Make this Raspberry Pi as a DLNA/UPnP media server
# to allow other devices within the same network to
# access your media files using the DLNA/UPnP protocal.
#
# This installation assumes the following:
# - You have a Rapsberry Pi and you want to use it as a DLNA/UPnP media server
# - The Pi is connected to your home network
# - You have already installed Raspbian
#
# Sources
# - http://bbrks.me/rpi-minidlna-media-server/
# - http://www.howtogeek.com/139433/how-to-turn-a-raspberry-pi-into-a-low-power-network-storage-device/
#

if [ ! -f /tmp/raspberrypi-dlna-upnp-media-server/src/Rpi_DLNA_UPnP_Media_Server_Setup/config.conf ]; then
	echo "No config file available: Create config.conf from config_sample.conf"
	exit 1
fi

echo "Updating Raspberyy Pi"
apt-get update && sudo apt-get upgrade -y
echo "Finished updating Raspberyy Pi"

. /tmp/raspberrypi-dlna-upnp-media-server/src/Rpi_DLNA_UPnP_Media_Server_Setup/config.conf
echo "Loaded installation config file"

if [ ! ${MEDIA_MOUNTED} = true ]; then
	if [ ${MEDIA_FILESYSTEMTYPE} = 'ntfs' ]; then
		echo "HDD File System Type of NTFS. Installing ntfs-3g"
		apt-get install ntfs-3g -y

		echo "Mounting external HDD"
		mkdir -p ${MEDIA_MOUNT_DIR}
		sudo chown pi:pi ${MEDIA_MOUNT_DIR}
		mount -t ntfs-3g -o uid=pi,gid=pi /dev/sda1 ${MEDIA_MOUNT_DIR}

		# Adding subnet configuration
		cat >> /etc/fstab <<EOF
/dev/sda1	${MEDIA_MOUNT_DIR}	ntfs-3g	uid=pi,gid=pi 	  0	  0
EOF
		echo "Media will now auto-mount on boot"
	else
		echo "Mounting external HDD"
		mkdir -p ${MEDIA_MOUNT_DIR}
		sudo chown pi:pi ${MEDIA_MOUNT_DIR}
		mount -t vfat -o uid=pi,gid=pi /dev/sda1 ${MEDIA_MOUNT_DIR}

		# Adding subnet configuration
		cat >> /etc/fstab <<EOF
/dev/sda1	${MEDIA_MOUNT_DIR}	vfat	uid=pi,gid=pi 	  0	  0
EOF
		echo "Media will now auto-mount on boot"
	fi
fi

echo "Creating required directory structure on HDD if not exist"

mkdir ${MEDIA_MOUNT_DIR}/MiniDLNA
echo "${MEDIA_MOUNT_DIR}/MiniDLNA created"

mkdir ${MEDIA_MOUNT_DIR}/MiniDLNA/Music
echo "${MEDIA_MOUNT_DIR}/MiniDLNA/Music created"

mkdir ${MEDIA_MOUNT_DIR}/MiniDLNA/Pictures
echo "${MEDIA_MOUNT_DIR}/MiniDLNA/Pictures created"

mkdir ${MEDIA_MOUNT_DIR}/MiniDLNA/Videos
echo "${MEDIA_MOUNT_DIR}/MiniDLNA/Videos created"

echo "Installing minidlna"
apt-get install minidlna -y
echo "Installed minidlna"

sed -i -e "s;media_dir=/var/lib/minidlna;#media_dir=/var/lib/minidlna;" /etc/minidlna.conf
cat >> /etc/minidlna.conf <<EOF

media_dir=A,${MEDIA_MOUNT_DIR}/MiniDLNA/Music
media_dir=P,${MEDIA_MOUNT_DIR}/MiniDLNA/Pictures
media_dir=V,${MEDIA_MOUNT_DIR}/MiniDLNA/Videos
friendly_name=Raspberry Pi
inotify=yes
EOF
echo "Updated /etc/minidlna.conf"

service minidlna start
echo "Started media server service minidlna"

update-rc.d minidlna defaults
echo "minidlna set to start on boot"

service minidlna force-reload
echo "minidlna force-reloaded to rescan media file"

echo "Installing samba for network storage sharing"
apt-get install samba samba-common-bin -y
echo "Finished installing samba"

cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
echo "Backup etc/samba/smb.conf created"

cat >> /etc/samba/smb.conf <<EOF
[MiniDLNA]
comment = DLNA/UPnP Media Server
path = ${MEDIA_MOUNT_DIR}/MiniDLNA
valid users = @users
force group = users
create mask = 0660
directory mask = 0771
read only = no
EOF
echo "Authentication requirement added"

/etc/init.d/samba restart
echo "samba restarted"

useradd -m -p ${SAMBA_PASSWORD} ${SAMBA_USER} -G users
echo "User [${SAMBA_USER}] created"

echo -e "${SAMBA_PASSWORD}\n${SAMBA_PASSWORD}" | smbpasswd -s -a ${SAMBA_USER}
echo "User [${SAMBA_USER}] added as a Samba user"

echo "Installation completed."

exit 0