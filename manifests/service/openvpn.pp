#
# class master::service::openvpn
# ==============================
#
# Set up OpenVPN
#
# See also: master::openvpn_config
#
# This class does not attempt to do SSL key management for you.  You
# must take care of certificate handling elsewhere.
#
# TODO: tie-in with sysctl and iptables, requires rewrites of
# master::common::sysctl and master::util::iptables
#
class master::service::openvpn (
    # Parameters
    # ----------
    #
    # ### autostart
    # Start only these VPNs automatically via init script.
    # Allowed values are "all", "none" or space separated list of
    # names of the VPNs. If empty, "all" is assumed.
    $autostart = undef,

    # ### vpns
    # Hash of master::openvpn_config resources, where the first key is
    # the name of the config file without ".conf" (which will be
    # automatically appended)
    #
    # Example:
    #
    #     master::service::openvpn::vpns:
    #       openvpn:
    #         ca: '/etc/ssl/certs/mycacert.pem'
    #         cert: '/etc/ssl/certs/myopenvpn.pem'
    #         key: '/etc/ssl/private/myopenvpn.pem'
    #         pam: 'sshd login USERNAME password PASSWORD'
    #
    $vpns = undef
){
    # Code
    # ----

    package { 'openvpn': }

    # Generate 1024-bit DH parameters if they don't already exist
    exec { 'openvpn-generate-dh1024':
        command => 'openssl dhparam -out dh1024.pem 1024',
        cwd     => '/etc/openvpn',
        path    => '/usr/bin:/bin',
        creates => '/etc/openvpn/dh1024.pem',
    }

    case $::osfamily {
        'Debian': {
            templatelayer { '/etc/default/openvpn': }
        }
    }

    if $vpns and is_hash($vpns) {
        create_resources(master::openvpn_config,$vpns)
    }
}
