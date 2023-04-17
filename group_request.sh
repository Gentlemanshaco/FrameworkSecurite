#!/bin/bash

# Read LDAP connection information from config file
source server_ldap.conf

# Execute LDAP search and create variables for dn and gid of each group
while IFS= read -r line; do
    if [[ $line =~ ^dn:\ (.*) ]]; then
        group_dn=${BASH_REMATCH[1]}
    elif [[ $line =~ ^gidNumber:\ (.*) ]]; then
        group_gid=${BASH_REMATCH[1]}
        echo "Group dn: $group_dn"
        echo "Group gid: $group_gid"
    fi
done < <(ldapsearch -LLL -x -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -b "$LDAP_BASE_DN" "(&(objectClass=posixGroup)(gidNumber=*))" gidNumber)