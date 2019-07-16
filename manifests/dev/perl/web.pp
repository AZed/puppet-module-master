#
# master::dev::perl::web
#
# Installs packages related to Perl web parsing and development
#

class master::dev::perl::web {
    include master::dev::perl::base
    include master::dev::perl::cgi
    include master::dev::perl::css
    include master::dev::perl::html

    case $::operatingsystem {
        'centos','redhat': {
            package { 'perl-Test-WWW-Selenium': }
            package { 'perl-WWW-Curl': }
            package { 'perl-WWW-Mechanize': }
            package { 'perl-WWW-Mechanize-GZip': }
            package { 'perl-WWW-Shorten': }
        }
        'debian': {
            package { 'libhttp-request-ascgi-perl': }
            package { 'libtest-html-content-perl': }
            package { 'libtest-www-declare-perl': }
            package { 'libtest-www-mechanize-catalyst-perl': }
            package { 'libtest-www-mechanize-cgiapp-perl': }
            package { 'libtest-www-mechanize-perl': }
            package { 'libtest-www-selenium-perl': }
            package { 'libwhisker2-perl': }
            package { 'libwww-curl-perl': }
            package { 'libwww-indexparser-perl': }
            package { 'libwww-mechanize-formfiller-perl': }
            package { 'libwww-mechanize-perl': }
            package { 'libwww-mechanize-shell-perl': }
            package { 'libwww-mediawiki-client-perl': }
            package { 'libwww-perl': }
            package { 'libwww-search-perl': }
            package { 'libwww-shorten-perl': }
        }
        default: { }
    }
}
