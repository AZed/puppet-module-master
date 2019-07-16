#
# class master::common::sudo
# ==========================
#
# Ensure that the sudo package is installed and provide a flexible way
# of handling the contents of /etc/sudoers.
#
# WARNING: this class will take complete ownership of /etc/sudoers.d,
# removing unmanaged files.  This is for security benefit, but may
# cause surprises if you install third-party packages that place files
# there without making them recognized by Puppet.
#

class master::common::sudo (
    # Parameters
    # ----------

    # ### env_reset
    # ### env_keep
    # Environment handling
    $env_reset            = true,
    $env_keep             =
    'COLORS DISPLAY EMAIL GIT_COMMITTER_EMAIL GIT_COMMITTER_NAME HGUSER HISTSIZE HOME HOSTNAME KRB5CCNAME LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_ALL LS_COLORS MAIL PATH PS1 PS2 TZ XAUTHORITY XAUTHORIZATION _XKB_CHARSET',

    # ### root_group
    # Members of this group will be allowed to execute any command as
    # any user (including root!).  The defaults match the defaults of
    # the underlying operating system family to avoid breaking the
    # assumptions of a freshly installed system, but it is highly
    # recommended to set this to false in your own configuration if
    # you do not explicitly need it.
    $root_group = $::osfamily ? {
        'Debian' => 'sudo',
        'RedHat' => 'wheel',
    },

    # ### admins
    # System administrators will be allowed to execute any command as
    # any user (including root!).  This loads from the global Hiera
    # value 'admins' by default, as that value is used in multiple
    # classes.
    $admins = hiera('admins',[]),

    # ### root_users
    # The following userids will ALSO be allowed to execute any
    # command as any user (including root!), e.g. for auditors or
    # temporary admins.
    $root_users = [ ],

    # ### includedirs
    # This will create and enforce ownership and permissions on all
    # listed directories in addition to adding them to sudoers, and
    # purge any unmanaged files in these locations.
    $includedirs          = [ '/etc/sudoers.d', ],

    # ### host_alias_templates
    # ### host_alias_lines
    # ### user_alias_templates
    # ### user_alias_lines
    # ### cmnd_alias_templates
    # ### cmnd_alias_lines
    # ### user_priv_templates
    # ### user_priv_lines
    # ### final_templates
    # ### final_lines
    # Arrays of template fragments or lines to be placed in each
    # specific sudoers section and at the end of the file
    $host_alias_templates = [ ],
    $host_alias_lines     = [ ],
    $user_alias_templates = [ ],
    $user_alias_lines     = [ ],
    $cmnd_alias_templates = [ ],
    $cmnd_alias_lines     = [ ],
    $user_priv_templates  = [ ],
    $user_priv_lines      = [ ],
    $final_templates      = [ ],
    $final_lines          = [ ]
)
{
    # Code
    # ----

    package { 'sudo': ensure => present, }
    templatelayer { '/etc/sudoers':
        owner => root, group => root, mode => '0440',
    }

    file { $includedirs:
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0750',
        recurse => true,
        purge   => true,
    }

    # Activate any templatelayers for sudo rules in any other active
    # classes
    Templatelayer <| tag == 'sudo_rule' |>
}
