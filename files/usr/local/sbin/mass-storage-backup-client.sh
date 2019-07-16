#!/bin/sh
# Shell script to backup and encrypt data to mass storage.
# Usage: $0 -f <file system to back up> -u <remote_user> -h <remote_host> -k 
#    <ssh_private_key> -d <repository_dir> -r <GPG key id> [-r GPG key id]...



### Variables

# Locations of various programs
TAR="/bin/tar"
SSH="/usr/bin/ssh"
GPG="/usr/bin/gpg"
DATE="/bin/date"

# Sane defaults
CIPHERALGO="AES"       # FIPS 140 compliant(ish), might change for performance
#COMPRESSALGO="bzip2"
#COMPRESSLEVEL="9"
CURRDATE=`/bin/date --utc +%FT%H:%M:%SZ`
ARCHIVEDIR="/archive/backup/$HOSTNAME"
REMOTEHOST="dirac"
REMOTEPORT="2225"



### Program

# Parse command line options and replace defaults where reasonable
while getopts f:u:h:k:d:r: opt
do
   case "$opt" in
   f)	VOLUME=$OPTARG;;
   u)   REMOTEUSER=$OPTARG;;
   h)   REMOTEHOST=$OPTARG;;
   k)   REMOTEKEY=$OPTARG;;
   d)   ARCHIVEDIR="${OPTARG}/${HOSTNAME}";;
   r)   PUBKEYS=${PUBKEYS}" $OPTARG";;
   p)   REMOTEPORT=$OPTARG;;
   [?]) echo "Usage statement goes here." >&2
        exit 1;;
   esac
done


# Ensure the non-optionals are specified
if [ -z "$VOLUME" ] ; then
  echo "No backup source specified.  Use -f <backup_source>" >&2
  exit 1;
fi

if [ -z "$REMOTEUSER" ]; then
  echo "You did not specify a remote user.  Use -u <remote_user>" >&2
  exit 1;
fi

#if [ -z "$REMOTEHOST" ]; then
#  echo "You did not specify the target host.  Use -h <remote_host>" >&2
#  exit 1;
#fi

if [ -z "$REMOTEKEY" ]; then
  echo "You did not specify a private ssh key.  Use -k <priv_keys>" >&2
  exit 1;
fi

if [ -z "$PUBKEYS" ]; then
  echo "You did not specify any public keys.  Use -r <keyid> [ -r <keyid> ...]" >&2;
  exit 1;
fi



# Build the GPG command line

for i in $PUBKEYS
do
   KEYARGS=$KEYARGS' -r '$i
done

VOLUMETEXT=`basename ${VOLUME}`

if [ $VOLUMETEXT == "/" ] ; then
  VOLUMETEXT="root"
fi

ARCHIVENAME="${HOSTNAME}-${VOLUMETEXT}-${CURRDATE}.tar.gpg"

GPGARGS='--homedir /root/.gnupg '${KEYARGS}' -e'

if [ -n "$COMPRESSLEVEL" ] ; then
  GPGARGS="${GPGARGS} --compress-level ${COMPRESSLEVEL}"
fi

if [ -n "$COMPRESSALGO" ] ; then
  GPGARGS="${GPGARGS} --compress-algo ${COMPRESSALGO}"
fi

if [ -n "$CIPHERALGO" ] ; then
  GPGARGS="${GPGARGS} --cipher-algo ${CIPHERALGO}"
fi

# Do the deed
${TAR} --one-file-system --atime-preserve -cf - ${VOLUME} | \
  gpg --trust-model always ${GPGARGS}                        | \
  $SSH -i ${REMOTEKEY} ${REMOTEUSER}@${REMOTEHOST} -p ${REMOTEPORT} "backup-wrapper.pl ${ARCHIVEDIR}/${ARCHIVENAME}"
