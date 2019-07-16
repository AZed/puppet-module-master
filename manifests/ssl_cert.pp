#
# define master::ssl_cert
# =======================
#
# This is a shortcut helper define to create a virtual file
# resource for a file in /etc/ssl/certs or /etc/ssl/private tagged as
# 'sslcert' that can be used in any class in any module, but will be
# activated by `master::common::ssl`.  This is to allow other classes to
# require `master::common::ssl` to be complete and then also be assured
# that all SSL keys added by any class have been placed on the system.
#
# Using this define on its own does not cause anything to happen on a
# system.  It is entirely virtual.  It still does require that the
# specified file exist underneath files/etc/ssl/certs or
# files/etc/ssl/private in the calling module.
#
# If the certificate being installed is a private key, set $key =>
# true.  This will automatically change its default location to
# /etc/ssl/private and the default group to 'ssl-cert' under Debian.
#
# If the certificate being installed should be trusted by the system
# as a CA certificate, set `$trustedca => true`.
#
# If you are using `master::common::ssl`, then these directories will be
# valid via symlink on CentOS and SLES, even though they are not the
# default.  If you want to use a separate location, you can specify it
# via the $dir parameter.
#

define master::ssl_cert (
    $owner       = 'root',
    $group       = undef,
    $mode        = false,
    $module      = $caller_module_name,
    $key         = false,
    $dir         = false,
    $trustedca   = false
)
{
    include master::common::ssl

    if $dir {
        $ssldir = $dir
    }
    else {
        $ssldir = $key ? {
            true  => '/etc/ssl/private',
            false => '/etc/ssl/certs',
        }
    }

    if $group {
        $realgroup = $group
    }
    else {
        $realgroup = $key ? {
            true    => $::osfamily ? {
                ['Debian','Ubuntu'] => 'ssl-cert',
                default  => 'root',
            },
            default => 'root',
        }
    }

    if $mode {
        $realmode = $mode
    }
    else {
        $realmode = $key ? {
            true  => '0440',
            false => '0444',
        }
    }

    case $::osfamily {
        'RedHat': {
            $java_keystore_dir = '/etc/pki/java'
        }
        'Debian','Ubuntu': {
            $java_keystore_dir = '/etc/ssl/certs/java'
        }
        default: {
        }
    }

    if $java_keystore_dir {
        @file { "${ssldir}/${title}":
            ensure  => present,
            owner   => $owner,
            group   => $realgroup,
            mode    => $realmode,
            require => File[$ssldir],
            source  => "puppet:///modules/${module}${ssldir}/${title}",
            notify  => [ Exec["java-keystore-del-${title}"],
                         Exec["java-keystore-add-${title}"],
                         ],
            tag     => 'sslcert',
        }
        @exec { "java-keystore-del-${title}":
            cwd         => $java_keystore_dir,
            path        => '/usr/bin',
            command     => "keytool -keystore ./cacerts -storepass ${master::common::ssl::java_keystore_pass} -delete -alias ${title}",
            onlyif      => [ 'test -x /usr/bin/keytool',
                             "keytool -keystore ./cacerts -storepass ${master::common::ssl::java_keystore_pass} -list -alias ${title}",
                             ],
            refreshonly => true,
            tag         => 'sslcert',
        }

        @exec { "java-keystore-add-${title}":
            cwd         => $java_keystore_dir,
            path        => '/usr/bin',
            command     => "keytool -keystore ./cacerts -storepass ${master::common::ssl::java_keystore_pass} -importcert -file ${ssldir}/${title} -alias ${title} -trustcacerts -noprompt",
            onlyif      => [ 'test -x /usr/bin/keytool',
                             "keytool -keystore ./cacerts -storepass ${master::common::ssl::java_keystore_pass} -list",
                             ],
            require     => Exec["java-keystore-del-${title}"],
            refreshonly => true,
            tag         => 'sslcert',
        }
    }
    else {
        @file { "${ssldir}/${title}":
            ensure  => present,
            owner   => $owner,
            group   => $realgroup,
            mode    => $realmode,
            require => File[$ssldir],
            source  => "puppet:///modules/${module}${ssldir}/${title}",
            tag     => 'sslcert',
        }
    }

    if $trustedca {
        # These certificates MUST end in .crt to work properly
        $trusted_cert_base = regsubst($title,"(.*?).crt",'\1')
        $trusted_cert = "${trusted_cert_base}.crt"

        case $::osfamily {
            'Debian','Ubuntu': {
                @file { "/usr/share/ca-certificates/${trusted_cert}":
                    ensure => present,
                    owner  => root,
                    group  => root,
                    mode   => '0444',
                    source => "puppet:///modules/${module}${ssldir}/${title}",
                    notify => Exec['update-ca-certificates'],
                    tag    => 'sslcert'
                }
                file_line { "ca-certificates-${trusted_cert}":
                    ensure => present,
                    path   => '/etc/ca-certificates.conf',
                    line   => $trusted_cert,
                }
            }
            'RedHat': {
                @file { "/etc/pki/ca-trust/source/anchors/${trusted_cert}":
                    ensure => present,
                    owner  => root,
                    group  => root,
                    mode   => '0444',
                    source => "puppet:///modules/${module}${ssldir}/${title}",
                    notify => Exec['update-ca-trust'],
                    tag    => 'sslcert'
                }
            }
            default: { }
        }
    }
}
