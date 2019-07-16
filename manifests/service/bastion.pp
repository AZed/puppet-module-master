class master::service::bastion {
  package { "libpam-script": ensure => latest }
  package { "libpam-chroot": ensure => latest }

  nodefile { "/usr/share/libpam-script/pam_script_ses_open":  mode => '0555' }
  nodefile { "/usr/share/libpam-script/pam_script_ses_close": mode => '0555' }

  # New stonesh
  nodefile { "/usr/local/bin/stonesh2": mode => '0555' }
  nodefile { "/usr/local/sbin/stonewho": mode => '0555' }
  file { "/etc/stonesh2": ensure => directory }
  nodefile { "/etc/stonesh2/hosts.lst": require => File["/etc/stonesh2"] }
  nodefile { "/etc/stonesh2/stonesh2.conf": require => File["/etc/stonesh2"] }

  # Symlink to old stonesh
  file { "/usr/local/bin/stonesh":
    ensure  => "/usr/local/bin/stonesh2",
    require => Dist["/usr/local/bin/stonesh2"]
  }

  # Symlink ssh and nc for stonesh2
  file { "/bin/stonesh2-proxy": ensure => "/bin/nc" }
  file { "/bin/stonesh2-bastion": ensure => "/usr/bin/ssh" }
}
