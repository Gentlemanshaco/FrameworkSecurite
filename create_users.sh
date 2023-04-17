#!/bin/bash

########################### User creation ######################################
# Read LDAP connection information from config file
source server_ldap.conf

# Ask user for new user information
while true; do
    read -p "Enter first name: " FIRST_NAME
    read -p "Enter last name: " LAST_NAME
    read -p "Enter email: " EMAIL
    read -s -p "Enter password: " PASSWORD
    echo ""

    # Generate user DN
    USER_DN="cn=${FIRST_NAME} ${LAST_NAME},$LDAP_BASE_DN"
    echo "The user_dn is $USER_DN"

    # Generate random salt and encrypted password
    SALT=$(openssl rand -base64 4)
    ENCRYPTED_PASSWORD="{SSHA}$(echo -n "${PASSWORD}${SALT}" | openssl dgst -sha1 -binary | base64)"
    echo "The encrypted password is $ENCRYPTED_PASSWORD"

    # Write user data to LDIF file
    cat <<EOF >> users.ldif
dn: $USER_DN
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: ${FIRST_NAME} ${LAST_NAME}
givenName: ${FIRST_NAME}
sn: ${LAST_NAME}
mail: ${EMAIL}
uid: ${FIRST_NAME,,}.${LAST_NAME,,}
uidNumber: $(($(ldapsearch -LLL -x -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -b "$LDAP_BASE_DN" "(objectClass=posixAccount)" uidNumber | grep uidNumber | awk '{print $2}' | sort -n | tail -1)+1))
gidNumber: 500
homeDirectory: /home/${FIRST_NAME,,}.${LAST_NAME,,}
loginShell: /bin/bash
userPassword: ${ENCRYPTED_PASSWORD}
EOF
# Cette ligne crée un espace entre les utilisateurs dans le fichier ldif.
    echo "" >> users.ldif

# Check if file exists
if [ ! -f "users.ldif" ]; then
  echo "File not found!"
  exit 1
fi

# Read contents of file
while read line; do
  echo "$line"
done < "users.ldif"

    # Ask user if they want to create another user
    read -p "Create another user? (y/n) " CONTINUE
    if [[ "$CONTINUE" == "n" ]]; then
        break
    fi
done

# Add users to LDAP directory
ldapadd -x -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f users.ldif

# Remove LDIF file
rm users.ldif

echo "Done."