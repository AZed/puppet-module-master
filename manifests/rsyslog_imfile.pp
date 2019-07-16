#
# define master::rsyslog_imfile
# =============================
#
# This is a shortcut helper define to automatically create an imfile
# log importer configuration for rsyslog.  It can be used from any
# class in any module, but the resources created will only be
# activated when master::service::rsyslog is run
#
# Use of rsyslog v8.1.5 or higher is highly recommended for this define
# for both inotify mode (which allows for wildcards in filenames, or
# both filenames and paths after 8.25.0) and automatic statefile
# handling.  If you are using rsyslog before that point you will get a
# (non-configurable) default of 10 second polling, and must configure
# your statefiles manually.
#

define master::rsyslog_imfile (
    # Parameters
    # ----------
    #
    # ### owner
    # ### group
    # ### mode
    # Config file ownership and permissions
    $owner       = 'root',
    $group       = 'root',
    $mode        = '0444',

    # ### dir
    # Where to place the configuration file
    $dir         = '/etc/rsyslog.d',

    # ### file
    # File that should be imported
    $file        = false,

    # ### statefile
    # file in the rsyslog work directory that keeps track of which
    # parts of the imfile have been processed.
    #
    # REQUIRED AND MUST BE UNIQUE if tracking more than one imfile in
    # rsyslog 7 or earlier
    #
    # DEPRECATED for rsyslog 8 or later
    $statefile   = false,

    # ### facility
    # syslog facility to be assigned to lines read
    $facility    = 'local0',

    # ### readmode
    # parse mode for multiline messages (0-2)
    $readmode    = false,

    # ### ruleset
    # binds the listener to a specific ruleset
    $ruleset     = false,

    # ### severity
    # syslog severity to be assigned to lines read
    $severity    = 'notice',
)
{
    # ## Code
    if ! $file {
        fail("No input file specified for rsyslog_imfile ${title}")
    }

    # Set tag from title, as $title changes going to the template
    $imfile_tag = $title

    @templatelayer { "${dir}/${title}.conf":
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        notify   => Service['rsyslog'],
        require  => Package['rsyslog'],
        template => 'master/etc/rsyslog.d/imfile.erb',
        tag      => 'rsyslog',
    }
}
