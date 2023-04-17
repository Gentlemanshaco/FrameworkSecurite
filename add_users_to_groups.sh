#!/bin/bash

# Ce script doit permettre facilement d'ajouter des utilisateurs à des groupes existants.

# Read LDAP connection information from config file
source server_ldap.conf

#ask user for group change informations
while true; do
	read -p "enter the name of the group to add user to : " GROUP
	read -p "enter the userid of the user who change group : " USERID


# Write user and group data to LDIF file

	cat <<EOF >> changegroup.ldif
dn: cn=$GROUP,ou=groups,dc=tgs,dc=com
changetype: modify
add: memberuid
memberuid: $USERUID
EOF

# Check if file exists
if [ ! -f "changegroup.ldif" ]; then
  echo "File not found!"
  exit 1
fi

# Read contents of file
while read line; do
  echo "$line"
done < "changegroup.ldif"

    # Ask user if they want to change another user's group
    read -p "Change another user's group? (y/n) " CONTINUE
    if [[ "$CONTINUE" == "n" ]]; then
        break
    fi
done

# send the change to LDAP directory
ldapadd -x -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f changegroup.ldif

# Remove LDIF file
rm changegroup.ldif

echo "Done."
