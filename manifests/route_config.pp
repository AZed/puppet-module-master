#
# define master::route_config
# ===========================
#
# This is a shortcut helper define to create a routing configuration
# file on RedHat- and SuSE-based system.  It is intended to be called
# from master::common::network, but can be invoked manually.
#
# TODO: consider making this a virtual resource realized in
# master::common::network so that it can notify the network service
# and be guaranteed to be complete when the network class is.
#

define master::route_config (
    # Parameters
    # ----------
    #
    # ### dir
    # Directory in which to create the files
    $dir       = '/etc/sysconfig/network-scripts',
    #
    # ### owner
    # ### group
    # ### mode
    # Owner group and mode of the file
    $owner     = 'root',
    $group     = 'root',
    $mode      = '0444',

    # ### templates
    # Template fragments to insert at the top of the file
    #
    $templates = false,

    # ### lines
    # Array of lines to place after templates, if any
    $lines = false,
)
{
    templatelayer { "${dir}/${title}":
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        template => 'master/etc/sysconfig/network-scripts/route.erb',
        tag      => 'route_config',
    }
}
