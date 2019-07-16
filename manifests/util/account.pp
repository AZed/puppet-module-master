#
# master::util::account
#
# Account management packages and their configuration
#

class master::util::account (
    # Default home directory for new accounts
    $default_home = '/home',

    # Default shell for new accounts
    $default_shell = '/bin/bash'
)
{
    case $::osfamily {
        'debian': {
            package { 'adduser': }
            templatelayer { '/etc/adduser.conf': }
        }
        'redhat': {
            package { 'shadow-utils': }
        }
        default: { }
    }
}
