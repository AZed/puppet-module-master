#
class master::dev::perl::ldap {

    # Set the packages to be installed based on the OS
    $perlldap_packages_latest = $::operatingsystem ? {
        'centos' => [
            'perl-LDAP',
        ],
        'debian' => [
            'libauthen-simple-ldap-perl',
            'libnet-ldap-perl',
        ],
        default => '',
    }

    # Install the packages
    package { $perlldap_packages_latest:
        ensure => latest,
    }

}
