#
# master::dev::perl::cgi
#
# Installs packages related to Perl CGI
#
# Included from master::dev::perl::web
#

class master::dev::perl::cgi {
    include master::dev::perl::base

    case $::operatingsystem {
        'centos','redhat': {
            package { 'perl-CGI': }
            package { 'perl-CGI-Application': }
            package { 'perl-CGI-FormBuilder': }
            package { 'perl-CGI-Session': }
            package { 'perl-FCGI': }
            package { 'perl-FCGI-Client': }
            package { 'perl-FCGI-ProcManager': }
        }
        'debian': {
            package { 'libcgi-application-perl': }
            package { 'libcgi-formbuilder-perl': }
            package { 'libcgi-session-perl': }
            package { 'libcgi-simple-perl': }
            package { 'libcgi-untaint-perl': }
            package { 'libcgi-untaint-date-perl': }
            package { 'libcgi-untaint-email-perl': }
            package { 'libcgi-xml-perl': }
            package { 'libcgi-xmlapplication-perl': }
            package { 'libcgi-xmlform-perl': }
            package { 'libfcgi-perl': }
            package { 'libfcgi-procmanager-perl': }
        }
        default: { }
    }
}
