#
# define master::file
# ===================
#
# This define uses the title as the full path to the file to create,
# sourcing it from the matching directory in the files/ area of the
# calling module.
#
# The only valid 'ensure =>' values are 'present' and 'absent', where
# 'present' is the default.  Recursion is not allowed.
#
# owner, group, mode, and backup (clientbucket) can optionally be
# specified, and default to 'root', 'root', and '0444' respectively.
#
# if $prefix is set, it will be prepended to the path ($title) which
# follows the module name; this should generally be a path component
# beginning with a slash (e.g. prefix => "/specialdir"
#
# if $suffix is set, the string "-${suffix}" will be appended when
# looking for the file in the module templates area (but not the
# nodefiles override).
#
# The differences between this and a templatelayer are:
#  * no parsing will be done under any circumstances
#  * nodefiles will not be checked
#  * contents are drawn from the files/ area instead of templates/
#

define master::file (
    $ensure = 'present',
    $module = $caller_module_name,
    $prefix = false,
    $suffix = false,
    $owner  = 'root',
    $group  = 'root',
    $mode   = '0444',
    $backup = undef,
    $tag    = undef,
)
{
    if $prefix {
        $realprefix = $prefix
    }
    else {
        $realprefix = ""
    }

    if $suffix {
        $realsuffix = "-${suffix}"
    }
    else {
        $realsuffix = ""
    }

    $source = "${module}${realprefix}${title}${realsuffix}"

    file { $title :
        ensure => $ensure,
        owner => $owner, group => $group, mode => $mode,
        source => "puppet:///modules/${source}",
        backup => $backup,
        tag => $tag,
    }
}
