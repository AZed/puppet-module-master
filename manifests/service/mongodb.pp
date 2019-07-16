#
#master::service::mongodb
#

class master::service::mongodb()
{
    package{ 'mongodb-clients': ensure => installed }
    package{ 'mongodb-server':  ensure => installed }
    templatelayer { "/etc/mongodb.conf": }
    groupmembers  { "mongodb": members => "mongodb" }
}
