#
# class master::service::freeradius
#
# For this class to function, master::common::securid must also be
# included, even if no SecurID secret is available.
#

class master::service::freeradius (
    $tfti_proxy                = false,
    $tfti_address              = '',
    $tfti_radius_shared_secret = '',
    $devices                   = [],
    $users                     = [],
    $default_auth_type         = '',
) {
    
  $osnameversion = "${::operatingsystem}${::operatingsystemmajrelease}"

  case $osnameversion {
        'centos7','redhat7': { 
                                 $freeradius_config_dir = '/etc/raddb'
                                 $freeradius_group = 'radiusd'
                                 $freeradius_service = 'radiusd'
                                 $freeradius_conf_users = "${freeradius_config_dir}/mods-config/files/authorize"
                                 $freeradius_conf_preproxy_users = "${freeradius_config_dir}/mods-config/files/pre-proxy"
        }
        'centos6','redhat6': { 
                                 $freeradius_config_dir = '/etc/raddb'
                                 $freeradius_group = 'radiusd'
                                 $freeradius_service = 'radiusd'
                                 $freeradius_conf_users = "${freeradius_config_dir}/users"
                                 $freeradius_conf_preproxy_users = "${freeradius_config_dir}/preproxy_users"
        }
        'debian8':           { 
                                 $freeradius_config_dir = '/etc/freeradius'
                                 $freeradius_group = 'freerad'
                                 $freeradius_service = 'freeradius'
                                 $freeradius_conf_users = "${freeradius_config_dir}/users"
                                 $freeradius_conf_preproxy_users = "${freeradius_config_dir}/preproxy_users"
        }
        default:             { 
                                 $freeradius_config_dir = '/etc/freeradius'
                                 $freeradius_group = 'freerad'
                                 $freeradius_service = 'freeradius'
                                 $freeradius_conf_users = "${freeradius_config_dir}/users"
                                 $freeradius_conf_preproxy_users = "${freeradius_config_dir}/preproxy_users"
        }
  }


    # Install freeradius
    package { "freeradius":
        ensure => present,
        before => [
            File["${freeradius_config_dir}"],
            File["${freeradius_config_dir}/clients"],
            Templatelayer["${freeradius_config_dir}/radiusd.conf"],
            Templatelayer["${freeradius_config_dir}/clients.conf"],
            Templatelayer["${freeradius_config_dir}/proxy.conf"],
            Templatelayer["${freeradius_conf_preproxy_users}"],
            Templatelayer["${freeradius_conf_users}"],
        ],
    }
    package { "freeradius-ldap":
        ensure  => present,
        require => Package["freeradius"]
    }

    # Make sure the freeradius group exists
    group { $freeradius_group:
        ensure => present
    }

    # Make sure freeradius is running
    service { $freeradius_service:
        ensure    => true,
        hasstatus => false,
        enable   => true,
        require   => [
            Group[$freeradius_group],
            Package["freeradius"],
            Templatelayer["${freeradius_config_dir}/radiusd.conf"],
            Templatelayer["${freeradius_config_dir}/clients.conf"],
            Templatelayer["${freeradius_config_dir}/clients/css.conf"],
            Templatelayer["${freeradius_config_dir}/proxy.conf"],
            Templatelayer["${freeradius_conf_preproxy_users}"],
            Templatelayer["${freeradius_conf_users}"],
        ],
    }

    # Make sure the config directory is correct
    file { $freeradius_config_dir:
        ensure  => 'directory',
        mode    => '2640',
        owner   => root,
        group   => $freeradius_group,
        require => [
            Package["freeradius"],
            Group[$freeradius_group],
        ],
    }

    # Make sure the clients directory exists inside the config directory
    file { "${freeradius_config_dir}/clients":
        ensure  => 'directory',
        mode    => '2640',
        owner   => root,
        group   => $freeradius_group,
        require => [
            Package["freeradius"],
            Group[$freeradius_group],
            File["${freeradius_config_dir}"]
        ],
    }

    # Copy in clients.conf
    templatelayer { "${freeradius_config_dir}/clients.conf":
        mode          => '0640',
        owner         => 'root',
        group         => $freeradius_group,
        parsenodefile => true,
        require       => File["${freeradius_config_dir}"],
        notify        => Service[$freeradius_service],
    }

    # Copy in additional configuration files
    templatelayer { "${freeradius_config_dir}/clients/css.conf":
        mode          => '0640',
        owner         => 'root',
        group         => $freeradius_group,
        parsenodefile => true,
        require       => File["${freeradius_config_dir}/clients"],
        notify        => Service[$freeradius_service],
    }

    # Copy in radius.conf
    templatelayer { "${freeradius_config_dir}/radiusd.conf":
        mode    => '0640',
        owner   => 'root',
        group   => $freeradius_group,
        require => File["${freeradius_config_dir}"],
        notify  => Service[$freeradius_service],
    }

  # Copy in users file
    templatelayer { "${freeradius_conf_users}":
        mode          => '0640',
        owner         => 'root',
        group         => $freeradius_group,
        parsenodefile => true,
        require       => File["${freeradius_config_dir}"],
        notify        => Service[$freeradius_service],
    }

    # Copy in preproxy_users file
    templatelayer { "${freeradius_conf_preproxy_users}":
        mode    => '0640',
        owner   => 'root',
        group   => $freeradius_group,
        require => File["${freeradius_config_dir}"],
        notify  => Service[$freeradius_service],
    }

    # Copy in proxy.conf file
    templatelayer { "${freeradius_config_dir}/proxy.conf":
        mode          => '0640',
        owner         => root,
        group         => $freeradius_group,
        parsenodefile => true,
        require       => File["${freeradius_config_dir}"],
        notify        => Service[$freeradius_service],
    }

    # Copy in default configuration
    templatelayer { "${freeradius_config_dir}/sites-available/default":
        mode    => '0640',
        owner   => 'root',
        group   => $freeradius_group,
        require => File["${freeradius_config_dir}"],
    }

    # Copy in the Nagios tests for this service
    templatelayer { "/usr/share/nagios-client/client.d/20_Proc_freeradius":
        mode    => '0600',
        owner   => 'root',
        group   => 'root',
        require => File["/usr/share/nagios-client"],
    }

    # Remove inner-tunnel from sites-enabled
    file { "${freeradius_config_dir}/sites-enabled/inner-tunnel":
        ensure  => absent,
        require => File["${freeradius_config_dir}"],
    }

    # Remove control-socket from sites-enabled
    file { "${freeradius_config_dir}/sites-enabled/control-socket":
        ensure  => absent,
        require => File["${freeradius_config_dir}"],
    }
}
