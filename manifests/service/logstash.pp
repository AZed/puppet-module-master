#
#master::service::logstash
#

class master::service::logstash()
{
	#file { '/opt/local/logging/logstash.jar':
	#owner => root, group => root, mode => '0400',
	#source => "puppet:///modules/master/opt/local/logging/logstash.jar",
	#  }

templatelayer { "/etc/init.d/logstash": }
}
