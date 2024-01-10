# Notice
This repository is the simplest script to install Proxmox on Raspberry Pi5.
So, I plan to modify the script to be easy to install, like pimox7.


# Pimox8 - Proxmox V8 for the Raspberry Pi 5
Pimox is a port of Proxmox to the Raspberry Pi allowing you to build a Proxmox cluster of Rapberry Pi's or even a hybrid cluster of Pis and x86 hardware.

Requirements
---
* Raspberry Pi 5
* Internet connection via ethernet

Install Automatic Installer
---
1. Flash and startup the latest image from https://downloads.raspberrypi.org/raspios_arm64/ .
2. Run this command
```bash
# change user
$ sudo -s

# download this repository
$ curl https://raw.githubusercontent.com/kta/pimox8/main/RPi5-Arm64-Install.sh > RPi5-Arm64-Install.sh

# edit your param
$ vi RPi5-Arm64-Install.sh
# 'RPI_STATIC_IP': Please edit to your ipaddress
# 'RPI_HOSTNAME': Please edit to your hostname

# change mode
$ chmod +x RPi5-Arm64-Install.sh
# run script
$ ./RPi5-Arm64-Install.sh

```
3. Follow the prompts
* Q1 
  * Please select the mail server configuration type that best meets your needs.
  * I select "Local only"
* Q2 
  * System mail name:
  * I select "OK without changes"
* Q3
  * What would you like to do about it ?  Your options are
  * I select "Y" (install the package maintainer's version)

Notes
---
1. This repository only works on Raspberry pi 5.



# Special Thanks
* https://github.com/jiangcuo/Proxmox-Port
* https://github.com/pimox/pimox7
