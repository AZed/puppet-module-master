#
# class master::service::apache::modmellon
#
# Enables modmellon on the Apache server.
#
# Using this class requires correctly configuring
# master::service::apache in the same node.
class master::service::apache::modmellon (
    # valid values are sandbox, testing, prod
    $launchpad_env = 'sandbox',
)
{

    Templatelayer {
        parsenodefile => true,
        owner => root,
        group => $master::service::apache::apachegroup,
        mode => 0640
    }

    File {
        owner => root,
        group => $master::service::apache::apachegroup,
        mode => 0640
    }

    Nodefile { 
      owner => root,
      group => $master::service::apache::apachegroup,
      mode => 0640
    }
  
  case $::operatingsystem {
      'centos','fedora','redhat': {
           $modmellon_package_base = "auth_mellon"
           $modmellon_module_base= "auth_mellon"
           templatelayer { "/etc/apache2/mods-available/auth_mellon.load":
               require => File["/etc/apache2"]
           }     
           file { "/etc/apache2/conf.d/10-auth_mellon.conf":
               ensure => absent,
           }
           file { "/etc/apache2/conf.d/mod_auth_mellon.conf":
               ensure => absent,
           }
      }
      'debian': {
           $modmellon_package_base = "auth-mellon"
           $modmellon_module_base = "auth_mellon"
       }
  }

  apache2_install_module { $modmellon_package_base: }

  templatelayer { "/etc/apache2/mods-available/auth_mellon.conf":
        require => File["/etc/apache2"]
  }

    nodefile { "/etc/apache2/mellon":
        recurse => true,
        mode => 750
    }

    file { "/etc/apache2/mellon/launchpad.idp.xml":
        source => "puppet:///modules/master/etc/apache2/mellon/${launchpad_xml}"
    }
    require => File["/etc/apache2"]
  }


    case $launchpad_env {
    'sandbox': {
               $launchpad_xml = 'launchpad-sbx.idp.xml'
               $launchpad_cert = 'IDP-SBX-2017-idp.launchpad-sbx.nasa.gov.cer'
               }
     'testing': {
               $launchpad_xml = 'launchpad-test.idp.xml'
               $launchpad_cert = 'opensso-sbx-2015.cer'
               }
      'prod': {
               $launchpad_xml = 'launchpad.idp.xml'
               $launchpad_cert = 'IDP-PROD-2017-idp.launchpad.nasa.gov.cer'
               }
  }

  nodefile { "/etc/apache2/mellon":
    recurse => true,
    mode => 750 
  }
  
  file { "/etc/apache2/mellon/launchpad.idp.xml":
    source => "puppet:///modules/master/etc/apache2/mellon/${launchpad_xml}"
  }

  file { "/etc/apache2/mellon/launchpad.idp.cer":
    source => "puppet:///modules/master/etc/apache2/mellon/${launchpad_cert}"
  }

   notify { 'nccs::security::services':
      message => 'WARNING: mellon client data must be generated and integrated with Launchpad before use!',
   }

  apache2_enable_module { $modmellon_module_base:
    require => [
      Class["master::service::apache::packages"],
      File["/etc/apache2/mods-available/auth_mellon.conf"],
    ]
  }

    file { "/etc/apache2/mellon/launchpad.idp.cer":
        source => "puppet:///modules/master/etc/apache2/mellon/${launchpad_cert}"
    }

    notify { 'nccs::security::services':
        message => 'WARNING: mellon client data must be generated and integrated with Launchpad before use!',
    }
        require => [
                    Class["master::service::apache::packages"],
                    File["/etc/apache2/mods-available/auth_mellon.conf"],
                    ]
    }

    file { "/usr/local/sbin/mellon_create_metadata.sh":
        mode   => 0750,
        source => "puppet:///modules/master/usr/local/sbin/mellon_create_metadata.sh",
        require => File["/usr/local/sbin"]
    }
}
