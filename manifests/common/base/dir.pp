#
# master::common::base::dir
# =========================
#
# Base directories upon which multiple other classes may depend
#

class master::common::base::dir (
    # Parameters
    # ----------

    # ### opt
    # ### srv
    # ### usr_local
    # ### var_spool
    # ### var_vc
    # If any of the above are specified, the related directory will be
    # converted to a symlink pointing at the specified location, e.g.:
    #
    #     master::common::base::dir::opt: /srv/opt
    #
    # *** WARNING ***
    #
    # These are forced conversions, since the base layout is expected
    # to be a directory.  This means that using any of these options
    # WILL DESTROY ALL EXISTING DATA undernath those locations.  Also,
    # use of these options is expected to fail if any of those
    # directories has already been set up as a mount point.
    #
    $opt = false,
    $srv = false,
    $usr_local = false,
    $var_spool = false,
    $var_vc = false,
){
    File {
        ensure => directory,
        owner => 'root', group => 'root', mode => '0755'
    }
    file { '/etc': }
    file { '/etc/cron.d': }
    file { '/etc/cron.daily': }
    if $opt {
        file { '/opt':
            ensure => link,
            target => $opt,
            force  => true,
        }
    }
    else {
        file { '/opt': }
    }
    if $srv {
        file { '/srv':
            ensure => link,
            target => $srv,
            force  => true,
        }
    }
    else {
        file { '/srv': }
    }
    file { '/tmp': mode => '1777' }
    file { '/usr': }
    if $usr_local {
        file { '/usr/local':
            ensure => link,
            target => $usr_local,
            force  => true,
        }
    }
    else {
        file { '/usr/local': }
    }
    file { '/usr/local/bin': }
    file { '/usr/local/etc': }
    file { '/usr/local/lib': }
    file { '/usr/local/sbin': }
    file { '/usr/local/share': }
    file { '/usr/local/share/doc': }
    file { '/usr/local/share/misc': }
    file { '/usr/share': }
    file { '/usr/share/nagios-client': mode => '0700' }
    file { '/usr/share/nagios-client/client.d':
        mode    => '0700',
        recurse => true,
        purge   => true,
    }
    file { '/var': }
    if $var_spool {
        file { '/var/spool':
            ensure => link,
            target => $var_spool,
            force  => true,
        }
    }
    else {
        file { '/var/spool': }
    }
    if $var_vc {
        file { '/var/vc':
            ensure => link,
            target => $var_vc,
            force  => true,
        }
    }
    else {
        file { '/var/vc': }
    }
    file { '/var/tmp': mode => '1777' }
}
