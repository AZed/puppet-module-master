#
#master::service::elasticsearch
#

class master::service::elasticsearch()
{
package{ 'elasticsearch': ensure => installed }

templatelayer { "/etc/elasticsearch/elasticsearch.yml": }
templatelayer { "/etc/elasticsearch/logging.yml": }

groupmembers { "elasticsearch": members => "elasticsearch" }

}
