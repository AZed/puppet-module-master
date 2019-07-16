#
# master::service::postgrey
#
# Set up a greylisting service usable by Postfix or Exim
#

class master::service::postgrey (
    # Port to listen on
    $port = '10023',

    # How long to greylist in seconds (default is 300)
    $delay = undef,

    # Delete old entries after N days (default is 35)
    $maxage = undef,

    # Customized rejection message
    $text = undef,
) {

    if $delay {
        $delaytext = " --delay=${delay}"
    }
    else {
        $delaytext = ''
    }
    if $maxage {
        $maxagetext = " --max-age=${maxage}"
    }
    else {
        $maxagetext = ''
    }

    case $::osfamily {
        'Debian': {
            package { 'postgrey': }
            templatelayer { '/etc/default/postgrey': }
        }
        default: {
            fail('Postgrey is not supported on $::operatingsystem')
        }
    }
}
