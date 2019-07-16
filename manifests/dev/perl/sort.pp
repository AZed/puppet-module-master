#
# class master::dev::perl::sort
# =============================
#
# Install Perl packages related to sorting
#

class master::dev::perl::sort {
    include master::dev::perl::base

    case $::operatingsystem {
        'centos','redhat': {
            package { 'perl-Sort-Maker': }
            package { 'perl-Sort-Naturally': }
            package { 'perl-Sort-Versions': }
        }
        'debian': {
            package { 'liblinux-kernelsort-perl': }
            package { 'libsort-fields-perl': }
            package { 'libsort-key-perl': }
            package { 'libsort-key-top-perl': }
            package { 'libsort-naturally-perl': }
            package { 'libsort-versions-perl': }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
