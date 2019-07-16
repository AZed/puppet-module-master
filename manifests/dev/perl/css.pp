#
# master::dev::perl::css
#
# Installs packages related to Perl CSS parsing
#
# Included from master::dev::perl::web
#

class master::dev::perl::css {
    include master::dev::perl::base

    case $::operatingsystem {
        'centos','redhat': {
            package { 'perl-CSS-Minifier': }
            package { 'perl-CSS-Squish': }
            package { 'perl-CSS-Tiny': }
        }
        'debian': {
            package { 'libcss-minifier-xs-perl': }
            package { 'libcss-perl': }
            package { 'libcss-squish-perl': }
            package { 'libcss-tiny-perl': }
        }
        default: { }
    }
}
