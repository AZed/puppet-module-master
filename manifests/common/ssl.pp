#
# class master::common::ssl
# =========================
#
# Packages and files related to SSL and TLS authentication/security
#
# This class also sets parameters used as defaults by other classes.
#

class master::common::ssl (
    # Parameters
    # ----------
    #
    # ### java_keystore_pass
    # This is the default java keystore pass, which despite the value
    # is very rarely changed.
    $java_keystore_pass = 'changeit',

    # ### cert_file
    # ### key_file
    # These are default system SSL cert files that are not actually
    # used by this class, but set the default for other classes.
    $cert_file = $::osfamily ? {
        'Debian' => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
        'RedHat' => $::operatingsystemmajrelease ? {
            '7'     => '/etc/pki/tls/certs/localhost.crt',
            default => undef,
        },
        default  => undef,
    },
    $key_file = $::osfamily ? {
        'Debian' => '/etc/ssl/private/ssl-cert-snakeoil.key',
        'RedHat' => $::operatingsystemmajrelease ? {
            '7'     => '/etc/pki/tls/private/localhost.key',
            default => undef,
        },
        default  => undef,
    }
)
{
    # Code
    # ----

    package { 'gnutls': ensure => present,
        name => $::operatingsystem ? {
            'debian' => 'gnutls-bin',
            'ubuntu' => 'gnutls-bin',
            default  => 'gnutls',
        }
    }
    package { 'openssl': ensure => present }

    file { '/etc/ssl': ensure => directory,
        owner => root, group => root, mode => '0755',
    }
    file { '/etc/ssl/private': ensure => directory,
        owner => root,
        group => $::operatingsystem ? {
            'Debian' => 'ssl-cert',
            'Ubuntu' => 'ssl-cert',
            default  => root,
        },
        mode => $::operatingsystem ? {
            'Debian' => '0710',
            'Ubuntu' => '0710',
            default  => '0700',
        }
    }

    case $::operatingsystem {
        'Debian','Ubuntu': {
            package { 'ca-certificates': }

            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                package { 'libgnutls26': ensure => installed }
            }
            elsif versioncmp($::operatingsystemrelease, '9.0') < 0 {
                package { 'libgnutls-deb0-28': ensure => installed }
            }
            else {
                package { 'libgnutls30': ensure => installed }
            }

            # The ssl-cert package is technically part of the Apache family,
            # but it is responsible for creating the 'ssl-cert' group in
            # Debian.
            #
            package { 'ssl-cert': ensure => latest,
                before => File['/etc/ssl/private'],
            }
            file { '/etc/ssl/certs': ensure => directory,
                owner => root, group => root, mode => '0755',
            }
            exec { 'update-ca-certificates':
                command     => 'update-ca-certificates',
                path        => '/usr/sbin:/sbin:/usr/bin:/bin',
                refreshonly => true,
                require     => Package['ca-certificates'],
            }
        }
        'CentOS','RedHat': {
            # The ca-certificates package will refuse to upgrade if
            # /etc/ssl/certs is a directory instead of a symlink, so we must
            # enforce it in advance.  This does not break Puppet rules
            # placing files in /etc/ssl/certs.
            #
            package { 'ca-certificates':
                require => File['/etc/ssl/certs'],
            }
            file { '/etc/pki/tls/certs': ensure => directory, }
            file { '/etc/ssl/certs': ensure => link,
                target => '../pki/tls/certs',
                force  => true,
            }
            # ### Exec['update-ca-trust']
            # Command to update the main CA certificates
            #
            # This can be called by master::ssl_cert
            exec { 'update-ca-trust':
                command     => 'update-ca-trust extract',
                path        => '/usr/bin:/bin',
                refreshonly => true,
                require     => Package['ca-certificates'],
            }
        }
        'SLES': {
            if versioncmp($::operatingsystemrelease, '12.0') < 0 {
                package { 'openssl-certs': }
                file { '/etc/ssl/certs': ensure => directory,
                    owner => root, group => root, mode => '0755',
                }
            }
            else {
                package { 'ca-certificates': }
                file { '/etc/ssl/certs': ensure => link,
                    target => '/var/lib/ca-certificates/pem',
                }
            }
        }
        default: {
            file { '/etc/ssl/certs': ensure => directory,
                owner => root, group => root, mode => '0755',
            }
        }
    }

    # Activate any SSL certificate file/exec resources defined in any
    # other active classes
    File <| tag == 'sslcert' |> -> Exec <| tag == 'sslcert' |>
    File <| tag == 'sslcert' |>
    Exec <| tag == 'sslcert' |>
}
