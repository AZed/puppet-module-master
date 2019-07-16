#
# class master::service::foswiki
#
# Installs the Foswiki package.  This requires Apache.  It also may
# require an unofficial Debian repository
#

class master::service::foswiki {
  include master::client::ldap
  include master::service::apache
  include master::dev::perl::unicode
  Class['master::service::apache'] -> Class[$name]

  $authldapurl = "${master::client::ldap::uri}/${master::client::ldap::base}?uid??(authorizedService=foswiki)"

  package { 'foswiki': ensure => installed }
  package { 'foswiki-subscribeplugin': ensure => installed }
  package { 'foswiki-genpdfaddon': ensure => installed }

  templatelayer { '/etc/foswiki/apache.conf': }
  file { '/etc/apache2/conf.d/foswiki.conf':
    ensure => '../../foswiki/apache.conf'
  }
  file { '/etc/apt/foswiki.key':
    source => 'puppet:///modules/master/etc/apt/foswiki.key',
    owner => 'root', group => 'root', mode => '0444',
  }

  # Alternate technique, to always pull the latest from upstream:
  # wget -O - http://fosiki.com/Foswiki_debian/FoswikiReleaseGpgKey.asc | apt-key add -

  exec { 'foswiki-archive-key':
    path => '/bin:/usr/bin',
    command => 'apt-key add /etc/apt/foswiki.key',
    unless => 'apt-key list | grep -q AAEE96F6',
    require => File['/etc/apt/foswiki.key']
  }

  # There's not much point in making a default template for
  # LocalSite.cfg, as it will always contain machine-specific names
  nodefile { '/etc/foswiki/LocalSite.cfg':
    owner => 'www-data', group => 'www-data', mode => '0644'
  }

  # Foswiki had a bug in the code that rendered the 'subscribe' or
  # 'unsubscribe' link at the top of the page unformatted.
  templatelayer { '/var/lib/foswiki/pub/System/PatternSkinTheme/style.css':
    owner => 'www-data', group => 'www-data', mode => '0644'
  }

  # The new foswiki had a bug in the code that rendered the 'WYSIWYG' plugin
  # invalid.  So, just pull 'patched' file from dist overrides to enable the
  # plugin again (used for text and table formating)
  templatelayer { '/var/lib/foswiki/lib/Foswiki/Plugins/WysiwygPlugin/TML2HTML.pm':
    owner => 'www-data', group => 'www-data', mode => '0644'
  }

  # Webnotify may vary per machine
  nodefile { '/etc/cron.d/foswiki':
    owner => 'root', group => 'root', defaultensure => 'ignore'
  }

  # The following plugins are also in use, but now appear to be
  # integrated into the main foswiki package.
  #
  # 'foswiki-commentplugin',
  # 'foswiki-edittableplugin',
  # 'foswiki-interwikiplugin',
  # 'foswiki-ldapngplugin',
  # 'foswiki-mailercontrib',
  # 'foswiki-newuserplugin',
  # 'foswiki-preferencesplugin',
  # 'foswiki-slideshowplugin',
  # 'foswiki-smiliesplugin',
  # 'foswiki-spreadsheetplugin',
  # 'foswiki-tableplugin',
  # 'foswiki-wysiwygplugin'

}
