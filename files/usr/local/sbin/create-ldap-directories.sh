#!/bin/sh
#

# Full path to the slapd.conf file
SLAPD_CONF="/etc/ldap/slapd.conf"

# Root directory where the LDAP databases are
# (Don't include the trailing slash)
SLAPD_ROOT="/var/lib/ldap"

# Logging stuff
LOGGER="logger -s -i -t `basename $0`"

grep "^directory" "${SLAPD_CONF}" | awk '{print $2}' | sed -e 's/"//g' | \
while read DIRECTORY
do
  # Ensure that DIRECTORY is within SLAPD_ROOT
  DIRNAME=`echo "${DIRECTORY}" | sed -e "s#${SLAPD_ROOT}##"`
  if [ "${DIRECTORY}" != "${SLAPD_ROOT}${DIRNAME}" ]
  then
    ${LOGGER} "${DIRECTORY} not safe, exiting (!= ${SLAPD_ROOT}${DIRNAME})"
    exit 1
  fi

  # Ensure that DIRECTORY exists
  if [ ! -d "${DIRECTORY}" ] 
  then
    ${LOGGER} "Directory '${DIRECTORY}' does not exist, creating"
    mkdir -p "${DIRECTORY}"
  fi

  # Ensure ownership and permissions are correct

  ${LOGGER} "Setting ownership of '${DIRECTORY}' to openldap:openldap"
  chown -R opendlap:openldap "${DIRECTORY}"

  ${LOGGER} "Setting permissions of directories within ${DIRECTORY} to 750"
  find "${DIRECTORY}" -type d -exec chmod 750 {} \;

  ${LOGGER} "Setting permissions of files within ${DIRECTORY} to 640"
  find "${DIRECTORY}" -type f -exec chmod 640 {} \;
done
