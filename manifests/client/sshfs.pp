class master::client::sshfs (
  $fusemembers = ""
)
{
    $sshfs_package = $::operatingsystem ? {
        'centos' => 'fuse-sshfs',
        'debian' => 'sshfs',
        default  => '',
    }

    if $sshfs_package == '' {
        fail( "not configured for ${::operatingsystem}" )
    }

    package { $sshfs_package:
        ensure => 'latest',
    }

    groupmembers { fuse: members => $fusemembers }
}
