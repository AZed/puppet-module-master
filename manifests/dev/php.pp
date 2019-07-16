#
# class master::dev::php
# ======================
#
# Installs a complete PHP development environment
#

class master::dev::php {
    include master::dev::php::net

    package { 'php-pear': }
    package { 'php-fpdf': }

    case $::operatingsystem {
        'Debian': {
            package { 'php-cas': }
            package { 'php-codesniffer': }
            package { 'php-db': }
            package { 'php-html-safe': }
            package { 'php-log': }
            package { 'php-mail': }
            package { 'php-xml-htmlsax3': }
            package { 'phpunit': }

            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'php-monolog': }
                package { 'php-nette': }
                package { 'php-patchwork-utf8': }
            }

            # All of the php5* packages were renamed to php- in Debian
            # 9, and some PHP packages were removed.
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                package { 'composer': }
                package { 'php-apcu': }
                package { 'php-cgi': }
                package { 'php-dev': }
                package { 'php-gd': }
                package { 'php-gmp': }
                package { 'php-imagick': }
                package { 'php-imap': }
                package { 'php-ldap': }
                package { 'php-mbstring': }
                package { 'php-memcache': }
                package { 'php-mysql': }
                package { 'php-pgsql': }
                package { 'php-xmlrpc': }
            }
            else {
                package { 'php-apc': }
                package { 'php-auth': }
                package { 'php-file': }
                package { 'php-html-common': }
                package { 'php-mail-mimedecode': }
                package { 'php-pager': }
                package { 'php-xml-parser': }
                package { 'php-xml-rss': }
                package { 'php5-cgi': }
                package { 'php5-dev': }
                package { 'php5-gd': }
                package { 'php5-gmp': }
                package { 'php5-imagick': }
                package { 'php5-imap': }
                package { 'php5-ldap': }
                package { 'php5-memcache': }
                package { 'php5-mysql': }
                package { 'php5-pgsql': }
                package { 'php5-xmlrpc': }

                templatelayer{ '/etc/php5/cli/php.ini': }
            }
        }
        'centos','redhat': {
            package { 'php-imap': }
            package { 'php-ldap': }
            package { 'php-Monolog': }
            package { 'php-mysql': }
            package { 'php-pgsql': }
            package { 'php-pear-Auth': }
            package { 'php-pear-DB': }
            package { 'php-pear-File': }
            package { 'php-pear-HTML-Common': }
            package { 'php-pear-Log': }
            package { 'php-pear-Mail': }
            package { 'php-pear-Mail-mimeDecode': }
            package { 'php-pear-Pager': }
            package { 'php-pear-PHP-CodeSniffer': }
            package { 'php-pear-XML-Parser': }
            package { 'php-pear-XML-RSS': }
        }
        default: {
            notify { "stub-${title}":
                message  => "WARNING: ${title} has not been updated for use on ${::operatingsystem}!",
                loglevel => warning,
            }
        }
    }
}
