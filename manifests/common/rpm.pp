#
# class master::common::rpm
# =========================
#
# Ensure that the rpm and createrepo packages are installed even on
# operating systems that don't use it natively, and import specified
# trusted keys
#
# This is required to manage rpm signing on Debian systems, but can be
# useful for the key management even on CentOS/RedHat.
#
# See also: master::rpmkey
#

class master::common::rpm (
    # Parameters
    # ----------
    #
    # ### keys
    #
    # This is a hash of master::rpmkey parameters, where the top key
    # name is the filename of the public key to import.  By default,
    # .pub is appended to the filename, and it is placed in
    # /root/.gnupg/keys
    #
    # Example:
    #
    #     master::common::rpm::keys:
    #       firstkey:
    #         template: 'mymodule/keys/firstkey.pub'
    #
    # or (for a template found in
    # mymodule/templates/root/.gnupg/keys/firstkey.pub):
    #
    #     master::common::rpm::keys:
    #       firstkey:
    #         module: 'mymodule'
    #
    $keys = false,
){
    require master::common::gpg

    package { 'rpm': }
    package { 'createrepo': }

    if $keys and is_hash($keys) {
        create_resources(master::rpmkey,$keys)
    }
}
