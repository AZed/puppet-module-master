#
# class master::dev::perl::data_compare
# =====================================
#
# Perl packages for data comparison
#

class master::dev::perl::data_compare {
    include master::dev::perl::base

    case $::osfamily {
        'redhat': {
            package {  "perl-Data-Compare": ensure => latest,
            }
        }
        'debian': {
            package { "libdata-compare-perl": ensure => latest,
            }
        }
        default: { }
    }
}
