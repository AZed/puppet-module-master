class master::service::portmap (
  $portmap_allow = true
)
{
  Class['master::common::network'] -> Class[$name]
  
  package { "portmap": ensure => latest, }
  templatelayer { "/etc/default/portmap": }
}
