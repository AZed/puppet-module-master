#
# class master::common::xfs
# =========================
#
# XFS and extended attribute packages.  These were once included in
# master::common::base and should usually end up on all machines, but
# on some systems these packages are replaced by SGI-specific versions
# with different names.
#
# Under RHEL 6, the xfsdump and xfsprogs packages can only be installed
# if you are paying for an extra per-seat XFS layer.
#

class master::common::xfs {
    Class['master::common::base'] -> Class[$name]

    Package { ensure => present }
    package { 'attr': }

    case $::operatingsystem {
        'RedHat': {
            if versioncmp($::operatingsystemrelease, "7.0") < 0 {
            }
            else {
                package { 'xfsdump': }
                package { 'xfsprogs': }
            }
        }
        default: {
            package { 'xfsdump': }
            package { 'xfsprogs': }
        }
    }
}
