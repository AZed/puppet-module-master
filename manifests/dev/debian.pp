#
# class master::dev::debian
# =========================
#
# Packages used for creating Debian packages
#

class master::dev::debian {
    require master::common::package_management

    include master::common::editors
    include master::dev::base
    include master::dev::git

    case $::operatingsystem {
        'debian': {
            $packages = [
                'cdbs',
                'checkinstall',
                'devscripts',
                'devscripts-el',
                'debhelper',
                'debian-faq',
                'dh-autoreconf',
                'dh-kpatches',
                'dh-make',
                'dh-make-perl',
                'doc-debian',
                'dpatch',
                'dpkg-dev',
                'dput',
                'fakeroot',
                'git-buildpackage',
                'kernel-package',
                'kernel-patch-scripts',
                'module-assistant',
                'python-apt',
            ]
        }
        default: {
            $packages = []
        }
    }
    ensure_packages($packages)
}
