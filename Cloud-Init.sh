apt install cloud-init

TEMPLATE_ID=9000
VM_ID=110

IMG_FILE_URL=https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img

# Create template
curl $IMG_FILE_URL > /tmp/cloudimg-arm64.img

qm create $TEMPLATE_ID \
--cpulimit 1 \
--memory 2048  \
--net0 virtio,bridge=vmbr0  \
--scsihw virtio-scsi-single \
--bios ovmf \
--efidisk0 local:0,efitype=4m,pre-enrolled-keys=1,size=64M \
--scsi0 local:0,import-from=/tmp/cloudimg-arm64.img \
--sata0 local:cloudinit \
--boot order=scsi0 \
--serial0 socket

qm template $TEMPLATE_ID


# Deploy VM
wget https://raw.githubusercontent.com/kta/pimox8/main/cloudinit/1000-cloud-init.yml -O $VM_ID-cloud-init.yml
cp $VM_ID-cloud-init.yml /var/lib/vz/snippets/

qm clone $TEMPLATE_ID $VM_ID --name vm$VM_ID
qm set $VM_ID --sshkey ~/.ssh/id_rsa.pub
qm set $VM_ID --ipconfig0 ip=10.0.10.101/24,gw=10.0.10.1
qm set $VM_ID --cicustom "user=local:snippets/$VM_ID-cloud-init.yml"
qm cloudinit dump $VM_ID user
qm start $VM_ID

