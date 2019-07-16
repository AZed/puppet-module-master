#
# define master::apt_repo
# =======================
#
# Sets up an Apt repository
# Currently only tested under Debian
#
# No detection is done to determine if you are adding a repo identical
# to the default system repo, so don't do that.
#
# The following keywords, if used as a title, will be populated automatically:
#    squeeze
#    squeeze-backports
#    squeeze-backports-sloppy
#    squeeze-lts
#    wheezy
#    wheezy-backports
#    jessie
#    jessie-backports
#    stretch
#    stretch-backports
#    buster
#    deb-multimedia
#    foswiki
#    fusioninventory
#    neurodebian
#    postgresql
#
# Preferences files are not handled by this define -- instead, this
# define will trigger any virtual Templatelayer resources tagged with
# the pattern `apt_repo_${title}`
#
# For example, if you call `master::apt_repo { 'mycustom': }` then the
# following, in any other class, would also trigger:
#
#     templatelayer { '/etc/apt/preferences/mycustom':
#       tag => 'apt_repo_mycustom',
#     }
#

define master::apt_repo (
    # Parameters
    # ----------

    # ### debian_mirror
    # URL of the Debian mirror to use for official repositories (without
    # trailing slash).  Note that this only works if the mirror uses the
    # same directory naming as the official mirrors.
    $debian_mirror = $master::common::package_management::debian_mirror,

    # ### debian_backports_mirror
    # URL of the Debian mirror to use for backports repositories
    # (without trailing slash).
    $debian_backports_mirror = $master::common::package_management::debian_backports_mirror,

    # ### nonfree
    # Allow non-free packages
    $nonfree = $master::common::package_management::nonfree,

    # ### keyserver
    # Keyserver to use when importing repository signing keys
    $keyserver = 'pgp.mit.edu',

    # ### signing_key_source
    # A file source, the contents of which will be placed in
    # /etc/apt/trusted.gpg.d/${title}.gpg.
    #
    # Example:
    #
    #   signing_key_source => 'puppet:///modules/mymodule/etc/apt/trusted.gpg.d/myrepo.gpg'
    #
    $signing_key_source = false,

    # ### signing_keyid
    # As an alternate to signing_key_source, above, this is a keyid to
    # be imported into apt from a keyserver, but it will only be used
    # if `title` does not match a known keyword.
    #
    # Note that no verification is done of this key during the
    # retrieval process -- if something can redirect this keyserver
    # request, the security of the entire server could be compromised.
    # Use signing_key_source, above, if possible, for keys you control.
    $signing_keyid = false,

    # ### sources_lines
    # $sources_lines contains the array of lines to populate the
    # sources.list.d file, but it will only be used if $title does not
    # match a known keyword.
    $sources_lines = [ ],

    # ### sources_template
    # The template that will be used to generate the sources.list.d file
    $sources_template = 'master/etc/apt/sources.list.d/template'
)
{
    # Code Comments
    # -------------
    include master::common::package_management

    if $nonfree {
        $nonfreetext = " contrib non-free"
    }
    else {
        $nonfreetext = ""
    }


    # ### Attempt autodetection of parameters for common keywords
    case $title {
        # Debian 6
        'squeeze': {
            $deb_lines = [
                "deb ${debian_mirror} squeeze main${nonfreetext}",
                "deb-src ${debian_mirror} squeeze main${nonfreetext}",
            ]
        }

        # Debian 7
        'wheezy': {
            $deb_lines = [
                "${debian_mirror} wheezy main${nonfreetext}",
                "${debian_mirror} wheezy main${nonfreetext}",
            ]
        }
        'wheezy-backports': {
            $deb_lines = [
                "deb ${debian_backports_mirror} wheezy-backports main${nonfreetext}",
            ]
        }

        # Debian 8
        'jessie': {
            $deb_lines = [
                "deb ${debian_mirror} jessie main${nonfreetext}",
                "deb-src ${debian_mirror} jessie main${nonfreetext}",
            ]
        }
        'jessie-backports': {
            $deb_lines = [
                "deb ${debian_backports_mirror} jessie-backports main${nonfreetext}",
                "deb-src ${debian_backports_mirror} jessie-backports main${nonfreetext}",
            ]
        }

        # Debian 9
        'stretch': {
            $deb_lines = [
                "deb ${debian_mirror} stretch main${nonfreetext}",
                "deb-src ${debian_mirror} stretch main${nonfreetext}",
            ]
        }
        'stretch-backports': {
            $deb_lines = [
                "deb ${debian_backports_mirror} stretch-backports main${nonfreetext}",
                "deb-src ${debian_backports_mirror} stretch-backports main${nonfreetext}",
            ]
        }

        # Debian 10
        'buster': {
            $deb_lines = [
                "deb ${debian_mirror} buster main${nonfreetext}",
                "deb-src ${debian_mirror} buster main${nonfreetext}",
            ]
        }

        # Debian Unstable
        'sid': {
            $deb_lines = [
                "deb ${debian_mirror} sid main${nonfreetext}",
                "deb-src ${debian_mirror} sid main${nonfreetext}",
            ]
        }

        # Unofficial multimedia package repository
        # This is implicitly non-free
        'deb-multimedia': {
            $deb_lines = [
                'deb http://www.deb-multimedia.org ${::debian_release_codename} main non-free',
            ]
            $keyid     = '1F41B907'
        }

        # Foswiki's unofficial Debian repository
        # This implicitly pulls contrib
        'foswiki': {
            $deb_lines = [
                'deb http://fosiki.com/Foswiki_debian/ stable main contrib',
                'deb-src http://fosiki.com/Foswiki_debian/ stable main contrib',
            ]
        }

        # FusionInventory unofficial Debian repository
        'fusioninventory': {
            $deb_lines = [
                "deb http://debian.fusioninventory.org/debian/ ${::debian_release_codename} main",
            ]
            $keyid     = '049ED9B94765572E'
        }

        # NeuroDebian Project Repository
        'neurodebian': {
            $deb_lines = [
                "deb http://neuro.debian.net/debian data main${nonfreetext}",
                "deb-src http://neuro.debian.net/debian data main${nonfreetext}",
                "deb http://neuro.debian.net/debian ${::debian_release_codename} main${nonfreetext}",
                "deb-src http://neuro.debian.net/debian ${::debian_release_codename} main${nonfreetext}",
            ]
            $keyid     = '2649A5A9'
        }

        # Oracle Java from Ubuntu Launchpad
        'oracle-java-launchpad': {
            $deb_lines = [
                "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main",
                "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main",
            ]
            $keyid     = 'EEA14886'
        }

        # PostGRESQL latest packages repository
        'postgresql': {
            $deb_lines = [
                "deb http://apt.postgresql.org/pub/repos/apt/ ${::debian_release_codename}-pgdg main",
            ]
            $keyid     = 'ACCC4CF8'
        }

        # Adiscon repository for RSyslog
        'rsyslog-v8': {
            $deb_lines = [
                "# Adiscon repository for rsyslog",
                "deb http://debian.adiscon.com/v8-stable ${::debian_release_codename}/",
                "deb-src http://debian.adiscon.com/v8-stable ${::debian_release_codename}/",
            ]
            $keyid     = 'AEF0CF8E'
        }

        # Unrecognized custom repository
        default: {
            if ! $sources_lines {
                fail("Apt repo '${title}' not recognized and no source specified.")
            }
            $deb_lines = $sources_lines
            $keyid     = $signing_key
        }
    }

    $reponame = $title
    templatelayer { "/etc/apt/sources.list.d/${title}.list":
        template => $sources_template,
        owner    => root,
        group    => root,
        mode     => '0444',
    }

    if $preferences_templates {
        templatelayer { "/etc/apt/preferences.d/${title}":
            template => "${preferences_templates}/${title}",
            owner    => root,
            group    => root,
            mode     => '0444',
        }
    }

    if $signing_key_source {
        file { "/etc/apt/trusted.gpg.d/${title}.gpg":
            source => $signing_key_source,
            owner  => 'root',
            group  => 'root',
            mode   => '0444',
        }
    }

    if $keyid {
        exec { "apt-import-key-${keyid}":
            command => "apt-key adv --recv-keys --keyserver ${keyserver} ${keyid}",
            cwd     => '/etc/apt',
            path    => '/bin:/usr/bin',
            unless  => "apt-key list | grep -q ${keyid}",
        }
    }

    # Activate any templatelayers for this repository in any other
    # active classes
    Templatelayer <| tag == "apt_repo_${title}" |>
}
