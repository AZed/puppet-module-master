#
# master::dev::bazaar
# ===================
#
# Installs the Bazaar version control system
#
# Note that versions of Bazaar prior to version 2.0 should not be
# used, so set the package repositories appropriately.
#

class master::dev::bazaar (
    # ### bzr_repo_base
    # Bazaar Repository Base (where the /bzr symlink points)
    $bzr_repo_base = undef
)
{
    require master::dev::python
    require master::dev::subversion

    package { 'bzr': }
    package { 'bzrtools': }

    if $bzr_repo_base {
        file { "/${bzr_repo_base}": ensure => directory }
        file { '/bzr': ensure => $bzr_repo_base }
    }
}
