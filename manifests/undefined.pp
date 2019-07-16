#
# master::undefined
#
# This class fails immediately with a diagnostic if included.
#

class master::undefined
{
    fail("${::fqdn} undefined in environment '${::environment}' on ${::puppetmaster}")
}
