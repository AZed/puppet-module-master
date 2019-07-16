#
# define master::trac_project
# ===========================
#
# ### Example
#
#     trac_project { "project-name":
#         fullname => "My Project",
#         repopath => "/var/git/myproject"
#     }
#
# Initializes and deploys a project if it does not exist.
#
# Note that a repo synchronization failure will NOT cause this to fail.
#
# Some manual configuration may be required in
# /var/trac/project-name/conf/trac.ini (such as disabling CVS
# repository syncing).
#
# For disaster recovery, the backup SQL dump can be directly deployed
# back into the appropriate database.
#
define master::trac_project (
    # ### fullname
    $fullname,

    # ### repotype
    $repotype='git',

    # ### repopath
    $repopath,

    # ### owner
    $owner=undef,

    # ### ownerplugins
    $ownerplugins='root',
) {
    # Code Comments
    # -------------

    master::pg_create_db { "trac-${title}":
        owner   => 'trac',
        require => Master::Pg_create_user['trac'],
    }

    $admins = join(hiera('admins'),' ')
    if $owner {
        $tracadmins = "${admins} ${owner}"
    }
    else {
        $tracadmins = $admins
    }

    exec { "trac_new_project-${title}":
        cwd         => '/var/trac',
        command     => "trac-admin /var/trac/${title} initenv '${fullname}' 'postgres://trac:@/trac-${title}' ${repotype} ${repopath} --inherit=/etc/trac/trac.ini",
        environment => 'PKG_RESOURCES_CACHE_ZIP_MANIFESTS=1',
        path        => '/sbin:/usr/sbin:/bin:/usr/bin',
        umask       => '022',
        creates     => "/var/trac/${title}",
        notify      => Exec["trac_defaultperms-${title}"],
        require     => [ File['/etc/trac/trac.ini'],
                         File['/var/trac'],
                         Master::Pg_create_db["trac-${title}"]
                         ],
        before      => File["trac.ini-${title}"],
    }

    file { "trac-version-${title}":
        ensure  => present,
        path    => "/var/trac/${title}/VERSION",
        owner   => 'root',
        group   => 'www-data',
        mode    => '0444',
        require => Exec["trac_new_project-${title}"],
    }

    file { "trac-attachments-${title}":
        ensure  => directory,
        path    => "/var/trac/${title}/attachments",
        owner   => $owner,
        group   => 'www-data',
        mode    => '2775',
        require => Exec["trac_new_project-${title}"],
    }
    file { "trac-conf-${title}":
        ensure  => directory,
        path    => "/var/trac/${title}/conf",
        owner   => $owner,
        group   => 'www-data',
        mode    => '2775',
        require => Exec["trac_new_project-${title}"],
    }
    file { "trac.ini-${title}":
        ensure  => present,
        path    => "/var/trac/${title}/conf/trac.ini",
        owner   => $owner,
        group   => 'www-data',
        mode    => '0664',
        require => Exec["trac_new_project-${title}"],
    }
    file { "trac-log-${title}":
        ensure  => directory,
        path    => "/var/trac/${title}/log",
        owner   => $owner,
        group   => 'www-data',
        mode    => '2775',
        require => Exec["trac_new_project-${title}"],
    }
    file { "trac-plugins-${title}":
        ensure  => directory,
        path    => "/var/trac/${title}/plugins",
        owner   => $ownerplugins,
        group   => 'www-data',
        mode    => '2750',
        require => Exec["trac_new_project-${title}"],
    }

    exec { "trac_deploy_project-${title}":
        cwd     => '/var/trac',
        command => "trac-admin /var/trac/${title} deploy /var/www/trac/${title}",
        environment => 'PKG_RESOURCES_CACHE_ZIP_MANIFESTS=1',
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        creates => "/var/www/trac/${title}",
        require => Exec["trac_new_project-${title}"],
    }

    # We want to set up default permissions upon new project creation,
    # but this is very dangerous because it destroys all existing
    # permissions, so we limit this both to when:
    #   /var/trac/${title} doesn't exist (as a refresh of trac_deploy_project)
    #   no TRAC_ADMIN permission exists
    exec { "trac_defaultperms-${title}":
        cwd         => '/var/trac',
        command     => "/usr/local/sbin/trac-defaultperms ${title} ${tracadmins}",
        environment => 'PKG_RESOURCES_CACHE_ZIP_MANIFESTS=1',
        path        => '/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin',
        unless      => "trac-admin /var/trac/${title} permission list | grep -E '^\w+\s+TRAC_ADMIN",
        refreshonly => true,
        require     => [ Exec["trac_deploy_project-${title}"],
                         File['/usr/local/sbin/trac-defaultperms'],
                         ],
    }
}
