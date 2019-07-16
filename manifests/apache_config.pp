#
# define master::apache_config
# ============================
#
# This is a shortcut helper define to place an Apache configuration
# file.  Using it will activate master::service::apache so that it
# knows what version is in use so it can determine the correct
# location and so it can notify the service.
#
# The extension '.conf' will be applied automatically and should not
# be specified in the title.
#
# Normally, it will be simpler to pass a $configfiles hash as a
# parameter to master::service::apache than to use this define
# directly.
#

define master::apache_config (
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
    # ### enable
    # For Apache 2.4 and later, whether to create or remove a symlink
    # in conf-enabled.  In earlier versions, this has no effect.
    #
    # ### template
    # Required parameter for template source
    #
    $owner       = 'root',
    $group       = 'root',
    $mode        = '0444',
    $dir         = undef,
    $enable      = true,
    $template    = undef,
)
{
    include master::service::apache
    if $dir {
        $realdir = $dir
    }
    else {
        $apacheversion = $master::service::apache::apacheversion
        if versioncmp($apacheversion, '2.4') >= 0 {
            $realdir = '/etc/apache2/conf-available'
        }
        else {
            $realdir = '/etc/apache2/conf.d'
        }
    }
    if ! $template {
        fail("No template specified for apache_config ${title}")
    }

    templatelayer { "${realdir}/${title}.conf":
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        notify   => Service['httpd'],
        require  => Package['rsyslog'],
        template => $template,
        tag      => 'apache',
    }

    if $enable and versioncmp($apacheversion, '2.4') >= 0 {
        /* Convert to relative symlink if in default directory */
        if $realdir == '/etc/apache2/conf-available' {
            $realtarget = "../conf-available/${title}.conf"
        }
        else {
            $realtarget = "${realdir}/${title}.conf"
        }

        file { "/etc/apache2/conf-enabled/${title}.conf":
            ensure => link,
            target => $realtarget,
        }
    }
    else {
        file { "/etc/apache2/conf-enabled/${title}.conf":
            ensure => absent,
        }
    }
}
