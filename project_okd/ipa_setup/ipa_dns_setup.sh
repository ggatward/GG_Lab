#!/bin/bash

# OKD nodes in VLAN5
ipa dnszone-add okd.home.gatwards.org. --allow-sync-ptr=true --dynamic-update=true
ipa dnszone-add 5.22.172.in-addr.arpa. --name-from-ip=172.22.5.0 --allow-sync-ptr=true --dynamic-update=true

ipa dnsrecord-add okd.home.gatwards.org services --a-ip-address=172.22.5.210 --a-create-reverse
ipa dnsrecord-add okd.home.gatwards.org bootstrap.lab --a-ip-address=172.22.5.100 --a-create-reverse
ipa dnsrecord-add okd.home.gatwards.org master1.lab --a-ip-address=172.22.5.101 --a-create-reverse
ipa dnsrecord-add okd.home.gatwards.org master2.lab --a-ip-address=172.22.5.102 --a-create-reverse
ipa dnsrecord-add okd.home.gatwards.org master3.lab --a-ip-address=172.22.5.103 --a-create-reverse
ipa dnsrecord-add okd.home.gatwards.org worker1.lab --a-ip-address=172.22.5.104 --a-create-reverse
ipa dnsrecord-add okd.home.gatwards.org worker2.lab --a-ip-address=172.22.5.105 --a-create-reverse

# OKD cluster internal IPs

ipa dnsrecord-add okd.home.gatwards.org api.lab --a-ip-address=172.22.5.210
ipa dnsrecord-add okd.home.gatwards.org *.apps.lab --a-ip-address=172.22.5.210
ipa dnsrecord-add okd.home.gatwards.org console-openshift-console.apps.lab --a-ip-address=172.22.5.210

ipa dnsrecord-add okd.home.gatwards.org api-int.lab --a-ip-address=172.22.5.210
ipa dnsrecord-add okd.home.gatwards.org etcd-0.lab --a-ip-address=172.22.5.101
ipa dnsrecord-add okd.home.gatwards.org etcd-1.lab --a-ip-address=172.22.5.102
ipa dnsrecord-add okd.home.gatwards.org etcd-2.lab --a-ip-address=172.22.5.103
ipa dnsrecord-add okd.home.gatwards.org oauth-openshift.apps.lab --a-ip-address=172.22.5.210

# OKD Service records
ipa dnsrecord-add okd.home.gatwards.org _etcd-server-ssl._tcp.lab --srv-rec="0 10 2380 etcd-0.lab"
ipa dnsrecord-add okd.home.gatwards.org _etcd-server-ssl._tcp.lab --srv-rec="0 10 2380 etcd-1.lab"
ipa dnsrecord-add okd.home.gatwards.org _etcd-server-ssl._tcp.lab --srv-rec="0 10 2380 etcd-2.lab"
