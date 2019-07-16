#
# class master::service:postgresql
# ================================
#
# Sets up a PostgreSQL server and provides a set of defines for
# automatically setting up users and databases.
#
# WARNING: this does not necessarily play nicely with multiclustering
# or multiple versions.  It assumes that you want to use the most
# recent Postgresql version for your OS and are only using cluster
# 'main'.
#

class master::service::postgresql (
    # Parameters
    # ----------

    # ### checkpoint_segments
    #
    # Checkpoint segments for new transactions
    # (only valid for PostgreSQL < 9.6)
    #
    # This is the number of 16MB WAL segments written for new
    # transactions before a checkpoint is forced.  Checkpoints are
    # resource-intensive and can become a performance bottleneck.  The
    # PostGRESQL default is 3, though 10+ is recommended by the
    # PostGRESQL tuning guide except for very small configurations.
    # Large settings use more disk and cause the database to take longer
    # to recover.  Setting this value higher than 64 (1 GB WAL) should
    # only be done for bulk loading.
    #
    # For PostgreSQL >= 9.6, use min_wal_size and max_wal_size
    $checkpoint_segments = 10,

    # ### data_directory_base
    #
    # Base Data Directory
    #
    # This is a filesystem path to which will be appended the version
    # and the cluster name to get the full data_directory setting
    # (e.g. setting $data_directory_base to /var/lib/postgresql for a
    # default 9.1 cluster results in:
    # 'data_directory = /var/lib/postgresql/9.1/main'
    $data_directory_base = '/var/lib/postgresql',

    # ### effective_cache_size
    #
    # Effective cache size used by query planning
    #
    # This should generally be set to roughly half of available memory
    # (or the sum of free + cached memory when looking at the 'free'
    # command)
    #
    # If memorysizeinbytes is available in facter (which it will on
    # Linux systems using this module), then setting this value to
    # 'false' will cause it to be automatically computed and set to half
    # of available memory.  Otherwise, setting this value to 'false'
    # will default the value to '256MB'.
    #
    # It is a query tuning parameter only, not an allocation
    $effective_cache_size = false,

    # ### fsync
    #
    # Use fsync?  Valid values are 'on' and 'off' Turning this off gains
    # you performance but greatly increases the chance of database
    # corruption during an unclean shutdown (e.g. due to power failure,
    # networked filesystem outage, etc.)
    #
    # DO NOT TURN THIS OFF unless you are absolutely certain what you
    # are doing or don't care at all about the integrity of the data.
    $fsync = 'on',

    # ### listen_addresses
    #
    # What IP addresses will PostgreSQL listen on?  Usual values are
    # 'localhost' and '*'
    $listen_addresses = 'localhost',

    # ### log_directory
    #
    # Directory where log files are written
    # Can be absolute or relative to PGDATA
    $log_directory = '/var/log/postgresql',

    # ### logging_collector
    #
    # Enable capturing of stderr and csvlog into log files.
    # Valid values are 'on' and 'off'
    $logging_collector = 'on',

    # ### max_wal_size
    #
    # Maximum size to let the WAL grow to between automatic WAL
    # checkpoints.  If you were previously using checkpoint_segments,
    # convert roughly via the formula:
    #
    #     max_wal_size = (3 * checkpoint_segments) * 16MB
    #
    # The default value is larger than it used to be under
    # checkpoint_segments, and may no longer need tuning.
    $max_wal_size = undef,

    # ### min_wal_size
    #
    # As long as WAL disk usage stays below this setting, old WAL
    # files are always recycled for future use at a checkpoint, rather
    # than removed. This can be used to ensure that enough WAL space
    # is reserved to handle spikes in WAL usage, for example when
    # running large batch jobs.
    $min_wal_size = undef,

    # ### pam_cidr
    #
    # CIDR addresses that will allow access via pam_users, below.
    # Local socket access will also be allowed.
    $pam_cidr = [ '127.0.0.1/32', '::1/128', ],

    # ### pam_users
    #
    # Array of usernames that will be allowed access to all databases
    # from approved IPs after authenticating via PAM.  Local pg
    # userids will be created for these users if they do not already
    # exist.
    #
    $pam_users = false,

    # ### pam_users_createdb
    #
    # Determines whether userids created for pg_pam_users will be
    # allowed to create their own databases
    $pam_users_createdb = false,

    # ### pg_hba_templates
    #
    # Array of template fragments to transclude into pg_hba.conf
    $pg_hba_templates = false,

    # ### pg_hba_lines
    #
    # Array of lines to place at the end of pg_hba.conf
    $pg_hba_lines = false,

    # ### pg_ident_map
    #
    # Hash of mapnames with a subhash mapping ident username to pg
    # username.  Entries in this hash are added to a default map named
    # 'admin' which allows the root user to locally authenticate both
    # as root and as postgres.
    #
    # This entry is looked up in Hiera via a merged hash.  If you need
    # to map the same ident username to multiple PG usernames, use
    # pg_ident_templates or pg_ident_lines, below.
    #
    # Example:
    #
    #   master::service::postgresql::pg_ident_map:
    #     mygroup:
    #       user1: pgname1
    #       user2: pgname2
    #
    $pg_ident_map = lookup('master::service::postgresql::pg_ident_map',
                           Hash, 'hash', {}),

    # ### pg_ident_templates
    #
    # Array of template fragments to transclude into pg_ident.conf
    $pg_ident_templates = false,

    # ### pg_ident_lines
    # Array of lines to place at the end of pg_ident.conf
    $pg_ident_lines = false,

    # ### port
    #
    # What port will PostgreSQL listen on?
    $port = '5432',

    # ### shared_buffers
    #
    # Size of shared buffers dedicated to PostgreSQL data caching
    # The value of shmmax in master::common::base needs to be 8
    # megabytes larger than this for PostgreSQL to reliably start.
    #
    # If this value is set to false and memorysizeinbytes is available
    # in facter, then this will automatically be set to one quarter of
    # the available memory.  If memorysizeinbytes is not available, then
    # setting this to false will cause the default value of '24MB' to be
    # used.
    $shared_buffers = false,

    # ### servicename
    #
    # Name of the service.  Default is to autodetect by OS version.
    $servicename = false,

    # ### ssl_ciphers
    #
    # Allowed SSL ciphers
    $ssl_ciphers = 'HIGH:!ADH:-kEDH:!kRSA:!MD5:-SHA1:!DSS:ECDHE-RSA-AES128-SHA',

    # ### version
    #
    # Version number of primary Postgresql database in use
    # Default is to autodetect by OS version
    $version = false
)
{
    # Code Comments
    # -------------

    include master::common::base
    include master::common::package_management

    /* ### Set version, service, and path variables as necessary ### */
    if $servicename {
        $pgservice = $servicename
    }
    else {
        case $::operatingsystem {
            'Debian': {
                case $::release_majornum {
                    '5': {
                        $pgservice = 'postgresql-8.3'
                    }
                    default: {
                        $pgservice = 'postgresql'
                    }
                }
            }
            default: {
                $pgservice = 'postgresql'
            }
        }
    }

    if $version {
        $pgversion = $version
    }
    else {
        case $::operatingsystem {
            'Debian': {
                case $::release_majornum {
                    '5': {
                        $pgversion = '8.3'
                    }
                    '6': {
                        $pgversion = '8.4'
                    }
                    '7': {
                        $pgversion = '9.1'
                    }
                    '8': {
                        $pgversion = '9.4'
                    }
                    '9': {
                        $pgversion = '9.6'
                    }
                    default: {
                        fail("PostgreSQL version not defined for Debian release ${::release_majornum}!")
                    }
                }
            }
            default: {
                fail("PostgreSQL versions unknown under ${::operatingsystem} -- set manually")
            }
        }
    }
    $pgdirmain = "/etc/postgresql/${pgversion}/main"


    /* ### Main rules begin here ### */

    case $::operatingsystem {
        'debian': {
            package { "postgresql-${pgversion}":
                alias   => 'postgresql',
                ensure  => latest,
                require => File[$data_directory_base],
            }
            package { "postgresql-doc-${pgversion}": ensure => latest }
            package { "postgresql-contrib-${pgversion}":
                ensure  => latest,
                require => Package['postgresql'],
            }
        }
        default: {
            package { 'postgresql':
                ensure  => latest,
                require => File[$data_directory_base],
            }
            package { 'postgresql-docs': ensure => latest }
            package { 'postgresql-contrib':
                ensure  => latest,
                require => Package['postgresql'],
            }
        }
    }

    file { '/etc/postgresql': ensure => directory,
        owner => root, group => root, mode => '0755',
    }
    file { "/etc/postgresql/${pgversion}":
        ensure  => directory,
        owner   => root,
        group   => postgres,
        mode    => '0755',
        require => Package['postgresql'],
    }
    file { $pgdirmain: ensure => directory,
        owner   => root,
        group   => postgres,
        mode    => '0755',
        require => Package['postgresql'],
    }
    file { $data_directory_base: ensure => directory }

    # If $data_directory_base has been set to something other than the
    # default, and Postgresql has not yet been installed on the system,
    # ensure that the default directory is a symlink to the new base
    # before the package is installed to prevent base install and
    # configuration from becoming confused.
    #
    # To avoid any chance of destroying data, this does nothing if the
    # default already exists as a directory.
    if $data_directory_base != '/var/lib/postgresql' {
        exec { 'link-default-postgresql':
            command => "ln -s ${data_directory_base} /var/lib/postgresql",
            creates => '/var/lib/postgresql',
            cwd  => '/var/lib',
            path => '/bin:/usr/bin',
            require => File[$data_directory_base],
            before => Package['postgresql'],
        }
    }


    Templatelayer {
        notify => Service['postgresql'],
        require => Package['postgresql'],
    }
    templatelayer { "${pgdirmain}/postgresql.conf":
        template => "master/etc/postgresql/postgresql.conf-${pgversion}",
        group    => postgres,
        require  => Package['postgresql'],
    }

    templatelayer { "${pgdirmain}/pg_hba.conf":
        template => "master/etc/postgresql/pg_hba.conf",
        group   => postgres,
        require => Package['postgresql'],
    }
    templatelayer { "${pgdirmain}/pg_ident.conf":
        template => "master/etc/postgresql/pg_ident.conf",
        group   => postgres,
        require => Package['postgresql'],
    }
    master::pg_create_admin { 'root': }
    if $pam_users {
        master::pg_create_user { $pam_users: createdb => $pam_users_createdb }
    }

    service { $pgservice: ensure => running,
        alias => 'postgresql',
        hasrestart => true,
        hasstatus => true,
        require => Package['postgresql']
    }

    master::nagios_check { '20_Proc_postgres': }
}
