#
# define master::openvpn_config
# =============================
#
# Create an openvpn configuration file
#
# Intended to be invoked from master::service::openvpn, though it can
# be used manually.
#
# By default this will attempt to set up a TLS server on 172.16.10.1
# in subnet mode
#
# WARNING: defaults subject to change, as while this is an ideal
# end-point, this will never result in an out-of-the-box working
# configuration
#

define master::openvpn_config (
    # Parameters
    # ----------
    #
    # ### ca
    # ### cert
    # ### key
    # Server TLS certificates.  These are undefined by default and
    # MUST be created separately
    $ca = undef,
    $cert = undef,
    $key = undef,

    # ### cipher
    # Encrypt data channel packets with this cipher algorithm
    #
    # The OpenVPN default is 'BF-CBC', which has suboptimal security
    # properties, so this class defaults to AES-256-GCM
    $cipher = 'AES-256-GCM',

    # ### client_to_client
    # Enable internal client-to-client routing
    $client_to_client = false,

    # ### dev
    # TUN/TAP virtual network device
    #
    # This must be the same on both sides of the connection
    #
    # NOTE: TAP devices are not supported on Android
    $dev = 'tun',

    # ### dh
    # Location of Diffie-Helman parameters in pem format
    $dh = '/etc/openvpn/dh1024.pem',

    # ### dir
    # Directory in which to place the configuration file
    $dir = '/etc/openvpn',

    # ### dns
    # DNS server to push to the client
    #
    # By default we push OpenDNS
    $dns = '208.67.222.222',

    # ### keepalive
    # Helper directive for ping and ping-restart.
    $keepalive = '10 60',

    # ### localaddress
    # Local address passed to the ifconfig parameter
    $localaddress = '172.16.10.1',

    # ### netmask
    # netmask used in ifconfig parameter in subnet mode and in ifconfig-pool
    $netmask = '255.255.255.0',

    # ### pam
    # Activate the PAM plugin for authentication
    #
    # The value of this is the plugin configuration string
    #
    # Example for using the same access as sshd:
    #
    #     pam: 'sshd login USERNAME password PASSWORD'
    #
    $pam = undef,

    # ### poolstart
    # ### poolend
    # Starting and ending IPs for the DHCP pool range
    #
    # Only has meaning in subnet mode
    $poolstart = '172.16.10.2',
    $poolend = '172.16.10.254',

    # ### port
    # ### proto
    # Port and protocol (tcp/udp)
    $port = '1194',
    $proto = 'udp',

    # ### status
    # Where to put the status log
    $status = '/var/log/openvpn-status.log',

    # ### tls
    # In server mode, activate tls-server?
    $tls = true,

    # ### topology
    # Virtual addressing topology if $dev = 'tun'
    #
    # The OpenVPN default is 'net30', but we default to 'subnet'
    $topology = 'subnet',

    # ### verb
    # Output verbosity
    $verb = '1',

    # ### vpn_mode
    # 'p2p' or 'server'
    $vpn_mode = 'server',
){
    templatelayer { "${dir}/${title}.conf": }
}
