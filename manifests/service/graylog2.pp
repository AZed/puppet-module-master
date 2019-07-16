#
# master::service::graylog2
#

class master::service::graylog2 (
  # String for verifiying signed cookies, should be long, random, and unique
  $secret_tok = undef,
  $mongodb_user = 'graylog2',
  $mongodb_pass = undef,
  $num_ES_indexes = undef,
  $ES_docs_per_index = undef
)
{
  #Depend on Elasticsearch
  Class['master::service::elasticsearch'] -> Class[$name]
  #Depend on MongoDB
  Class['master::service::mongodb'] -> Class[$name]

  package { 'ruby1.9.1': ensure => installed }
  package { 'ruby1.9.1-dev': ensure => installed }
  package { 'bundler': ensure => installed }

  templatelayer { "/etc/apache2/conf.d-ssl/graylog2": }
  templatelayer { "/etc/init.d/graylog2": }
  templatelayer { "/etc/graylog2.conf": }
  templatelayer { "/etc/graylog2-elasticsearch.yml": }

  exec { 'ruby1.9.1-default':
    command => '/usr/sbin/update-alternatives --set ruby /usr/bin/ruby1.9.1',
    require => Package['ruby1.9.1']
  }
}
