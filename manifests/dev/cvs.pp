#
# class master::dev::cvs
# ======================
#
# Installs a CVS server, either using stock CVS, CVS with the ACL
# patches applied, or CVSNT.
#
# Use of CVS with ACL patches installed requires a custom repository
# not handled by this module.
#

class master::dev::cvs (
    # Parameters
    # ----------

    # ### cvs_package
    # CVS provider package
    # Valid values are cvs, cvsnt, or cvsacl
    $cvs_package = 'cvs',

    # ### cvsroot
    # Location of cvsroot (where the symlink of /cvsroot points)
    $cvsroot = undef
)
{
    require master::common::package_management

    Package { ensure => installed }
    case $cvs_package {
        'cvs','cvsacl': {
            package { 'cvs': }
        }
        'cvsnt': {
            package { 'cvsnt': }

            nodefile { '/etc/cvsnt/PServer':
                owner => 'root', group => 'root', mode => '0400',
                defaultensure => 'ignore',
                require => Package['cvsnt'],
            }
        }
        default: {
            fail("Unrecognized CVS package '${cvs_package}' requested on host ${::fqdn}!")
        }
    }

    package { 'cvs2cl': }
    package { 'cvsgraph': }
    package { 'cvsps': }

    if $cvsroot {
        file { '/cvsroot': ensure => $cvsroot }
    }
}
