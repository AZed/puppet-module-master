#
# master::util::securityscan
#
# Security scanners used for auditing systems
#

class master::util::securityscan {
  package { 'arp-scan': }
  package { 'nmap': }

  case $::operatingsystem {
    'debian': {
      package { 'arping': }
      package { 'debsecan': }

      templatelayer { '/etc/default/debsecan': }
      templatelayer { '/var/lib/debsecan/whitelist': }
    }
    'centos','redhat': {
    }
    default: { }
  }
}
