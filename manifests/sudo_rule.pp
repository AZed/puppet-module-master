#
# master::sudo_rule
#
# This is a shortcut helper define to create a virtual templatelayer
# resource for a sudoers ruleset tagged as 'sudo_rule' that can be
# used in any class in any module, but will be activated when
# master::common:sudo is run.
#
# Using this define on its own does not cause anything to happen on a
# system if master::common::sudo is not active.  It will fail if the
# target directory is not managed (normally handled by
# master::common::sudo).  It is provided for convenience so that a
# series of rules can be sent as an array with a single directory
# location.
#

define master::sudo_rule (
    $owner       = 'root',
    $group       = 'root',
    $mode        = '0440',
    $module      = $caller_module_name,
    $dir         = '/etc/sudoers.d'
)
{
    @templatelayer { "${dir}/${title}":
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        module  => $module,
        require => File[$dir],
        tag     => 'sudo_rule',
    }
}
