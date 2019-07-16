#
# master::util::cluster
#
# Cluster management tools
#

class master::util::cluster (
  # Template fragments to put at the top of /etc/genders
  $genders_templates = [ ],

  # Array of lines to put at the bottom of /etc/genders
  $genders = [ ]
)
{
  Package { ensure => present }

  package { 'pdsh': }
  templatelayer { '/etc/genders': }

  case $::operatingsystem {
    'centos', 'redhat': {
      package { 'clusterssh': }
      package { 'genders': }
      package { 'genders-compat': }
      package { 'pdsh-mod-genders': }
    }
    'debian': {
      package { 'clusterssh': }
      package { 'genders': }
    }
    'suse','sles': {
      package { 'genders': }
      package { 'genders-compat': }
    }
    default: { }
  }
}
