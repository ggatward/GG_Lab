# Setup is TWO hosts - deploy runs on control-1, second host is compute-1
# (compute-2/control-2 can also be installed if uncommented in ansible and kolla inventories)

# Deploy oVirt VMs
```
ansible-playbook -i hosts_lab.ini -u ansible --vault-id vault@prompt kolla_provision_ovirt.yml
```

# Apply generic config and hardening
```
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt generic.yml --limit kolla
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt hardening.yml --limit kolla
```

# Prep deploy host for kolla.  control-1 will be the deploy host
Initial run will need the extra_vars to do the swift setup
```
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt kolla_prep_hosts.yml \
  -e 'swift_newrings=true' -e 'swift_formatdisks=true'
```

Subsequent runs shouldn't need the swift setup
```
ansible-playbook -i hosts.ini -u ansible --vault-id vault@prompt kolla_prep_hosts.yml
```



#############################################
#   Kolla Deploy - executed on control-1
```
source /opt/venv/kolla/bin/activate
cd /etc/kolla
kolla-ansible -i inventory bootstrap-servers
kolla-ansible -i inventory pull
kolla-ansible -i inventory prechecks
kolla-ansible -i inventory deploy
```

# Get admin creds
```
kolla-ansible -i inventory post-deploy
```
