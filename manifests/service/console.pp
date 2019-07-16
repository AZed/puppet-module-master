#
# master::service::console
#
# Enable a serial console
#
# STUB: this currently only works on Debian 8+, and possibly only with SystemD enabled
#

class master::service::console (
    $tty = 'ttyS0',
){
    service { "serial-getty@${tty}":
        enable => true,
        ensure => running,
    }
}
