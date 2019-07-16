#
# define master::rsyslog_config
# =============================
#
#
# This is a shortcut helper define to create a virtual templatelayer
# resource for a rsyslog configuration file tagged as 'rsyslog' that
# can be used in any class in any module, but will be activated when
# master::service::rsyslog is run.
#
# Normally, it will be simpler to pass a $configfiles hash as a
# parameter to master::service::rsyslog than to use this define
# directly.
#
# Using this define on its own does not cause anything to happen on a
# system if master::service::rsyslog is not active.  It will fail if
# the rsyslog package is not managed.
#

define master::rsyslog_config (
    # Parameters
    # ----------
    #
    # ### owner
    # ### group
    # ### mode
    # Config file ownership and permissions
    #
    # ### dir
    # Directory in which to place the config files
    #
    # ### template
    # Required parameter for template source
    #
    $owner       = 'root',
    $group       = 'root',
    $mode        = '0444',
    $dir         = '/etc/rsyslog.d',
    $template    = false
)
{
    if ! $template {
        fail("No template specified for rsyslog_configfile ${title}")
    }

    @templatelayer { "${dir}/${title}.conf":
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        notify   => Service['rsyslog'],
        require  => Package['rsyslog'],
        template => $template,
        tag      => 'rsyslog',
    }
}
