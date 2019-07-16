#
# class master::service::rpcbind
# ==============================
#
# Installs rpcbind and ensures that the service is started
#

class master::service::rpcbind (
){
    package { 'rpcbind': }

    service { 'rpcbind':
        ensure  => running,
        enable  => true,
        require => Package['rpcbind'],
    }
}
