#
# define master::sshd
# ===================
#
# This is a helper define to create (or remove) a SSH daemon running
# on an alternate port.  Although it can be invoked directly, it is
# intended for use by master::service::ssh.
#
# The title MUST start with a lowercase letter (normally just 'p' will
# do fine) and be followed immediately by the port number.  This will
# be extracted via regular expression.
#
# By default, the name of the service and the executable (used for pam
# and hosts.allow) will be sshd-<port>, but this can be overridden
# with the $execname parameter and $servicename parameters.
#


define master::sshd (
    # Parameters
    # ----------
    #
    # ### execname
    # ### servicename
    # Name of the executable and service name (used for pam and
    # hosts.allow)
    #
    # If $execname is set to 'sshd', then the executable name will be
    # 'sshd' (so the same hosts.allow and pam.d rules will apply), but
    # the service name will still be sshd-<port>
    $execname        = undef,
    $servicename     = undef,

    # ### templates
    # ### final_templates
    # ### conf
    $templates       = $master::service::ssh::templates,
    $final_templates = $master::service::ssh::final_templates,
    $conf            = {},

    # ### pam_radius
    # Override the value of `master::common::pam::radius`
    # This only has meaning if
    $pam_radius      = undef,

    # ### remove
    # Making one Puppet run with `remove => true` will attempt to make
    # master::sshd clean up the instance, removing any files that are
    # no longer needed.
    #
    # Note that this is not actually required to disable a service, as
    # simply removing a definition for an alternate SSH port will mean
    # that the symlinks for it will not exist.
    $remove          = false,
)
{
    # ## Code
    include master::common::pam
    include master::common::systemd
    include master::service::ssh

    if $pam_radius == undef {
        $radius = $master::common::pam::radius
    }
    else {
        $radius = $pam_radius
    }
    $systemd_lib = $master::common::systemd::systemd_lib

    $port = regsubst($title,'^[a-z]+([0-9]+).*$','\1')
    if ! $port {
        fail("Unable to determine SSH port from ${title}")
    }

    if $execname {
        $sshd_execname = $execname
    }
    else {
        $sshd_execname = "sshd-${port}"
    }
    if $servicename {
        $sshd_servicename = $servicename
    }
    else {
        $sshd_servicename = "sshd-${port}"
    }

    $config = merge(hiera_hash('master::service::ssh::config',{}),$conf)

    file { [ "/etc/ssh/alt/${port}",
             "/etc/ssh/alt/${port}/init.d",
             "/etc/ssh/alt/${port}/pam.d",
             "/etc/ssh/alt/${port}/sbin",
             "/etc/ssh/alt/${port}/systemd",
           ]:
               ensure  => directory,
               mode    => '0644',
               backup  => false,
               force   => true,
               purge   => true,
               recurse => true,
    }

    # Ensure a PAM entry exists
    templatelayer { "/etc/ssh/alt/${port}/pam.d/${sshd_execname}":
        template => 'master/etc/pam.d/sshd',
        suffix   => $::osfamily,
    }
    if $remove {
        file { "/etc/pam.d/${sshd_execname}": ensure => absent }
    }
    elsif $sshd_execname != 'sshd' {
        file { "/etc/pam.d/${sshd_execname}":
            ensure => link,
            target => "/etc/ssh/alt/${port}/pam.d/${sshd_execname}",
        }
    }

    # Create a symlink to sshd with the selected name
    file { "/etc/ssh/alt/${port}/sbin/${sshd_execname}":
        ensure => link,
        target => '/usr/sbin/sshd',
        alias  => "/etc/ssh/alt/${port}/sbin/sshd-${port}",
        notify => Service["ssh-${port}"],
    }
    templatelayer { "/etc/ssh/alt/${port}/sshd_config":
        mode     => '0400',
        notify   => Service["ssh-${port}"],
        template => 'master/etc/ssh/sshd_config',
    }

    case $::osfamily {
        'Debian': {
            # Debian 9 has a properly functioning systemd.  All prior
            # versions throw errors on enable if the source isn't a
            # real file in /lib/systemd/system.
            #
            # Fortunately, whether or not systemd is enabled on older
            # versions, using only the SysV files will work, so we
            # only enable the SystemD files on 9+.
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                $systemd = true
                $systemd_service_type='notify'
            }
            else {
                $systemd = false
            }
            # Service can be enabled for either SystemD or SysV
            $enable = true

            # Files in alt are safe to write whether or not SystemD is available
            templatelayer { "/etc/ssh/alt/${port}/default":
                mode     => '0444',
                notify   => Service["ssh-${port}"],
                template => 'master/etc/ssh/alt/default',
            }
            templatelayer { "/etc/ssh/alt/${port}/init.d/${sshd_servicename}":
                mode     => '0755',
                suffix   => $::osfamily,
                notify   => Service["ssh-${port}"],
                template => 'master/etc/ssh/alt/init.d/ssh',
            }
            templatelayer { "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service":
                suffix   => $::osfamily,
                notify   => [ Exec['systemd-reload'],
                              Service["ssh-${port}"],
                            ],
                template => 'master/etc/ssh/alt/systemd/sshd.service',
            }
            if $remove {
                file { "/etc/init.d/${sshd_servicename}":
                    ensure => absent,
                }
                file { "/etc/systemd/system/${sshd_servicename}.service":
                    ensure => absent,
                    notify => Exec['systemd-reload'],
                }
            }
            else {
                file { "/etc/init.d/${sshd_servicename}":
                    ensure => link,
                    target => "/etc/ssh/alt/${port}/init.d/${sshd_servicename}",
                    notify => [ Exec['systemd-reload'],
                                Service["ssh-${port}"],
                              ],
                }
                if $systemd {
                    file { "/etc/systemd/system/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
                    file { "${systemd_lib}/system/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
                }
            }
        }
        'RedHat': {
            templatelayer { "/etc/ssh/alt/${port}/sysconfig":
                suffix   => "${::osfamily}-${::operatingsystemmajrelease}",
                notify   => Service["ssh-${port}"],
                template => 'master/etc/sysconfig/sshd',
            }
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                # SystemD-only
                #
                # We manage the SystemD symlinks directly, so the
                # service does not need to be enabled (and in fact it
                # will fail because it doesn't like the symlink farm)
                $enable = undef

                templatelayer { "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service":
                    suffix   => $::osfamily,
                    notify   => [ Exec['systemd-cleanup'],
                                  Service["ssh-${port}"],
                                ],
                    template => 'master/etc/ssh/alt/systemd/sshd.service',
                }
                if $remove {
                    file { "/etc/systemd/system/${sshd_servicename}.service":
                        ensure => absent,
                    }
                    file { "/etc/systemd/system/multi-user.target.wants/${sshd_servicename}.service":
                        ensure => absent,
                    }
                    if $sshd_servicename != "sshd-${port}" {
                        file { "/etc/systemd/system/sshd-${port}.service":
                            ensure => absent,
                        }
                    }
                }
                else {
                    file { "/etc/systemd/system/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
                    file { "${systemd_lib}/system/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
                    if $sshd_servicename != "sshd-${port}" {
                        # Also create the standard port-based service name
                        file { "/etc/systemd/system/sshd-${port}.service":
                            ensure => link,
                            target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                            notify => [ Exec['systemd-cleanup'],
                                        Service["ssh-${port}"],
                                      ],
                        }
                    }

                    # Enable the service
                    file { "/etc/systemd/system/multi-user.target.wants/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
                }
            }
            else {
                # SysV-only
                $enable = true
                templatelayer { "/etc/ssh/alt/${port}/init.d/${sshd_servicename}":
                    mode     => '0755',
                    suffix   => $::osfamily,
                    notify   => Service["ssh-${port}"],
                    template => 'master/etc/ssh/alt/init.d/ssh',
                }
                if $remove {
                    file { "/etc/init.d/${sshd_servicename}":
                        ensure => absent,
                    }
                }
                else {
                    file { "/etc/init.d/${sshd_servicename}":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/init.d/${sshd_servicename}",
                        notify => Service["ssh-${port}"],
                    }
                }
            }
        }
        'Suse': {
            if versioncmp($::operatingsystemrelease, '12.0') >= 0 {
                # SystemD-only
                #
                # We manage the SystemD symlinks directly, so the
                # service does not need to be enabled (and in fact it
                # will fail because it doesn't like the symlink farm)
                $enable = undef

                templatelayer { "/etc/ssh/alt/${port}/sysconfig":
                    suffix   => "${::osfamily}-${::operatingsystemmajrelease}",
                    notify   => Service["ssh-${port}"],
                    template => 'master/etc/ssh/alt/sysconfig',
                }
                templatelayer { "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service":
                    suffix   => $::osfamily,
                    notify   => [ Exec['systemd-cleanup'],
                                  Service["ssh-${port}"],
                                ],
                    template => 'master/etc/ssh/alt/systemd/sshd.service',
                }
                if $remove {
                    file { "/etc/systemd/system/${sshd_servicename}.service":
                        ensure => absent,
                    }
                    file { "/etc/systemd/system/multi-user.target.wants/${sshd_servicename}.service":
                        ensure => absent,
                    }
                    if $sshd_servicename != "sshd-${port}" {
                        file { "/etc/systemd/system/sshd-${port}.service":
                            ensure => absent,
                        }
                    }
                }
                else {
                    file { "/etc/systemd/system/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
# Adina begin addition
                    file { "${systemd_lib}/system/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
# Adina end addition
                    if $sshd_servicename != "sshd-${port}" {
                        # Also create the standard port-based service name
                        file { "/etc/systemd/system/sshd-${port}.service":
                            ensure => link,
                            target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                            notify => [ Exec['systemd-cleanup'],
                                        Service["ssh-${port}"],
                                      ],
                        }
                    }
                    # Enable the service
                    file { "/etc/systemd/system/multi-user.target.wants/${sshd_servicename}.service":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/systemd/${sshd_servicename}.service",
                        notify => [ Exec['systemd-cleanup'],
                                    Service["ssh-${port}"],
                                  ],
                    }
                }
            }
            else {
                # SysV-only
                $enable = true
                templatelayer { "/etc/ssh/alt/${port}/init.d/${sshd_servicename}":
                    mode     => '0755',
                    suffix   => $::osfamily,
                    notify   => Service["ssh-${port}"],
                    template => 'master/etc/ssh/alt/init.d/ssh',
                }
                templatelayer { "/etc/ssh/alt/${port}/sysconfig":
                    suffix   => "${::osfamily}-${::operatingsystemmajrelease}",
                    notify   => Service["ssh-${port}"],
                    template => 'master/etc/ssh/alt/sysconfig',
                }
                if $remove {
                    file { "/etc/init.d/${sshd_servicename}":
                        ensure => absent,
                    }
                }
                else {
                    file { "/etc/init.d/${sshd_servicename}":
                        ensure => link,
                        target => "/etc/ssh/alt/${port}/init.d/${sshd_servicename}",
                        notify => Service["ssh-${port}"],
                    }
                }
            }
        }
        default: {
            fail("I don't know how to configure SSHD on ${::operatingsystem}")
        }
    }

    if $remove {
        service { "ssh-${port}":
            ensure => stopped,
            enable => false,
            name   => $sshd_servicename,
        }
    }
    else {
        service { "ssh-${port}":
            ensure => running,
            enable => $enable,
            name   => $sshd_servicename,
        }
    }
}
