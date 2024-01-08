RPI_STATIC_IP="192.168.11.4" # edit me
RPI_HOSTNAME="pi5-prox2"     # edit me

# password reset
passwd

# apt update, upgrade
apt update
apt upgrade -y

# set hostname
echo "${RPI_STATIC_IP} ${RPI_HOSTNAME}.proxmox.com ${RPI_HOSTNAME}" >>/etc/hosts

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
