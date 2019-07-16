#
define master::service::gluster::volume(
    $bricks     = [],
    $transport  = "tcp",
    $replica    = 1,
    $stripe     = 1,
    $start      = undef,
    $nfs        = false,
    $auth_allow = undef
) {
    # Assemble the replica arguments
    $replica_arg = $replica ? {
        '1'     => "",
        default => "replica ${replica} "
    }

    # Assemple the stripe arguments
    $stripe_arg = $stripe ? {
        '1'     => "",
        default => "stripe ${stripe} "
    }

    # Assemble the brick arguments
    $bricks_arg = inline_template("<%= @bricks.collect {|x| ''+x.chomp('/')+'/${name}' }.join(' ') %>")

    # Create the volume if it doesn't already exist
    exec { "gluster-volume-create-${name}":
        command   => "/usr/sbin/gluster volume create ${name} ${replica_arg} ${stripe_arg} transport ${transport} ${bricks_arg}",
        unless    => "/usr/sbin/gluster volume info | /bin/grep -c '^Volume Name: ${name}'",
        logoutput => on_failure,
    }

    # start/stop/ignore the volume
    if ( $start == true ) {
        exec { "gluster-volume-start-${name}":
            command   => "/usr/sbin/gluster volume start ${name}",
            unless    => "/usr/sbin/gluster volume info ${name} | /bin/grep -c '^Status: Started'",
            logoutput => on_failure,
            require   => Exec["gluster-volume-create-${name}"],
        }
    } elsif ( $start == false ) {
        exec { "gluster-volume-stop-${name}":
            command => "/usr/bin/yes | /usr/sbin/gluster volume stop ${name}",
            unless  => "/usr/sbin/gluster volume info ${name} | /bin/grep '^Status: ' | grep -vc 'Started'",
            logoutput => on_failure,
            require   => Exec["gluster-volume-create-${name}"],
        }
    } else {
        # Undef; don't manage state
    }

    # Enable disable NFS
    if ( $nfs == true ) {
        exec { "gluster-volume-nfs-enable-${name}":
            command   => "/usr/sbin/gluster volume set ${name} nfs.disable off",
            unless    => "/usr/sbin/gluster volume info ${name} | /bin/grep -c '^nfs.disable: off'",
            logoutput => on_failure,
            require   => Exec["gluster-volume-create-${name}"],
        }
    } elsif ( $nfs == false ) {
        exec { "gluster-volume-nfs-disable-${name}":
            command   => "/usr/sbin/gluster volume set ${name} nfs.disable on",
            unless    => "/usr/sbin/gluster volume info ${name} | /bin/grep -c '^nfs.disable: on'",
            logoutput => on_failure,
            require   => Exec["gluster-volume-create-${name}"],
        }
    } else {
        # Undef; don't manage NFS state
    }
    
    # Set auth.allow on the volume
    if ( $auth_allow ) {
        exec { "gluster-volume-set-auth-allow-${name}":
            command   => "/usr/sbin/gluster volume set ${name} auth.allow ${auth_allow}",
            unless    => "/usr/sbin/gluster volume info ${name} | /bin/grep -c '^auth.allow: ${auth_allow}'",
            logoutput => on_failure,
            require   => Exec["gluster-volume-create-${name}"],
        }
    } else {
        exec { "gluster-volume-reset-auth-allow-${name}":
            command   => "/usr/sbin/gluster volume set ${name} auth.allow *",
            unless    => "/usr/sbin/gluster volume info ${name} | /bin/grep -c '^auth.allow: \\*'",
           
            logoutput => on_failure,
            require   => Exec["gluster-volume-create-${name}"],
        }
    }

}
