#!/bin/bash
# Ce script doit permettre de créer des groupes LDAP.

# Read LDAP connection information from config file
source server_ldap.conf

# Ask user for new groups information
while true; do
	read -p "enter group name : " GROUP_NAME


# Write user data to LDIF file NOTE: To change the gidNumber


	cat <<EOF >> group.ldif
dn: cn=$GROUP_NAME,ou=groups,dc=tgs,dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 500 
EOF



# Check if file exists
if [ ! -f "group.ldif" ]; then
  echo "File not found!"
  exit 1
fi

# Read contents of file
while read line; do
  echo "$line"
done < "group.ldif"

    # Ask user if they want to create another user
    read -p "Create another user? (y/n) " CONTINUE
    if [[ "$CONTINUE" == "n" ]]; then
        break
    fi
done

# Add group to LDAP directory
ldapadd -x -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f group.ldif

# Remove LDIF file
rm group.ldif

echo "Done."


