#
# class master::common::selinux
# =============================
#
# SELinux Tools and Policies
#

class master::common::selinux (
    # Parameters
    # ----------
    #
    # ### selinux_state
    # Valid values are 'enforcing', 'permissive', and false (not 'false')
    #
    # Setting this to 'disabled' could result in inconsistent behavior
    # as the state is set to 'disabled' in the config, but activation
    # commands are executed
    $selinux_state = false,

    # ### selinux_type
    # Valid values is dependent on OS
    # On Debian, valid values are 'default', 'mls'
    # On CentOS/RedHat, valid values are 'targeted', 'mls'
    #
    # If left as 'false', it will default to 'default' on Debian and
    # 'targeted' on CentOS/RedHat
    $selinux_type = false
)
{
    # Code
    # ----
    #
    # The base policycoreutils and checkpolicy packages are depended on
    # by other packages and for basic validation even when SELinux is to
    # be disabled.
    #
    package { 'policycoreutils': ensure => present }
    package { 'checkpolicy': ensure => present }

    # If not otherwise specified, set defaults for selinux_type base on
    # operating system
    #
    if $selinux_type {
        $selinux_type_real = $selinux_type
    }
    else {
        $selinux_type_real = $::operatingsystem ? {
            'centos' => 'targeted',
            'debian' => 'default',
            'redhat' => 'targeted',
            'sles'   => 'default',
            default  => 'targeted',
        }
    }

    # The SELinux Policy package state is controlled by the
    # $selinux_state variable, and determines whether or not SELinux
    # might become active.  Note that installing this package under
    # Debian does not actually cause SELinux policy failures, but under
    # CentOS it will.
    #
    $selinux_policy_package = "selinux-policy-${selinux_type_real}"

    templatelayer { '/etc/selinux/config':
        suffix  => $::operatingsystem,
        require => Package['policycoreutils'],
    }

    file { '/etc/selinux/local':
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0700',
    }

    case $::operatingsystem {
        'CentOS','RedHat': {
            if $selinux_state and ($::selinux == 'true') {
                package { $selinux_policy_package: ensure => installed }
                if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                    selboolean { 'authlogin_shadow':
                        persistent => true,
                        value => on
                    }
                }
                selboolean { 'use_fusefs_home_dirs':
                    persistent => true,
                    value => on
                }
            }

            if $selinux_state and ($::selinux == 'false') {
                package { $selinux_policy_package: ensure => installed }
            }

            # Multiple things can depend on libselinux-utils -- don't
            # attempt to uninstall this for any reason
            #
            package { 'selinux-utils':
                ensure => installed,
                name   => 'libselinux-utils',
            }
            package { 'policycoreutils-python': ensure => installed }
            $selinux_local_modules = [
                                      "local-groupadd", "system_mail-dead_letter", "setsebool-useradd",
                                      "sshd_mkhomedir", "xauth-pty-selinux", "local-fuse-login-selinux",
                                      "unix_chkpwd-selinux", "login-selinux",
                                      "logrotate-selinux", "ntp-selinux", 
                                      "sshd-selinux", "syslog-selinux", "system-mail-selinux",
                                      ]
        }
        'Debian': {
            if  versioncmp($::operatingsystemrelease, '9.0') >= 0  {
                package { $selinux_policy_package: ensure => installed }
                package { 'selinux-utils': ensure => installed }

                if $selinux_state {
                    package { 'selinux-basics': ensure => installed,
                        notify => Exec['/usr/sbin/selinux-activate'] }
                }
                else {
                    package { 'selinux-basics': ensure => absent, }
                }

                ### REFACTOR THIS!  Does not belong in common::selinux
                # Used here because fsck repairs are required on boot for
                # initial SELinux policy
                templatelayer { '/etc/default/rcS': }

                if $selinux_state {
                    selinux_activate { 'now': }
                }
                $selinux_local_modules =
                [
                 "auditctl-selinux",
                 "dbus-selinux",
                 "login-selinux",
                 "unix_chkpwd-selinux",
                 "sshd-selinux",
                 "cron-selinux",
                 "getty-selinux",
                 "ntp-selinux",
                 "restorecond-selinux",
                 "sendmail-selinux",
                 "blkid-selinux",
                 "gpg-selinux",
                 "logrotate-selinux",
                 "puppet-hostname-selinux",
                 "semanage-selinux",
                 "load_policy-selinux",
                 "user-mail-selinux",
                 "system-mail-selinux",
                 "setrans-selinux",
                 "setfiles-selinux",
                 "dmesg-selinux"
                 ]
            }
            elsif  versioncmp($::operatingsystemrelease, '9.0') < 0  {
                notify { 'master::common::selinux':
                    message => 'WARNING: SELINUX NOT SUPPORTED ON JESSIE Debian 8!',
                }
            }
        }
        default: {
            warning("No SELinux policy package known for OS ${::operatingsystem} !")
        }
    }

    if $selinux_state and  $::selinux {
        selinux_enable_module {  $selinux_local_modules: }
        # selinux policies for postfix. Currently Centos7 specific, but will not always be.

        if ($::operatingsystem == 'centos') and (versioncmp($::operatingsystemrelease, '7.0') >= 0) and ($master::common::mta::mta == 'postfix') {
            selinux_enable_module { 'postfix_netadmin':  }
        }
        selboolean { 'allow_execmod':
            persistent => true,
            value => on
        }
        selboolean { 'allow_execstack':
            persistent => true,
            value => on
        }
        selboolean { 'puppet_manage_all_files':
            persistent => true,
            value => on
        }
        selboolean { 'allow_polyinstantiation':
            persistent => true,
            value => on
        }
    }

    if $selinux_state and !($::selinux) {
        notify { 'master::common::selinux::disabled':
            message => "WARNING: SELINUX DISABLED and ATTEMPTED STATE CHANGE to $selinux_state. REBOOT REQUIRED",
            loglevel => "warning",
        }
    }

    if !($::selinux_config_mode == $::selinux_current_mode) {
        notify { 'master::common::selinux::Selinux_state':
            message => "WARNING: SELINUX configured ${::selinux_config_mode} and current ${::selinux_current_mode} differ. REBOOT RECOMMENDED",
            loglevel => "warning",
        }
    }
}

define selinux_enable_module {
    $selinux_module_name = "/etc/selinux/local/${title}"
    if $::operatingsystem == 'redhat' {
      file { "${selinux_module_name}.te":
          ensure => present,
          source => "puppet:///modules/master/etc/selinux/local/${title}.te.CentOS",
          require => File['/etc/selinux/local'],
          notify =>  Exec["checkmodule-${title}"],
      }
    }
    else {
      file { "${selinux_module_name}.te":
          ensure => present,
          source => "puppet:///modules/master/etc/selinux/local/${title}.te.${::operatingsystem}",
          require => File['/etc/selinux/local'],
          notify =>  Exec["checkmodule-${title}"],
      }
    }
    exec { "checkmodule-${title}":
        command => "checkmodule -M -m -o ${selinux_module_name}.mod ${selinux_module_name}.te",
        cwd => "/etc/selinux/local",
        path => "/bin:/usr/bin:/usr/sbin",
        require => [
                    Package['checkpolicy'],
                    ],
        subscribe => [  File["${selinux_module_name}.te"], ],
        refreshonly => true,
        notify => Exec["semodule_package-${title}"],
    }

    exec { "semodule_package-${title}":
        command => "semodule_package -o ${selinux_module_name}.pp -m ${selinux_module_name}.mod",
        cwd => "/etc/selinux/local",
        path => "/bin:/usr/bin:/usr/sbin",
        require => [
                    Package['policycoreutils'],
                    ],
        subscribe => [
                      File["${selinux_module_name}.te"],
                      Exec["checkmodule-${title}"],
                      ],
        refreshonly => true,
        notify => Exec["semodule-${title}"],
    }

    exec { "semodule-${title}":
        command => "semodule -i /etc/selinux/local/${title}.pp",
        path => "/bin:/usr/bin:/usr/sbin",
        require => [
                    Package['policycoreutils'],
                    ],
        subscribe => [
                      File["${selinux_module_name}.te"],
                      Exec["checkmodule-${title}"],
                      Exec["semodule_package-${title}"],
                      ],
        refreshonly => true,
    }
}

define selinux_toggle_boolean ( $selinux_boolean = $title, $toggle = true ) {
    exec { "setsebool-${title}":
        command => "setsebool -P ${selinux_boolean} ${toggle}",
        path => "/bin:/usr/bin:/usr/sbin",
        require => Package['policycoreutils'],
        onlyif => "/usr/sbin/selinuxenabled",
    }
}

define selinux_activate {
    exec { '/usr/sbin/selinux-activate':
        subscribe =>  Package['selinux-basics'],
        refreshonly => true }

    notify { 'master::common::selinux':
        message => 'WARNING: INITIALIZING SELINUX REQUIRES A REBOOT',
        subscribe => Exec['/usr/sbin/selinux-activate'],
    }
}
