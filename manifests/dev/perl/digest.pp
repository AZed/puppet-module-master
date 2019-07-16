#
# class master::dev::perl::digest
# ===============================
#
# Install Perl packages related to cryptographic digests
#

class master::dev::perl::digest {
    include master::dev::perl::base

    case $::osfamily {
        'Debian': {
            package { 'libdigest-crc-perl': }
            package { 'libdigest-hmac-perl': }
            package { 'libdigest-md2-perl': }
            package { 'libdigest-md4-perl': }
            package { 'libdigest-md5-file-perl': }
            package { 'libdigest-sha-perl': }
        }
        'RedHat': {
            package { 'perl-Digest-CRC': }
            package { 'perl-Digest-HMAC': }
            package { 'perl-Digest-MD4': }
            package { 'perl-Digest-MD5-File': }
            package { 'perl-Digest-SHA1': }
        }
        'Suse': {
            package { 'perl-Digest-HMAC': }
            package { 'perl-Digest-MD4': }
            package { 'perl-Digest-SHA1': }
        }
        default: { }
    }
}
