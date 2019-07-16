#
# class master::dev::perl::template
#
# Perl packages related to text/html templates
#

class master::dev::perl::template {
    case $::operatingsystem {
        'debian': {
            package { 'libhtml-template-perl': }
            package { 'libhtml-template-pro-perl': }
            package { 'libtemplate-perl': }
            package { 'libtemplate-perl-doc': }
            package { 'libtemplate-plugin-gd-perl': }
            package { 'libtemplate-provider-encoding-perl': }
            package { 'libtemplate-timer-perl': }
        }
        'centos','redhat': {
            package { 'perl-HTML-Template': }
            package { 'perl-HTML-Template-Pro': }
            package { 'perl-Template-GD': }
            package { 'perl-Template-Toolkit': }
        }
        default: { }
    }
}
