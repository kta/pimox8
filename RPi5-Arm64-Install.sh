RPI_STATIC_IP="192.168.11.101" # edit me
RPI_GATEWAY_IP="192.168.11.1" # edit me
RPI_HOSTNAME="pi5-prox-node1"     # edit me

# password reset
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
        address $RPI_STATIC_IP
        gateway $RPI_GATEWAY_IP
        bridge-ports eth0
        bridge-stp off
        bridge-fd 0 \n" > /etc/network/interfaces.new


# prepare for Proxmox VE installation
echo 'deb [arch=arm64] https://mirrors.apqa.cn/proxmox/debian/pve bookworm port' >/etc/apt/sources.list.d/pveport.list
curl https://mirrors.apqa.cn/proxmox/debian/pveport.gpg -o /etc/apt/trusted.gpg.d/pveport.gpg
apt update && apt full-upgrade -y

# Install Proxmox VE packages
apt install ifupdown2 -y
apt install proxmox-ve postfix open-iscsi -y

# setting OVMF
apt download pve-edk2-firmware-aarch64=3.20220526-rockchip
dpkg -i pve-edk2-firmware-aarch64_3.20220526-rockchip_all.deb
apt update && apt full-upgrade -y

# update kernel pagesize
echo 'kernel=kernel8.img' >>/boot/firmware/config.txt

# update boot cmdline
echo ' cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1' >>/boot/cmdline.txt
