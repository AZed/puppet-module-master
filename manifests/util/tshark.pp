#
class master::util::tshark (
)
{
    package { 'tshark': ensure => 'latest' }
}
