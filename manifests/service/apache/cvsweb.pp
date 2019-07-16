#
# class master::service::apache::cvsweb
# =====================================
#
# Installs and configures cvsweb, used to view CVS repositories over the web.
#
# SSL is required for access, even if authentication is not enabled.
#

class master::service::apache::cvsweb (
    # Parameters
    # ----------

    # ### apache_require
    # Apache access requirements
    #
    # This can be presented either as a string or as an array.
    # Generated lines will be placed inside a RequireAll block
    # preceded by the keyword 'require'
    #
    # Example:
    #
    #     master::service::apache::cvsweb::apache_require:
    #       - 'valid-user'
    #       - 'ip 1.2.3.4'
    #
    $apache_require = undef,

    # ### descriptions
    # Use CVSROOT/descriptions for describing the directories/modules?
    # Valid values are "0" and "1"
    $descriptions = "1",

    # ### errordocument
    #
    # A hash where the keys are the response codes and the values are URLs
    #
    $errordocument = lookup('master::service::apache::cvsweb::errordocument',Hash,undef),

    # ### ldap
    # Use LDAP for authentication?
    $ldap = false,

    # ### repositories
    # Repository lines for cvsweb.conf -- defaults are commented-out examples
    $repositories = [
        "        'local'   => ['CVS Repositories', '/cvsroot'],",
    ],

    # ### show_author
    # Show author of last change?  Valid values are "0" and "1".
    #
    # Debian sets this to "0" by default for security by obscurity, but
    # since this class defaults to requiring SSL auth to view, we
    # default it to "1"
    $show_author = "1",

    # ### contact_email
    # ### contact_email_name
    # Webmaster e-mail address and name
    $contact_email = "webmaster@${::domain}",
    $contact_email_name = "Webmaster",
)
{
    include master::dev::cvs
    include master::service::apache
    if $ldap {
        include master::client::ldap
        $authldapurl = $master::client::ldap::authurl
    }

    package { 'cvsweb': }

    File { notify => Exec['apache2-reload'] }
    Templatelayer { notify => Exec['apache2-reload'] }

    /* Since we may require authentication this should only be
    ** available via SSL */
    file { "/etc/apache2/conf.d/cvsweb": ensure => absent }
    templatelayer { "/etc/apache2/conf.d-nossl/cvsweb.conf": }
    templatelayer { "/etc/apache2/conf.d-ssl/cvsweb.conf": }

    file { "/etc/cvsweb": ensure => directory,
        owner => 'root', group => 'root', mode => '0755'
    }
    templatelayer { "/etc/cvsweb/cvsweb.conf": }
}
