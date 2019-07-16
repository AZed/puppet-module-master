#
# class master::dev::perl::oo
#
# Packages related to enhancing object oriented coding in Perl
#

class master::dev::perl::oo {
    case $::operatingsystem {
        'debian','ubuntu': {
            package { 'libmoose-perl': }
            package { 'libmoosex-getopt-perl': }
            package { 'libmoosex-params-validate-perl': }
            package { 'libmoosex-role-parameterized-perl': }
            package { 'libmoosex-strictconstructor-perl': }
            package { 'libmoosex-types-perl': }
            package { 'libmoosex-types-common-perl': }
            package { 'libtemplate-plugin-class-perl': }
        }
        'centos','redhat': {
            package { 'perl-Moose': }
            package { 'perl-MooseX-Getopt': }
            package { 'perl-MooseX-Role-Parameterized': }
            package { 'perl-MooseX-Types': }
        }
        default: { }
    }
}
