#
# class master::common::login_shells
# ==================================
#
# Ensures that the basic shells are present on all systems and have
# controlled system-wide configurations.
#

class master::common::login_shells (
    # Parameters
    # ----------
    #
    # ### umask_default
    # Default shell umask.  This is set very restrictive by default.  For
    # group-read access, you may want "027"
    $umask_default = '077'
){
    package { 'bash': }
    package { 'tcsh': }
    package { 'zsh': }

    
    case $::operatingsystem {
        'sles': {
            if versioncmp($::operatingsystemrelease, '12.0') < 0 {
                package { 'ksh': }
            }
            else {
                package { 'mksh': }
                templatelayer { '/etc/bash.bashrc': suffix => "$::operatingsystem-$::operatingsystemmajrelease" }
            }
        }
        'centos', 'redhat' : { 
            templatelayer { '/etc/bash.bashrc': suffix => $::operatingsystem }
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { [ 'bash-completion', 'dash', ]: }
                package { 'ksh': }
            }
            else {
                package { 'bash-completion': }
                package { 'ksh': }
            }
        }
        'ubuntu' : {
            package { [ 'bash-completion', 'dash', ]: }
            package { 'ksh': } 
            templatelayer { '/etc/bash.bashrc': suffix => $::operatingsystem }
        }
        default: {
            package { [ 'bash-completion', 'dash', ]: }
            package { 'ksh': }
            templatelayer { '/etc/bash.bashrc': suffix => $::operatingsystem }
        }
    }

    File { owner => root, group => root }

    file { '/etc/csh': ensure => directory, mode => '0755' }
    file { '/etc/csh/login.d': ensure => directory, mode => '0755' }
    file { '/etc/profile.d': ensure => directory, mode => '0755' }
    file { '/etc/zsh': ensure => directory, mode => '0755' }

    templatelayer { '/etc/csh.cshrc': suffix => $::operatingsystem }
    templatelayer { '/etc/csh.login': suffix => $::operatingsystem }
    templatelayer { '/etc/csh.logout': }
    templatelayer { '/etc/profile': suffix => $::operatingsystem }
    templatelayer { '/etc/profile.d/umask.sh': }
    file { '/etc/profile.d/umask.zsh':
        ensure => link,
        target => 'umask.sh',
    }
    templatelayer { '/etc/zsh/zlogin': }
    templatelayer { '/etc/zsh/zlogout': }
    templatelayer { '/etc/zsh/zprofile': }
    templatelayer { '/etc/zsh/zshenv': }
    templatelayer { '/etc/zsh/zshrc': }
}
