#!/bin/bash

# --- 設定項目 (環境に合わせて変更してください) ---
RPI_STATIC_IP="192.168.11.101"
RPI_GATEWAY_IP="192.168.11.1"
RPI_HOSTNAME="pve-node1"
# ---------------------------------------------

set -e # エラーが発生したら停止

# 1. パスワード設定 (未設定の場合のみ実行したい場合はコメントアウト等してください)
echo '----- update password -----'
passwd

# 2. ホスト名の設定
hostnamectl set-hostname $RPI_HOSTNAME
# /etc/hosts の修正 (Proxmoxは自身のホスト名解決に厳格です)
# 既存のエントリを消して追記する簡易的な手法をとります
sed -i "/$RPI_STATIC_IP/d" /etc/hosts
echo "${RPI_STATIC_IP} ${RPI_HOSTNAME}.proxmox.com ${RPI_HOSTNAME}" >> /etc/hosts

# 3. システムの更新
apt update && apt upgrade -y

# 4. ネットワーク設定 (ifupdown2への移行)
# NetworkManagerが入っている場合は無効化 (ドキュメント推奨)
if systemctl is-active --quiet NetworkManager; then
    echo "Disabling NetworkManager..."
    systemctl stop NetworkManager
    systemctl disable NetworkManager
fi

# ifupdown2 のインストール
apt install -y ifupdown2

# /etc/network/interfaces の書き換え
# バックアップを作成
cp /etc/network/interfaces /etc/network/interfaces.bak

cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

iface eth0 inet manual

auto vmbr0
iface vmbr0 inet static
    address $RPI_STATIC_IP/24
    gateway $RPI_GATEWAY_IP
    bridge-ports eth0
    bridge-stp off
    bridge-fd 0
EOF

# 5. Proxmox (Pxvirt) リポジトリの追加
# ドキュメントに基づき lierfang.com のミラーを使用
echo "deb https://mirrors.lierfang.com/pxcloud/pxvirt bookworm main" > /etc/apt/sources.list.d/pxvirt-sources.list

# GPGキーの追加
curl -L https://mirrors.lierfang.com/pxcloud/lierfang.gpg -o /etc/apt/trusted.gpg.d/lierfang.gpg

# リポジトリ情報の更新
apt update && apt full-upgrade -y

# 6. Proxmox VE パッケージのインストール
# ドキュメント推奨パッケージ + 必須ツール
apt install -y proxmox-ve pve-manager qemu-server pve-cluster postfix open-iscsi

# 7. Raspberry Pi 固有のカーネル/ブート設定
# cgroups (コンテナ用) の有効化は RPi では必須です
CMDLINE_FILE="/boot/cmdline.txt"
# /boot/firmware/cmdline.txt の場合もあるため確認 (Bookworm以降の変更点)
if [ -f "/boot/firmware/cmdline.txt" ]; then
    CMDLINE_FILE="/boot/firmware/cmdline.txt"
fi

if ! grep -q "cgroup_memory=1" "$CMDLINE_FILE"; then
    echo "Adding cgroup settings to $CMDLINE_FILE..."
    # 行末に追加
    sed -i 's/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1/' "$CMDLINE_FILE"
fi

# カーネル設定 (kernel8.img)
# 多くの環境ではデフォルトで64bitカーネルがロードされますが、念のため config.txt を確認
CONFIG_FILE="/boot/config.txt"
if [ -f "/boot/firmware/config.txt" ]; then
    CONFIG_FILE="/boot/firmware/config.txt"
fi

# kernel=kernel8.img が無い場合のみ追記（重複防止）
if ! grep -q "kernel=kernel8.img" "$CONFIG_FILE"; then
    echo "kernel=kernel8.img" >> "$CONFIG_FILE"
fi

echo "-----------------------------------------------------"
echo "Installation Complete!"
echo "Please REBOOT your Raspberry Pi to apply changes."
echo "Web Interface: https://${RPI_STATIC_IP}:8006"
echo "-----------------------------------------------------"