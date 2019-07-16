#
# class master::common::root
# ==========================
#
# Minimal class to set a root password, or ensure that it is locked
#

class master::common::root (
    # Parameters
    # ----------
    #
    # ### authorized_keys
    # Array of authorized keys entries to put in /root/.ssh/authorized_keys
    # If this is false (or undef), the file will be unmanaged
    $authorized_keys = undef,

    # ### password
    # Hash to put in /etc/shadow
    $password = false,

    # ### password_max_age
    # ### password_min_age
    # minimum and maximum days a password must be used before it is changed
    $password_max_age = '99999',
    $password_min_age = undef
)
{
    file { '/root': ensure => directory, mode => '0700' }
    file { '/root/.ssh': ensure => directory, mode => '0700' }

    nodefile { '/root/.procmailrc': defaultensure => undef }

    if $authorized_keys {
        templatelayer { '/root/.ssh/authorized_keys': mode => '0400' }
    }

    if $password {
        $rootpw = $password
    }
    else {
        $rootpw = '!'
    }
    user { 'root':
        ensure           => present,
        uid              => 0,
        gid              => 0,
        expiry           => absent,
        managehome       => false,
        password         => $rootpw,
        password_max_age => $password_max_age,
        password_min_age => $password_min_age,
    }
}
