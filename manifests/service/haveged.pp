#
# class master::service::haveged
# ==============================
#
# Installs the HArdware Volatile Entropy Gathering and Expansion
# Daemon to fill the /dev/random pool on systems where high entropy is
# needed (e.g. for key generation)
#

class master::service::haveged (
){
    package { 'haveged': }
}
