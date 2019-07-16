# Empty default class -- including this will simply cause the rest of
# init to be parsed and available.
class master { }


# Set default path for all Execs
Exec { path => "/sbin:/usr/sbin:/bin:/usr/bin" }


# Periodic schedule definitions
#
# These only set the maximum number of events per schedule; they do
# not guarantee that a type using them will be executed.
#
schedule { oncedaily:
    period => daily,
    repeat => 1
}

schedule { oncemonthly:
    period => monthly,
    repeat => 1
}

#
# nodefile { "/path/to/file": owner => "username",
#                             defaultensure => "present",
#                             suffix => "" }
#
# This is an alternative to templatelayer (see below) where a file is
# expected to be provided only in the dist override area.
#
# if $suffix is set, the string "-${suffix}" will be appended when
# looking for the file.
#
# If the file is not present in the nodefile area, by default it
# will be actively removed from the target filesystem during the
# puppet run, though the state can be specified with the
# $defaultensure argument, which can also be assigned the special
# value "ignore", which will cause any existing state (present or
# absent) to be left alone if no override file is present.
#
# If the file is present, but $parsenodefile is false (the default),
# there will be a straight copy with no template interpolation, and
# the $recurse variable will be checked to see if a recursive copy
# should be used.
#
# If the file is present and $parsenodefile is set to true, the file
# will be parsed as a template.  This is mutually exclusive with
# $recurse: if $parsenodefile is true, $recurse will be ignored.
#
define nodefile (
    $owner='root',$group='root',$mode='0444',$parsenodefile=false,
    $recurse=false,$suffix=false,$defaultensure='absent',
)
{
    if $suffix {
        $realsuffix = "-${suffix}"
    }
    else {
        $realsuffix = ""
    }

    if nodefile_exists("${title}${realsuffix}") {
        if $parsenodefile {
            file { $title :
                owner => $owner, group => $group, mode => $mode,
                content => template_v3("nodefiles/${::fqdn}${title}${realsuffix}"),
            }
        }
        else {
            file { $title :
                owner => $owner, group => $group, mode => $mode,
                source => "puppet:///modules/nodefiles/${::fqdn}${title}${realsuffix}",
                recurse => $recurse,
            }
        }
    }
    else {
        case $defaultensure {
            "ignore": { }
            default: {
                file { $title : ensure => $defaultensure }
            }
        }
    }
}

#
# This is an alias to nodefile for legacy historical reasons
#
define dist($owner='root',$group='root',$mode='0444',$parsedist=false,
$recurse=false,$defaultensure='absent')
{
    nodefile { $title :
        owner => $owner, group => $group, mode => $mode,
        parsenodefile => $parsedist, recurse => $recurse,
        defaultensure => $defaultensure,
    }
    notify { "dist-${title}":
        message => "DEPRECATED: use of the 'dist' define is deprecated.  Use 'nodefile' instead.",
        loglevel => warning,
    }
}


#
# define groupmembers($members)
#
# Assigns members to a group listed in /etc/groups
#
# The group in question must have been handled by a group command
# previously to ensure that it exists.  The members value will be used
# as a literal string after the final ':', so do not include
# extraneous spaces.
#
# Example:
# groupmembers { mygroup: members => "me,myself,myalias" }
#

define groupmembers($members) {
    if defined(Group[$title]) {
        Exec { require => Group[$title] }
    }
    # Fixing errors in the command.  original command is below
    #    command => "perl -pe 's/^$title:(.*?):(\d+):.*/$title:\1:\2:$members/' -i /etc/group",
    exec { "groupmembers-$title":
        command => "perl -pe 's/^${title}:(.*?):(\\d+):.*/${title}:\\1:\\2:${members}/' -i /etc/group",
        cwd => "/etc",
        path => "/bin:/usr/bin",
        unless => "grep -qE '^$title:.*:[0-9]+:$members' /etc/group"
    }
}


#
# pkginstall { "class-location": installer => "command", packages => $array }
#
# Installs/upgrades a group of packages in a single command,
# potentially accelerating the slow puppet package install process,
# and then passes those packages to a package type.  This is intended
# to be used in place of a regular package{} type.
#
# The default installer is aptitude on Debian and yum on CentOS, but
# this can be extended, and if the installer is not recognized or
# available, this command will still use the package{} type to update
# all packages to the latest version.
#

define pkginstall($installer=false,$packages) {
    $packagestring = inline_template("<%= packages.join(' ') %>")

    if $installer {
        $realinstaller = $installer
    }
    else {
        case $operatingsystem {
            'centos': {
                $realinstaller = "yum"
            }
            'debian': {
                $realinstaller = "aptitude"
            }
            default: {
                $realinstaller = "UNDEFINED"
            }
        }
    }

    case $realinstaller {
        "aptitude","apt-get": {
            $command = "$realinstaller -q -y -o DPkg::Options::=--force-confold install $packagestring"
            if defined(Exec["aptitude-update"]) {
                exec { "aptinstall-$title":
                    path => "/sbin:/usr/sbin:/bin:/usr/bin",
                    command => $command,
                    require => [ Exec["aptitude-update"],
                                 Class["master::common::etckeeper"] ],
                    timeout => 0
                }
                package { $packages: ensure => latest,
                    require => Exec["aptinstall-$title"]
                }
            }
            else {
                err("pkginstall attempted to use apt, but aptitude-update is not available!")
                package { $packages: ensure => latest }
            }
        }
        "yum": {
            $command = "$realinstaller -y install $packagestring"

            exec { "yuminstall-$title":
                path => "/sbin:/usr/sbin:/bin:/usr/bin",
                command => $command,
                timeout => 0,
            }
            package { $packages: ensure => latest, }
        }
        default: {
            err("pkginstall called with unknown installer '$installer'")
            package { $packages: ensure => latest }
        }
    }
}


#
# templatelayer { $filepath : template => $templatepath }
#
# This define uses the title as the full path to the file to create,
# creates it from the specified template if no override exists in the
# nodefiles area, but uses the override file if it does exist.
#
# The only valid 'ensure =>' values are 'present' and 'absent', where
# 'present' is the default.
#
# owner, group, mode, and backup (clientbucket) can optionally be
# specified
#
# The module containing the template can also optionally be specified
# (defaults to the calling module name)
#
# if $ignoremissing is set to true, then if neither a nodefile nor a
# template file for the given module exist no file resource will be
# managed.  This is false by default to catch errors where the wrong
# template is specified, but is available as a parameter to allow
# specific defines to manage sets of files that may not always need to
# be defined.
#
# if $parsenodefile is set to true, override files retrieved from the
# per-host distribution directory (nodefiles) will be parsed as
# templates.  By default, they will be copied directly.
#
# if $prefix is set, it will be prepended to the path ($title) which
# follows the module name; this should generally be a path component
# beginning with a slash (e.g. prefix => "/specialdir"
#
# if $suffix is set, the string "-${suffix}" will be appended when
# looking for the file in the module templates area (but not the
# nodefiles override).
#
# $precommit is a legacy option that used to relate to automatic
# etckeeper commits, but is now ignored.
#

define templatelayer(
    $ensure='present',
    $template=false,
    $module=$caller_module_name,
    $ignoremissing=false,
    $parsenodefile=false,
    $precommit=false,
    $prefix=false,
    $suffix=false,
    $owner='root',
    $group='root',
    $mode='0444',
    $backup=undef,
    $tag=undef,
)
{
    if $prefix {
        $realprefix = $prefix
    }
    else {
        $realprefix = ""
    }

    if $suffix {
        $realsuffix = "-${suffix}"
    }
    else {
        $realsuffix = ""
    }

    if $template {
        $realtemplate = "${template}${realsuffix}"
    }
    else {
        $realtemplate = "${module}${realprefix}${title}${realsuffix}"
    }

    if nodefile_exists($title) {
        if $parsenodefile {
            file { $title :
                ensure => $ensure,
                owner => $owner, group => $group, mode => $mode,
                content => template_v3("nodefiles/${::fqdn}${title}"),
                backup => $backup,
                tag => $tag,
            }
        }
        else {
            file { $title :
                ensure => $ensure,
                owner => $owner, group => $group, mode => $mode,
                source => "puppet:///modules/nodefiles/${::fqdn}${title}",
                backup => $backup,
                tag => $tag,
            }
        }
    }
    elsif $ignoremissing {
        if template_exists($module,$title) {
            file { $title :
                ensure => $ensure,
                owner => $owner, group => $group, mode => $mode,
                content => template_v3($realtemplate),
                backup => $backup,
                tag => $tag,
            }
        }
    }
    else {
        file { $title :
            ensure => $ensure,
            owner => $owner, group => $group, mode => $mode,
            content => template_v3($realtemplate),
            backup => $backup,
            tag => $tag,
        }
    }
}


#
# useradd { $username : ... }
#
# Adds a local user to the system, but only if the username is not
# already present in /etc/passwd.
#
# This will always create the user's home directory if it does not
# exist.
#
# Note that this will fail if the specified GID has not already been
# created.  Ensure that the appropriate require is set when used.
#

define useradd (
    $uid,
    $gid,
    $home,
    $create_home = true,
    $shell="/bin/bash",
    $password="*",
    $comment=""
)
{
    if $create_home {
        $opt_create_home = '-m'
    }
    else {
        $opt_create_home = ''
    }

    exec { "useradd-$title":
        path => '/sbin:/usr/sbin:/bin:/usr/bin',
        command => "useradd -u $uid -g $gid -d $home -s $shell -p $password -c $comment ${opt_create_home} $title",
        unless => "getent passwd ${title}"
    }
}


#
# userdel { $username : }
#
# Deletes a local user from the system, but only if the username is
# present in /etc/shadow.
#
# The reason for the discrepancy in file checked vs useradd is that
# where shell replacements (e.g. rssh, mash) are in use, accounts may
# want to have entries set in /etc/passwd to override the LDAP shell
# entry, but not in /etc/shadow, so that the LDAP password
# authentication still applies.
#
# This will delete the account even if the user is currently logged
# in.
#

define userdel {
    exec { "userdel-$title":
        path => "/sbin:/usr/sbin:/bin:/usr/bin",
        command => "userdel -f $title",
        onlyif => "grep -q '^$title:' /etc/shadow"
    }
}
