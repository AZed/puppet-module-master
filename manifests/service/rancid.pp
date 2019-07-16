#
class master::service::rancid (
    $rancid_cron_time      = '0,30',
    $rancid_list_of_groups = false,
    $manage_var_lib_rancid = true,
)
{
    # Install the RANCID packages
    package { "rancid": ensure => latest }
    #package { "rancid-core": ensure => latest }
    #package { "rancid-util": ensure => latest }

    # Add local RANCID account
    group { rancid: 
        gid    => 303,
        ensure => present 
    }
    user { rancid:
        gid        => rancid,
        ensure     => present,
        provider   => useradd,
        home       => "/var/lib/rancid",
        shell      => "/bin/bash",
        allowdupe  => false,
        require    => Package["rancid"],
    }

    templatelayer { "/var/lib/rancid/.bash_logout":
        require => User["rancid"]
    }
    templatelayer { "/var/lib/rancid/.bashrc":
        require => User["rancid"]
    }
    templatelayer { "/var/lib/rancid/.profile":
        require => User["rancid"]
    }

    # Fix RANCID directories
    if ( $manage_var_lib_rancid ) {
        file { "/var/lib/rancid":
            owner   => rancid,
            group   => rancid,
            recurse => true,
            require => [
                User[rancid],
                Package["rancid"],
            ]
        }
    }
    file { "/usr/lib/rancid":
        owner   => 'rancid',
        group   => 'rancid',
        recurse => true,
        require => [ User[rancid],
                    Package["rancid"]
                ]
    }
    file { "/var/log/rancid":
        mode    => '0640',
        owner   => 'rancid',
        group   => 'rancid',
        recurse => true,
        require => [ User[rancid],
                    Package["rancid"]
                ]
    }

    # Copy in script to handle SSHv1
    file { "/var/lib/rancid/bin/ssh1":
        source  => "puppet:///modules/master/rancid/ssh1",
        mode    => '0750',
        owner   => 'rancid',
        group   => 'rancid',
        require => File["/var/lib/rancid"],
    }

    # Copy in clogin file, modified for Force10 S50
    file { "/var/lib/rancid/bin/clogin":
        source  => "puppet:///modules/master/rancid/clogin",
        mode    => '0750',
        owner   => 'rancid',
        group   => 'rancid',
        require => File["/var/lib/rancid"],
    }

#  # Copy in rancid-fe file, modified for Force10 S50
#  file { "/var/lib/rancid/bin/rancid-fe":
#    source  => "puppet:///modules/master/rancid/rancid-fe",
#    mode    => '0750',
#    owner   => rancid,
#    group   => rancid,
#    require => File["/var/lib/rancid"],
#  }

#  # Copy in f10rancid file, modified for Force10 S50
#  file { "/var/lib/rancid/bin/f10rancid":
#    source  => "puppet:///modules/master/rancid/f10rancid",
#    mode    => '0750',
#    owner   => rancid,
#    group   => rancid,
#    require => File["/var/lib/rancid"],
#  }

    # Copy in srancid file, modified to work with our SMC
    file { "/var/lib/rancid/bin/srancid":
        source  => "puppet:///modules/master/rancid/srancid",
        mode    => '0750',
        owner   => 'rancid',
        group   => 'rancid',
        require => File["/var/lib/rancid"],
    }

    # Copy in the RANCID crontab
    templatelayer { "/etc/cron.d/rancid":
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        require => [
            File["/var/log/rancid"],
            File["/var/lib/rancid"],
            File["/usr/lib/rancid"],
        ],
    }

    ### The following items should have files in dist/${fqdn}

    # Copy in the RANCID configuration
    templatelayer { "/etc/rancid/rancid.conf":
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        require => [
            File["/var/log/rancid"],
            File["/var/lib/rancid"],
            File["/usr/lib/rancid"],
        ],
    }

    # Copy in .cloginrc for rancid user
    templatelayer { "/var/lib/rancid/.cloginrc":
        mode          => '0600',
        owner         => 'rancid',
        group         => 'rancid',
        parsenodefile => true,
        require       => [
            File["/var/log/rancid"],
            File["/var/lib/rancid"],
            File["/usr/lib/rancid"],
        ],
    }
}

define master::service::rancid::site (
    $email_list  = [],
    $router_list = [],
    $devices     = [],
)
{
    # Save the site name for later use
    $site_name = $title

    # Create the mail aliases
    mailalias { "rancid-${title}":
        ensure    => 'present',
        recipient => $email_list,
    }
    mailalias { "rancid-admin-${title}":
        ensure    => 'present',
        recipient => $email_list,
    }

    # Create the RANCID directory
    exec { "rancid-cvs-${title}":
        creates => "/var/lib/rancid/${title}",
        cwd     => "/var/lib/rancid",
        user    => "rancid",
        group   => "rancid",
        command => "/var/lib/rancid/bin/rancid-cvs ${title}",
        require => [
            Package["rancid"],
            User["rancid"],
        ],
    }

    # Copy the router.db
    templatelayer { "/var/lib/rancid/${title}/router.db": 
        ensure  => 'present',
        template => "${module_name}/var/lib/rancid/default/router.db",
        mode    => '0640',
        owner   => 'rancid',
        group   => 'rancid',
        require => [
            File["/var/log/rancid"],
            File["/var/lib/rancid"],
            File["/usr/lib/rancid"],
            Exec["rancid-cvs-${title}"],
            Package["rancid"],
        ],
    }
}
