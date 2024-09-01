RPI_STATIC_IP="192.168.11.101" # edit me
RPI_GATEWAY_IP="192.168.11.1"  # edit me
RPI_HOSTNAME="pve-node1"       # edit me

# password reset
echo '----- update password -----'
passwd

# apt update, upgrade
apt update
apt upgrade -y

# set hostname
echo "${RPI_STATIC_IP} ${RPI_HOSTNAME}.proxmox.com ${RPI_HOSTNAME}" >>/etc/hosts

# set static ip
printf "auto lo
iface lo inet loopback

iface eth0 inet manual

auto vmbr0
iface vmbr0 inet static
        address $RPI_STATIC_IP/24
        gateway $RPI_GATEWAY_IP
        bridge-ports eth0
        bridge-stp off
        bridge-fd 0 \n" >>/etc/network/interfaces

# prepare for Proxmox VE installation
echo 'deb [arch=arm64] https://de.mirrors.apqa.cn/proxmox/debian/pve bookworm port'>/etc/apt/sources.list.d/pveport.list


curl -L https://de.mirrors.apqa.cn/proxmox/debian/pveport.gpg -o /etc/apt/trusted.gpg.d/pveport.gpg 

apt update && apt full-upgrade

# Install Proxmox VE packages
apt install -y ifupdown2
apt install -y proxmox-ve postfix open-iscsi
# setting OVMF
apt download pve-edk2-firmware-aarch64=3.20220526-rockchip
dpkg -i pve-edk2-firmware-aarch64_3.20220526-rockchip_all.deb

apt update && apt full-upgrade -y

# update kernel pagesize
echo 'kernel=kernel8.img' >>/boot/firmware/config.txt

# update boot cmdline
echo ' cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1' >>/boot/cmdline.txt
