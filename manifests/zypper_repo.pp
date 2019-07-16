#
# define master::zypper_repo
# ==========================
#
# Sets up a Zypper repository for Suse-based systems.
#
# The following keywords, if used as a title, will be populated automatically:
#
#     * devel_languages_perl (openSUSE Perl)
#     * devel_languages_ruby (openSUSE Ruby)
#     * devel_tools_scm (openSUSE Software Configuration Management)
#     * security (OpenSUSE Security)
#     * SLE11-Security-Module
#     * SLE11-SDK-SP4-Updates
#
# OpenSUSE keywords may require the `osid` parameter to be set if autodetection fails.

define master::zypper_repo (
    # Parameters
    # ----------
    # ### autorefresh
    # Whether or not to activate automatic refresh of the repository
    $autorefresh = false,

    # ### baseurl
    # URL of the repository.  If neither this nor repourl is
    # specified, some common keywords will be checked against the
    # title instead.
    $baseurl = false,

    # ### gpgkey
    # URL of the GPG key used to sign the repository, if any.
    #
    # This only has meaning if baseurl is specified.  Keyword matching
    # will use the GPG key associated with the keyword, and use of
    # repourl will download a file already containing GPG information,
    # if any.
    $gpgkey = false,

    # ### osid
    # String containing an operating system identifier used to
    # identify a specific variant of a repository.  If specified, it
    # will be added to the name in the repo file, and it may be
    # required if detection fails for an automatic keywords.
    $osid = false,

    # ### reponame
    # Sets the name field of the repo file.  This only has meaning if
    # `baseurl` is specified.  If not specified, defaults to the title.
    $reponame = false,

    # ### repourl
    # URL of a file containing all repository information (e.g. a
    # "somename.repo" file).  If this is specified, parameters other
    # than `autorefresh` and `osid` are ignored, and the file at the
    # URL is activated via `zypper addrepo` if no matching file exists
    # in /etc/zypp/repos.d.
    #
    # WARNING: be sure when using this option that the expected output
    # filename matches the title of the master::zypper_repo resource.
    # If it does not, every Puppet run will attempt to recreate it.
    # Unfortunately, forcing a match by adding a name to `zypper
    # addrepo` can cause the output to have broken GPG checks and an
    # overwritten internal name.
    $repourl = false,

    # ### template
    # Template to use for the repo file.
    $template = 'master/etc/zypp/repos.d/template.repo'
)
{
    $primary_mirror = $master::common::package_management::primary_mirror

    /* $title will always be used for the header name in the repo
    /* file, but we can't use $title directly in the template */
    $repoheader = $title

    /* If $baseurl or $repourl is specified, bypass automatic keyword detection */
    if $baseurl or $repourl {
        $baseurl_real = $baseurl
        $gpgkey_real = $gpgkey
        $osid_real = $osid
        if $reponame {
            $reponame_real = $reponame
        }
        else {
            $reponame_real = $title
        }
        $repourl_real = $repourl
    }
    else {
        /* Attempt autodetection of parameters for common keywords */
        case $title {
            'devel_languages_perl': {
                if $osid {
                    $osid_real = $osid
                }
                else {
                    case $::operatingsystem {
                        'SLES': {
                            case $::operatingsystemrelease {
                                '11.4': {
                                    $osid_real = 'SLE_11_SP4'
                                }
                                '12.3': {
                                    $osid_real = 'SLE_12_SP3'
                                }
                                default: {
                                    fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                                }
                            }
                        }
                        default: {
                            fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                        }
                    }
                }
                $baseurl_real = "http://download.opensuse.org/repositories/devel:/languages:/perl/${osid_real}/"
                $gpgkey_real = "http://download.opensuse.org/repositories/devel:/languages:/perl/${osid_real}/repodata/repomd.xml.key"
                $reponame_real = "openSUSE Perl Modules"
            }
            'devel_languages_ruby': {
                if $osid {
                    $osid_real = $osid
                }
                else {
                    case $::operatingsystem {
                        'SLES': {
                            case $::operatingsystemmajrelease {
                                '11': {
                                    $osid_real = 'SLE_11_SP4'
                                }
                                '12': {
                                    $osid_real = 'SLE_12'
                                }
                                default: {
                                    fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                                }
                            }
                        }
                        default: {
                            fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                        }
                    }
                }
                $baseurl_real = "http://download.opensuse.org/repositories/devel:/languages:/ruby/${osid_real}/"
                $gpgkey_real = "http://download.opensuse.org/repositories/devel:/languages:/ruby/${osid_real}/repodata/repomd.xml.key"
                $reponame_real = "openSUSE Ruby Base Project"
            }
            'devel_tools_scm': {
                if $osid {
                    $osid_real = $osid
                }
                else {
                    case $::operatingsystem {
                        'SLES': {
                            case $::operatingsystemrelease {
                                '11.4': {
                                    $osid_real = 'SLE_11_SP4'
                                }
                                '12.3': {
                                    $osid_real = 'SLE_12_SP3'
                                }
                                default: {
                                    fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                                }
                            }
                        }
                        default: {
                            fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                        }
                    }
                }
                $baseurl_real = "http://download.opensuse.org/repositories/devel:/tools:/scm/${osid_real}/"
                $gpgkey_real = "http://download.opensuse.org/repositories/devel:/tools:/scm/${osid_real}/repodata/repomd.xml.key"
                $reponame_real = "openSUSE Software Configuration Management"
            }
            'security': {
                if $osid {
                    $osid_real = $osid
                }
                else {
                    case $::operatingsystem {
                        'SLES': {
                            case $::operatingsystemrelease {
                                '11.4': {
                                    $osid_real = 'SLE_11_SP4'
                                }
                                '12.3': {
                                    $osid_real = 'SLE_12_SP3'
                                }
                                default: {
                                    fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                                }
                            }
                        }
                        default: {
                            fail("Unsupported OS ${::operatingsystem} ${::operatingsystemrelease} for ${title}!")
                        }
                    }
                }
                $baseurl_real = "http://download.opensuse.org/repositories/security/${osid_real}/"
                $gpgkey_real = "http://download.opensuse.org/repositories/security/${osid_real}/repodata/repomd.xml.key"
                $reponame_real = 'openSUSE Security Tools'
            }
            'SLE11-SDK-SP4-Updates': {
                $baseurl_real = "${primary_mirror}/SLE11-SDK-SP4-Updates/sle-11-x86_64"
                $reponame_real = $title
            }
            'SLE11-Security-Module': {
                $baseurl_real = "${primary_mirror}/SLE11-Security-Module/sle-11-x86_64"
                $reponame_real = $title
            }
            default: {
                /* This should never actually happen, but we'll cover it anyway */
                $baseurl_real = $baseurl
            }
        }
    }

    if $repourl {
        if $autorefresh {
            $autorefresh_flag = "-f "
        }
        else {
            $autorefresh_flag = ""
        }
        exec { "zypper-repo-${reponame}":
            command => "zypper addrepo ${autorefresh_flag}${repourl_real}",
            cwd     => '/etc/zypp/repos.d',
            path    => '/bin:/usr/bin',
            creates => "/etc/zypp/repos.d/${title}.repo",
        }
    }
    else {
        templatelayer { "/etc/zypp/repos.d/${title}.repo":
            template => "${::realmodule}${template}",
            owner   => root,
            group   => root,
            mode    => '0644',
        }
    }
}
