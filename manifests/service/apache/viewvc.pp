#
# class master::service::apache::viewvc
# =====================================
#
# Installs and configures ViewVC, used to view CVS and Subversion
# repositories over the web.
#
# SSL is required for access, even if authentication is not enabled.
#

class master::service::apache::viewvc (
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

    # ### errordocument
    #
    # A hash where the keys are the response codes and the values are URLs
    #
    $errordocument = lookup('master::service::apache::viewvc::errordocument',Hash,undef),

    # ### ldap
    # Use LDAP for authentication?
    $ldap = false,

    # ### repositories
    # Repository lines for cvsweb.conf -- defaults are commented-out examples
    $repositories = [
        "        'local'   => ['CVS Repositories', '/cvsroot'],",
    ],

    # ### contact_email
    # ### contact_email_name
    # Webmaster e-mail address and name
    $contact_email = "webmaster@${::domain}",
    $contact_email_name = "Webmaster",

    # Apache require access line for viewvc
    $viewvc_require = "valid-user"
)
{
    include master::dev::cvs
    include master::service::apache
    if $ldap {
        include master::client::ldap
        $authldapurl = $master::client::ldap::authurl
    }

    package { 'viewvc': }

    File { notify => Exec['apache2-reload'] }
    Templatelayer { notify => Exec['apache2-reload'] }

    /* Since we may require authentication this should only be
    ** available via SSL */
    file { "/etc/apache2/conf.d/viewvc": ensure => absent }
    templatelayer { "/etc/apache2/conf.d-nossl/viewvc.conf": }
    templatelayer { "/etc/apache2/conf.d-ssl/viewvc.conf": }
    templatelayer { "/etc/viewvc/viewvc.conf": }

    file { "/etc/viewvc": ensure => directory,
        owner => 'root', group => 'root', mode => '0755'
    }
}
