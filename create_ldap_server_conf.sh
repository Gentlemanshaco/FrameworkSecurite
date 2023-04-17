#!/bin/bash

########################### Ldap connexion configuration ############################

# Prompt the user to enter the LDAP server connection parameters
read -p "Enter the LDAP server hostname: " LDAP_SERVER
read -p "Enter the LDAP server port (default: 389): " LDAP_PORT
LDAP_PORT=${LDAP_PORT:-389}  # If the user didn't enter a port number, use the default value of 389
read -p "Enter the LDAP bind DN: " LDAP_BIND_DN
read -s -p "Enter the LDAP bind password: " LDAP_BIND_PW
echo  # Move to a new line after the password input

# Write the parameters to a configuration file
echo "LDAP_SERVER=$LDAP_SERVER" > server_ldap.conf
echo "LDAP_PORT=$LDAP_PORT" >> server_ldap.conf
echo "LDAP_BIND_DN=$LDAP_BIND_DN" >> server_ldap.conf
echo "LDAP_BIND_PW=$LDAP_BIND_PW" >> server_ldap.conf

echo "LDAP server configuration saved in server_ldap.conf"


