#
# class master::common::gpg
# =========================
#
# Ensure that the appropriate command-line GnuPG tool is available to
# the system and allow automatic setup of keys used by root.
#
# This class will automatically distribute nodefiles for
# /root/.gnupg/secring.gpg, and otherwise ensure that the file exists.
#

class master::common::gpg (
    # Parameters
    # ----------

    # ### autorefresh
    #
    # Set up a cron job to automatically refresh keys in root's keyring?
    $autorefresh = true,

    # ### import_keys
    #
    # Array of key IDs to be imported into /root/.gnupg from the specified
    # keyserver.  This can be used to populate a keyring that will be
    # used by automated backups, among other things.
    $import_keys = undef,

    # ### keyserver
    #
    # Default keyserver used by `master::gpg_import_key`, and that can
    # be used by other classes.
    $keyserver = 'hkp://na.pool.sks-keyservers.net',
){
    # Code
    # ----

    $packagename = $::osfamily ? {
        'Debian'  => 'gnupg',
        'RedHat'  => 'gnupg2',
        'OpenBSD' => 'gnupg',
        'Suse'    => 'gpg2',
        default   => 'gnupg'
    }
    package { 'gnupg': name => $packagename }

    file { '/root/.gnupg': ensure => directory,
        owner => root, group => root, mode => '0700',
    }
    file { '/root/.gnupg/keys': ensure => directory,
        owner => root, group => root, mode => '0700',
    }

    nodefile { '/root/.gnupg/secring.gpg': defaultensure => 'present' }

    if $autorefresh {
        templatelayer { '/etc/cron.daily/gpgrefresh': mode => '0555' }
    }
    else {
        file { '/etc/cron.daily/gpgrefresh': ensure => absent }
    }

    if $import_keys {
        master::gpg_import_key { $import_keys: }
    }
}
