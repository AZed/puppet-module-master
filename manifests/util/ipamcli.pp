class master::util::ipamcli {
  package { "default-jre": ensure => latest }

  # Create the directory structure
  file { "/var/lib/ipam":
    ensure => directory, mode => '0755',
  }
  file { "/var/lib/ipam/classes":
    ensure => directory, mode => '0755',
    require => File["/var/lib/ipam"]
  }
  file { "/var/lib/ipam/log":
    ensure => directory, mode => '0755',
    require => File["/var/lib/ipam"]
  }
  file { "/var/lib/ipam/templates":
    ensure => directory, mode => '0755',
    require => File["/var/lib/ipam"]
  }

  # Copy in the configuration file
  templatelayer { "/var/lib/ipam/cli.properties":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
  }

  # Copy in the files
  file { "/var/lib/ipam/classes/spring.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/spring.jar",
  }
  file { "/var/lib/ipam/classes/jaxrpc.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/jaxrpc.jar",
  }
  file { "/var/lib/ipam/classes/log4j-1.2.11.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/log4j-1.2.11.jar",
  }
  file { "/var/lib/ipam/classes/incontrol_cli.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/incontrol_cli.jar",
  }
  file { "/var/lib/ipam/classes/wsdl4j.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/wsdl4j.jar",
  }
  file { "/var/lib/ipam/classes/commons-logging.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/commons-logging.jar",
  }
  file { "/var/lib/ipam/classes/saaj.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/saaj.jar",
  }
  file { "/var/lib/ipam/classes/commons-discovery.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/commons-discovery.jar",
  }
  file { "/var/lib/ipam/classes/axis.jar":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/classes/axis.jar",
  }
  file { "/var/lib/ipam/clirun.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/clirun.sh",
  }
  file { "/var/lib/ipam/DeleteAggregateBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DeleteAggregateBlock.sh",
  }
  file { "/var/lib/ipam/DeleteBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DeleteBlock.sh",
  }
  file { "/var/lib/ipam/DeleteContainer.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DeleteContainer.sh",
  }
  file { "/var/lib/ipam/DeleteDevice.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DeleteDevice.sh",
  }
  file { "/var/lib/ipam/DeleteTask.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DeleteTask.sh",
  }
  file { "/var/lib/ipam/DeleteZoneResourceRecord.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DeleteZoneResourceRecord.sh",
  }
  file { "/var/lib/ipam/DhcpConfigurationTask.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DhcpConfigurationTask.sh",
  }
  file { "/var/lib/ipam/DhcpRelease.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DhcpRelease.sh",
  }
  file { "/var/lib/ipam/DHCPUtilization.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DHCPUtilization.sh",
  }
  file { "/var/lib/ipam/DiscoverNetElement.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DiscoverNetElement.sh",
  }
  file { "/var/lib/ipam/DnsConfigurationTask.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/DnsConfigurationTask.sh",
  }
  file { "/var/lib/ipam/dns_import_log4j.properties":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/dns_import_log4j.properties",
  }
  file { "/var/lib/ipam/ExportChildBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ExportChildBlock.sh",
  }
  file { "/var/lib/ipam/ExportContainer.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ExportContainer.sh",
  }
  file { "/var/lib/ipam/ExportDevice.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ExportDevice.sh",
  }
  file { "/var/lib/ipam/ExportNetElement.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ExportNetElement.sh",
  }
  file { "/var/lib/ipam/ExportNetService.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ExportNetService.sh",
  }
  file { "/var/lib/ipam/ExportRootBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ExportRootBlock.sh",
  }
  file { "/var/lib/ipam/GlobalRollup.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/GlobalRollup.sh",
  }
  file { "/var/lib/ipam/GlobalSync.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/GlobalSync.sh",
  }
  file { "/var/lib/ipam/ImportAddrpool.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportAddrpool.sh",
  }
  file { "/var/lib/ipam/ImportAggregateBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportAggregateBlock.sh",
  }
  file { "/var/lib/ipam/ImportChildBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportChildBlock.sh",
  }
  file { "/var/lib/ipam/ImportContainer.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportContainer.sh",
  }
  file { "/var/lib/ipam/ImportDeviceResourceRecord.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportDeviceResourceRecord.sh",
  }
  file { "/var/lib/ipam/ImportDevice.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportDevice.sh",
  }
  file { "/var/lib/ipam/ImportDhcpServer.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportDhcpServer.sh",
  }
  file { "/var/lib/ipam/ImportDomainResourceRecord.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportDomainResourceRecord.sh",
  }
  file { "/var/lib/ipam/ImportNetElement.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportNetElement.sh",
  }
  file { "/var/lib/ipam/ImportNetService.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportNetService.sh",
  }
  file { "/var/lib/ipam/ImportNetServiceWithTemplate.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportNetServiceWithTemplate.sh",
  }
  file { "/var/lib/ipam/ImportRootBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportRootBlock.sh",
  }
  file { "/var/lib/ipam/ImportZoneResourceRecord.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportZoneResourceRecord.sh",
  }
  file { "/var/lib/ipam/ImportZone.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ImportZone.sh",
  }
  file { "/var/lib/ipam/inc_agent.keystore":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/inc_agent.keystore",
  }
  file { "/var/lib/ipam/ipcontrol-cli-unix.bin":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ipcontrol-cli-unix.bin",
  }
  file { "/var/lib/ipam/ipcontrol-cli-unix.tar.gz":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ipcontrol-cli-unix.tar.gz",
  }
  file { "/var/lib/ipam/JoinBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/JoinBlock.sh",
  }
  file { "/var/lib/ipam/log/ns_webservice.log":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/log/ns_webservice.log",
  }
  file { "/var/lib/ipam/log/readme.txt":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/log/readme.txt",
  }
  file { "/var/lib/ipam/log/ns_apache_webservice.log":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/log/ns_apache_webservice.log",
  }
  file { "/var/lib/ipam/log4j.dtd":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/log4j.dtd",
  }
  file { "/var/lib/ipam/log4j.xml":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/log4j.xml",
  }
  file { "/var/lib/ipam/ModifyAddrpool.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ModifyAddrpool.sh",
  }
  file { "/var/lib/ipam/ModifyBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ModifyBlock.sh",
  }
  file { "/var/lib/ipam/ModifyContainer.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ModifyContainer.sh",
  }
  file { "/var/lib/ipam/ModifyDeviceResourceRecord.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ModifyDeviceResourceRecord.sh",
  }
  file { "/var/lib/ipam/ModifyDevice.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ModifyDevice.sh",
  }
  file { "/var/lib/ipam/ModifyDhcpServer.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ModifyDhcpServer.sh",
  }
  file { "/var/lib/ipam/ModifyDomainResourceRecord.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/ModifyDomainResourceRecord.sh",
  }
  file { "/var/lib/ipam/snapshrc.bat":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/snapshrc.bat",
  }
  file { "/var/lib/ipam/SplitBlock.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/SplitBlock.sh",
  }
  file { "/var/lib/ipam/TaskStatus.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/TaskStatus.sh",
  }
  file { "/var/lib/ipam/templates/ImportAddrpool.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportAddrpool.xls",
  }
  file { "/var/lib/ipam/templates/DHCPRelease.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DHCPRelease.csv",
  }
  file { "/var/lib/ipam/templates/DeleteDevice.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteDevice.csv",
  }
  file { "/var/lib/ipam/templates/ImportAggregateBlock.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportAggregateBlock.xls",
  }
  file { "/var/lib/ipam/templates/ImportDomainResourceRecord.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDomainResourceRecord.xls",
  }
  file { "/var/lib/ipam/templates/DeleteContainer.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteContainer.csv",
  }
  file { "/var/lib/ipam/templates/DeleteAggregateBlock.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteAggregateBlock.csv",
  }
  file { "/var/lib/ipam/templates/ImportContainer.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportContainer.xls",
  }
  file { "/var/lib/ipam/templates/ImportDevice.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDevice.csv",
  }
  file { "/var/lib/ipam/templates/DHCPRelease.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DHCPRelease.xls",
  }
  file { "/var/lib/ipam/templates/ImportDeviceResourceRecord.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDeviceResourceRecord.csv",
  }
  file { "/var/lib/ipam/templates/ImportChildBlock.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportChildBlock.xls",
  }
  file { "/var/lib/ipam/templates/DeleteAggregateBlock.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteAggregateBlock.xls",
  }
  file { "/var/lib/ipam/templates/ImportZoneResourceRecord.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportZoneResourceRecord.csv",
  }
  file { "/var/lib/ipam/templates/ImportZone.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportZone.csv",
  }
  file { "/var/lib/ipam/templates/DeleteContainer.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteContainer.xls",
  }
  file { "/var/lib/ipam/templates/ImportContainer.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportContainer.csv",
  }
  file { "/var/lib/ipam/templates/ImportAddrpool.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportAddrpool.csv",
  }
  file { "/var/lib/ipam/templates/ImportDHCPServer.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDHCPServer.xls",
  }
  file { "/var/lib/ipam/templates/ImportDevice.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDevice.xls",
  }
  file { "/var/lib/ipam/templates/ImportNetServiceWithTemplate.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportNetServiceWithTemplate.csv",
  }
  file { "/var/lib/ipam/templates/ImportDeviceResourceRecord.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDeviceResourceRecord.xls",
  }
  file { "/var/lib/ipam/templates/ImportChildBlock.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportChildBlock.csv",
  }
  file { "/var/lib/ipam/templates/ImportNetService.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportNetService.csv",
  }
  file { "/var/lib/ipam/templates/ImportNetElement.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportNetElement.xls",
  }
  file { "/var/lib/ipam/templates/ImportNetElement.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportNetElement.csv",
  }
  file { "/var/lib/ipam/templates/DeleteZoneResourceRecord.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteZoneResourceRecord.xls",
  }
  file { "/var/lib/ipam/templates/DeleteBlock.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteBlock.xls",
  }
  file { "/var/lib/ipam/templates/ImportDomainResourceRecord.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDomainResourceRecord.csv",
  }
  file { "/var/lib/ipam/templates/DeleteDevice.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteDevice.xls",
  }
  file { "/var/lib/ipam/templates/ImportRootBlock.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportRootBlock.xls",
  }
  file { "/var/lib/ipam/templates/ImportZoneResourceRecord.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportZoneResourceRecord.xls",
  }
  file { "/var/lib/ipam/templates/DeleteBlock.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteBlock.csv",
  }
  file { "/var/lib/ipam/templates/ImportDHCPServer.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportDHCPServer.csv",
  }
  file { "/var/lib/ipam/templates/ImportAggregateBlock.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportAggregateBlock.csv",
  }
  file { "/var/lib/ipam/templates/DeleteZoneResourceRecord.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/DeleteZoneResourceRecord.csv",
  }
  file { "/var/lib/ipam/templates/ImportNetServiceWithTemplate.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportNetServiceWithTemplate.xls",
  }
  file { "/var/lib/ipam/templates/ImportZone.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportZone.xls",
  }
  file { "/var/lib/ipam/templates/ImportNetService.xls":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportNetService.xls",
  }
  file { "/var/lib/ipam/templates/ImportRootBlock.csv":
    mode    => '0644',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/templates/ImportRootBlock.csv",
  }
  file { "/var/lib/ipam/UseNextReservedIPAddress.sh":
    mode    => '0755',
    require => [ File["/var/lib/ipam"],
                 File["/var/lib/ipam/classes"],
                 File["/var/lib/ipam/templates"],
                 File["/var/lib/ipam/log"] ],
    source  => "puppet:///modules/master/var/lib/ipam/UseNextReservedIPAddress.sh",
  }
}
