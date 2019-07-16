#
# class master::dev::perl::crypt
# ==============================
#
# Install Perl packages related to encryption
#

class master::dev::perl::crypt {
    include master::dev::perl::base

    case $::operatingsystem {
        'Debian','Ubuntu': {
            $packages = [
                'libcrypt-blowfish-perl',
                'libcrypt-cbc-perl',
                'libcrypt-des-perl',
                'libcrypt-dh-perl',
                'libcrypt-ecb-perl',
                'libcrypt-eksblowfish-perl',
                'libcrypt-gpg-perl',
                'libcrypt-mysql-perl',
                'libcrypt-openssl-bignum-perl',
                'libcrypt-openssl-dsa-perl',
                'libcrypt-openssl-random-perl',
                'libcrypt-openssl-rsa-perl',
                'libcrypt-openssl-x509-perl',
                'libcrypt-passwdmd5-perl',
                'libcrypt-rijndael-perl',
                'libcrypt-simple-perl',
                'libcrypt-smbhash-perl',
                'libcrypt-ssleay-perl',
                'libcrypt-unixcrypt-perl',
                'libcrypt-unixcrypt-xs-perl',
            ]

            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'libcrypt-smime-perl': }
            }
        }
        'centos','redhat': {
            $packages = [
                'perl-Crypt-Blowfish',
                'perl-Crypt-CBC',
                'perl-Crypt-DES',
                'perl-Crypt-DH',
                'perl-Crypt-DSA',
                'perl-Crypt-OpenSSL-Bignum',
                'perl-Crypt-OpenSSL-Random',
                'perl-Crypt-OpenSSL-RSA',
                'perl-Crypt-OpenSSL-X509',
                'perl-Crypt-PasswdMD5',
                'perl-Crypt-Rijndael',
                'perl-Crypt-SmbHash',
                'perl-Crypt-SMIME',
                'perl-Tie-EncryptedHash',
            ]
        }
        'Suse','SLES': {
            $packages = [
                'perl-Crypt-Blowfish',
                'perl-Crypt-CBC',
                'perl-Crypt-DES',
                'perl-Crypt-OpenSSL-RSA',
                'perl-Crypt-SmbHash',
            ]
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
            $packages = []
        }
    }
    ensure_packages($packages)
}
