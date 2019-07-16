#
# define master::gpg_import_key
# =============================
#
# Import a GPG key from a keyserver into a keyring (root's keyring by
# default), but only if it does not already exist.
#
# To avoid causing exec actions on systems where no change is needed,
# this define cannot be used to refresh a keyring.
#

define master::gpg_import_key (
    # Parameters
    # ----------

    # ### gpgdir
    # GPG home directory to use
    $gpgdir = '/root/.gnupg',

    # ### keyserver
    # Keyserver to download from (will use the value of
    # master::common::gpg::keyserver if left undefined)
    $keyserver = undef
){
    include master::common::gpg

    if $keyserver {
        $realkeyserver = $keyserver
    }
    else {
        $realkeyserver = $master::common::gpg::keyserver
    }

    exec { "gpg_import_key-${title}":
        path    => '/bin:/usr/bin',
        command => "gpg --homedir ${gpgdir} --keyserver ${realkeyserver} --recv-keys ${title}",
        unless  => "gpg --homedir ${gpgdir} --list-keys ${title}",
        require => Package['gnupg'],
    }
}
