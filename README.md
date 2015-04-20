# Raspberry Pi MiniDLNA
Allows other UPnP devices (mobile, tv, laptop) within your home network access to your media.

## Pre-requisites
- Rapsberry Pi 2 (Or lower)
- Wireless USB 802.11n Adapter
- Ethernet port to home network
- Raspbian installed

## Pre-installation Instructions
- You have already loaded Raspbian on your SD Card
- Ensure that your Raspberry Pi is connected to the internet
- In order to allow backup, ensure you already have USB drive attached

## Installation Instructions

1. Download and extract zip file

        $ cd /tmp
        $ wget https://github.com/mosufy/raspberrypi-dlna-upnp-media-server/archive/master.zip
        $ sudo unzip raspberrypi-dlna-upnp-media-server-master.zip

2. Create config.conf from config_sample.conf

        $ cd raspberrypi-dlna-upnp-media-server/src/Rpi_DLNA_UPnP_Media_Server_Setup/
        $ sudo cp config_sample.conf config.conf

3. Update config.conf accordingly

        $ sudo vim config.conf

4. Run Install script

        $ sudo bash install.sh

6. To upload media, open My Computer > Network > RASPBERRYPI > MiniDLNA

7. To play media, download DLNA/ UPnP media player.

## Sources
The following sources were used to generate this installation script

- http://bbrks.me/rpi-minidlna-media-server/
- http://www.howtogeek.com/139433/how-to-turn-a-raspberry-pi-into-a-low-power-network-storage-device/