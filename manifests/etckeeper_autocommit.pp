#
# define master::etckeeper_autocommit
# ===================================
#
# Create an automatic commit of changes to /etc via etckeeper
#
# WARNING: It is extremely difficult to ensure that a define actually
# fires in between two specific actions in Puppet, so use of this
# define is actually not recommended except for very specific and
# limited circumstances where you are using it twice in a chain to
# capture changes for debugging.  If you are trying to ensure that
# etckeeper activates before and after puppet runs, use the
# prerun_command and postrun_command settings.

define master::etckeeper_autocommit {
    include master::common::etckeeper

    case $::osfamily {
        'Debian','RedHat','Suse': {
            exec { "etckeeper-autocommit-${title}":
                command => "etckeeper commit 'Automatic commit by puppet: ${title}'",
                cwd => '/etc',
                path => '/sbin:/usr/sbin:/bin:/usr/bin',
                onlyif => [ 'etckeeper pre-commit',
                            'etckeeper unclean'
                          ],
                require => Exec['etckeeper-init']
            }
        }
        default: {
            notice("etckeeper autocommits are not available for ${::operatingsystem}.")
        }
    }
}
