# GG_Lab

This project makes use of a KVM (libvirt) hypervisor hosting an oVirt Engine VM, and a pair of oVirt hypervisors.

The KVM host is currently installed manually from CentOS 8.3 ISO, and then these playbooks can configure the rest.

Kickstarts (files/kickstart) are hosted on a NAS webshare accessible to the lab environment and are copied to that share via an NFS mountpount  ** Not yet done by these playbooks **

PXE boot menu (files/pxelinux) are hosted on a NAS running the TFTP server accessible to the lab environment and are copied to that share via an NFS mountpount  ** Not yet done by these playbooks **

Kickstart the two hypervisor hosts (baremetal1 and baremetal2) from the included kickstarts.

## Order of running playbooks
Apply generic and hardening configurations to all baremetal
```
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt generic.yml
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt hardening.yml
```

Configure the KVM host
```
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt kvmhost.yml
```

Install and configure oVirt environment
```
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt ovirt.yml
```
