#
# class master::dev::crypt
# ========================
#
# Miscellaneous cryptographic development packages
#

class master::dev::crypt {
    # Code Comments
    # -------------

    case $::operatingsystem {
        'Debian': {
            package { 'libcrack2-dev': }
            package { 'libgcrypt11-dev': }
            package { 'libgpg-error-dev': }
            package { 'libssl-dev': }

            if versioncmp($::operatingsystemrelease, '9.0') < 0 {
                package { 'libgpgme11-dev': }
            }
            else {
                package { 'libgpgme-dev': }
            }

            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                package { 'libgnutls-dev': ensure => installed, }
                package { 'libtasn1-3-dev': }
            }
            else {
                package { 'libgnutls28-dev': ensure => installed, }
                package { 'libtasn1-6-dev': }
            }
        }
        'RedHat','CentOS': {
            package { 'cracklib-devel': }
            package { 'gpgme-devel': }
            package { 'libgcrypt-devel': }
            package { 'libgpg-error-devel': }
            package { 'libtasn1-devel': }
            package { 'openssl-devel': }
            # Upgrades to gnutls can be dangerous -- manage by hand
            package { 'gnutls-devel': ensure => installed, }
        }
        default: { }
    }
}
