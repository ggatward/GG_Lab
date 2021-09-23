#!/bin/bash

# OKD nodes in VLAN5
ipa dnszone-add ocp.home.gatwards.org. --allow-sync-ptr=true --dynamic-update=true
ipa dnszone-add 5.22.172.in-addr.arpa. --name-from-ip=172.22.5.0 --allow-sync-ptr=true --dynamic-update=true

ipa dnsrecord-add ocp.home.gatwards.org services --a-ip-address=172.22.5.100 --a-create-reverse
ipa dnsrecord-add ocp.home.gatwards.org master1.lab --a-ip-address=172.22.5.101 --a-create-reverse
ipa dnsrecord-add ocp.home.gatwards.org master2.lab --a-ip-address=172.22.5.102 --a-create-reverse
ipa dnsrecord-add ocp.home.gatwards.org master3.lab --a-ip-address=172.22.5.103 --a-create-reverse
ipa dnsrecord-add ocp.home.gatwards.org bootstrap.lab --a-ip-address=172.22.5.110 --a-create-reverse

# OKD cluster internal IPs

ipa dnsrecord-add ocp.home.gatwards.org api.lab --a-ip-address=172.22.5.100
ipa dnsrecord-add ocp.home.gatwards.org api-int.lab --a-ip-address=172.22.5.100
ipa dnsrecord-add ocp.home.gatwards.org *.apps.lab --a-ip-address=172.22.5.100
