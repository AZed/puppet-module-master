#
class master::dev::perl::io {
    include master::dev::perl::base

    # Set the packages to be installed based on the OS
    case $::operatingsystem {
        'centos': {
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'perl-IO-Compress': }
            }
            else {
                package { 'perl-IO-Compress-Base': }
            }

            package { 'perl-IO-All': }
            package { 'perl-IO-Tty': }
            package { 'perl-IO-Socket-SSL': }
            package { 'perl-IO-String': }
            package { 'perl-IO-stringy': }
        }
        'debian': {
            package { 'libio-all-perl': }
            package { 'libio-pty-perl': }
            package { 'libio-socket-ssl-perl': }
            package { 'libio-string-perl': }
            package { 'libio-stringy-perl': }
            package { 'libio-stty-perl': }
            if versioncmp($::operatingsystemrelease, '9.0') < 0 {
                package { 'libio-compress-perl': }
            }
            # These packages are related to libio-compress-perl
            package { 'libcompress-bzip2-perl': }
            package { 'libcompress-raw-bzip2-perl': }
            package { 'libcompress-raw-zlib-perl': }
            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'libcompress-raw-lzma-perl': }
            }
        }
        default: { }
    }
}
