#
# master::dev::net
# ================
#
# Miscellaneous network development/debugging packages
#

class master::dev::net {
    $global_packages = [
        'tcpdump',
        'w3m',
        'w3m-img'
    ]
    ensure_packages($global_packages)

    case $::operatingsystem {
        'CentOS': {
            $os_packages = [
                'libcurl-devel',
                'libsmbclient-devel',
                'mtr',
                'wireshark',
            ]
        }
        'Debian': {
            $os_packages = [
                'libcurl4-gnutls-dev',
                'mtr-tiny',
                'smbclient',
                'tshark',
                'cifs-utils',
            ]
        }
        default: { $os_packages = [ ] }
    }
    ensure_packages($os_packages)
}
