#
# class master::dev::subversion
# =============================
#
# Sets up a full set of Subversion version control tools, and
# optionally a symlink of /svn to the main repository area.
#

class master::dev::subversion (
    # Parameters
    # ----------

    # ### svn_repo_base
    $svn_repo_base = false
)
{
    $common_packages = [
        'cvs2svn',
        'subversion',
        'svnmailer'
    ]

    case $::osfamily {
        'Debian': {
            $os_packages = [
                'svn-load',
                'svn-workbench',
                'subversion-tools',
            ]
        }
        'RedHat': {
            $os_packages = []
        }
        default: { $os_packages = [] }
    }

    $all_packages = concat($common_packages,$os_packages)
    ensure_packages($all_packages)

    if $svn_repo_base {
        file { "/${svn_repo_base}": ensure => directory }
        file { '/svn': ensure => $svn_repo_base }
    }
}
