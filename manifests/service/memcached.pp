#
# class master::service::memcached
#
# Install the memcached cacheing daemon
#

class master::service::memcached (
    $logfile = '/var/log/memcached.log',
    # Maximum number of simultaneous incoming connections
    $maxconn = '1024',
    $port = '11211',
    # Maximum memory to use for object storage in MB
    $size = '64',
    $user = $::osfamily ? {
        'Debian' => $::operatingsystemmajrelease ? {
            '6'     => 'nobody',
            '7'     => 'nobody',
            '8'     => 'memcache',
            '9'     => 'memcache',
            default => 'memcache',
        },
        'RedHat' => 'memcached',
        default  => 'nobody',
    },
){
    package { "memcached": ensure => latest, }
    case $::osfamily {
        'Debian': {
            templatelayer { "/etc/memcached.conf": }
        }
        'RedHat': {
            templatelayer { '/etc/sysconfig/memcached': }
        }
        default: { }
    }
}
