
url --url http://mirror.internode.on.net/pub/centos/8.3.2011/BaseOS/x86_64/os/

lang en_US.UTF-8
selinux --enforcing
keyboard us
skipx

network --bootproto static --ip=172.22.4.12 --netmask=255.255.255.0 --gateway=172.22.4.1 --nameserver=172.22.1.3,172.22.1.5 --mtu=9000 --hostname baremetal2.lab.home.gatwards.org --device=ac:1f:6b:44:7a:e6
rootpw --iscrypted $6$1aFgyHgQfesAR4Jj$6R2B8AujvAGO/qIQUyX3JgrWCfUowzwyLIY9AM4SMoH.z2VTasva3Z77eku4uxE9ylfT7FqbH7H9iVfMomdg7.
firewall --service=ssh

authselect --useshadow --passalgo=sha512 --kickstart
timezone --utc UTC

bootloader --location=mbr --append="nofb quiet splash=quiet"

%include /tmp/diskpart.cfg

text
reboot

%packages
@Core
NetworkManager
chrony
crontabs
dhclient
redhat-lsb-core
wget
python3
%end
%pre

#Dynamic
act_mem=$((`grep MemTotal: /proc/meminfo | sed 's/^MemTotal: *//'|sed 's/ .*//'` / 1024))
if [ "$act_mem" -lt 2048 ]; then
    vir_mem=$(($act_mem * 2))
elif [ "$act_mem" -gt 2048 -a "$act_mem" -lt 8192 ]; then
    vir_mem=$act_mem
elif [ "$act_mem" -gt 8192 -a "$act_mem" -lt 65536 ]; then
    vir_mem=$(($act_mem / 2))
else
    vir_mem=4096
fi

PRI_DISK=$(awk '/[v|s]da|nvme0|c0d0/ {print $4 ;exit}' /proc/partitions)
grep -E -q '[v|s]db|nvme1|c1d1' /proc/partitions  &&  SEC_DISK=$(awk '/[v|s]db|nvme1|c1d1/ {print $4 ;exit}' /proc/partitions)
grep -E -q '[v|s]db1|nvme1p1|c1d1p1' /proc/partitions  &&  EXISTING="true"

echo zerombr >> /tmp/diskpart.cfg
echo clearpart --all --initlabel >> /tmp/diskpart.cfg
echo part /boot --fstype xfs --size=1024 --ondisk=${PRI_DISK} --asprimary >> /tmp/diskpart.cfg
echo part pv.01 --size=32767 --grow --ondisk=${PRI_DISK} >> /tmp/diskpart.cfg

echo volgroup vg_sys --pesize=16384 pv.01 >> /tmp/diskpart.cfg
echo logvol / --fstype xfs --name=lv_root --vgname=vg_sys --size=10240 --fsoptions="noatime" >> /tmp/diskpart.cfg
echo logvol swap --fstype swap --name=lv_swap --vgname=vg_sys --size=${vir_mem} >> /tmp/diskpart.cfg
echo logvol /home --fstype xfs --name=lv_home --vgname=vg_sys --size=10240 --fsoptions="noatime,nosuid,nodev" >> /tmp/diskpart.cfg
echo logvol /tmp --fstype xfs --name=lv_tmp --vgname=vg_sys --size=4096 --fsoptions="noatime,nosuid,nodev" >> /tmp/diskpart.cfg
echo logvol /var --fstype xfs --name=lv_var --vgname=vg_sys --size=20480 --fsoptions="noatime,nosuid,nodev" >> /tmp/diskpart.cfg
echo logvol /opt --fstype xfs --name=lv_opt --vgname=vg_sys --size=2048 --fsoptions="noatime,nosuid,nodev" >> /tmp/diskpart.cfg
echo logvol /var/log/ --fstype xfs --name=lv_log --vgname=vg_sys --size=8192 --fsoptions="noatime,nosuid,nodev,noexec" >> /tmp/diskpart.cfg
echo logvol /var/log/audit --fstype xfs --name=lv_audit --vgname=vg_sys --size=2048 --fsoptions="noatime,nosuid,nodev,noexec" >> /tmp/diskpart.cfg
echo logvol /var/crash --fstype xfs --name=lv_crash --vgname=vg_sys --size=10240 --fsoptions="noatime,nosuid,nodev,noexec" >> /tmp/diskpart.cfg
%end


%post --nochroot
exec < /dev/tty3 > /dev/tty3
#changing to VT 3 so that we can see whats going on....
/usr/bin/chvt 3
(
cp -va /etc/resolv.conf /mnt/sysimage/etc/resolv.conf
/usr/bin/chvt 1
) 2>&1 | tee /mnt/sysimage/root/install.postnochroot.log
%end

%post
logger "Starting anaconda baremetal2.lab.home.gatwards.org postinstall"
exec < /dev/tty3 > /dev/tty3
#changing to VT 3 so that we can see whats going on....
/usr/bin/chvt 3
(

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eno1
BOOTPROTO="none"
IPADDR="172.22.4.12"
NETMASK="255.255.255.0"
GATEWAY="172.22.4.1"
DOMAIN="lab.home.gatwards.org"
DEVICE=eno1
HWADDR="ac:1f:6b:44:7a:e6"
ONBOOT=yes
PEERDNS=yes
PEERROUTES=yes
DEFROUTE=yes
DNS1="172.22.1.3"
DNS2="172.22.1.5"
MTU=9000
EOF



# Copy root SSH key for bootstrap
mkdir -p /root/.ssh && chmod 700 /root/.ssh
cat << EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCu4S8wzEwXIVuHD+KK7y08lravhF5BvApvXRAPXXeaHtQ3HeYN+7t9HpyIQYg6OwsxNX7WbKgZ50Ok12t3EPRbEr8M9wWW+S5l0SJlzv7h26uNcIucFvlo5aPmV+XLFY7qokaKPaMEwrb7wG/gBTfsjLbhFNFXfT1bEMEp87/K6LUwoNQ3dBrZq5UWYuvMMW4kMH1igKB9dCWraHGqzlyJh4ol9XApPaDfJ8ujSiNs7NzZhUFeYpGC/eMAwnuhFWUZf/SJJJ53Y6AmPTBZVmpPbaJSNnakWssAG54t6Ay3orVi+cvvQlIB2oyilxE06i7FXgZSouwtJAk0Q2E/4mfj root@localhost.localdomain
EOF
chmod 600 /root/.ssh/authorized_keys
restorecon -Rv /root


useradd svc-ansible
cat << EOF > /etc/sudoers.d/svc-ansible
svc-ansible	ALL = (ALL)	NOPASSWD : ALL
Defaults: svc-ansible !requiretty
EOF
mkdir /home/svc-ansible/.ssh && chmod 700 /home/svc-ansible/.ssh
cat << EOF > /home/svc-ansible/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC75ApOJW1sf360AYmh9B57suv+etPYYa6CzvEJjCVZyU+8xPaZR5EacToq9HPYILNAv3TQk1r+K6DKA5+wEpJqm2YzgIPLkZOP1N4Bw19DnAiqIMnDTYa8iIYHOQMpqG/DY6q1/QnP2Gw6r0uTw7zFKH1Vw4DbVJMGOQBJblWFq1G+LSN4j60eiN72kZEMf3fQgLCKUzDdbOUkjJnl/4/SUq5lncMBm88efiJLNwdJzelGkH5QveNioiQ/mXP/DlnLYiCKHh1qJlaD/OGlEuHJSnDD9uD4TknEi8AFqLTDc4XZZgUWF5RWSUwxMIiBuyMtr5Zma20dQpdwqYZT6LcNcMokHHAQ+S/cuibtR/YQ3PsYubUIAbCfeIHjKRdBDUP5ZE/VfybKTE/rlAUQCzpt5w5iBWr3qo2iW7gW/Rvlt78bqCHETnCNHLIT5mm9koA0+kr2dNmiUnb91KpdpNs4tLveVYGtN8tJHL4NDSHqiEeOYklV+uLL2gN6kziB53c= svc-ansible@ansible.core.home.gatwards.org
EOF
chown -R svc-ansible: /home/svc-ansible/.ssh
chmod 600 /home/svc-ansible/.ssh/authorized_keys
restorecon -Rv /home

sync

) 2>&1 | tee /root/install.post.log
exit 0

%end
