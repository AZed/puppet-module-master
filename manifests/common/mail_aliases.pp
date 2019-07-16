#
# class master::common::mail_aliases
# ==================================
#
# Defines the standard mail aliases
#
# Note that abuse, webmaster, security, and root itself are not
# defined here due to potential special handling requirements.  Create
# your own <module>::common::mail_aliases class to include this
# and define those there.
#
# This class requires master::common::mta to ensure the newaliases
# command is available.

class master::common::mail_aliases (
    # Parameters
    # ----------
    #
    # ### mailerdaemon
    # ### nobody
    # ### hostmaster
    # ### postmaster
    # ### usenet
    # ### news
    # ### www
    # ### ftp
    # ### noc
    #
    # Default recipients for standard aliases
    $mailerdaemon = 'postmaster',
    $nobody = 'root',
    $hostmaster = 'root',
    $postmaster = 'root',
    $usenet = 'root',
    $news = 'root',
    $www = 'webmaster',
    $ftp = 'root',
    $noc = 'root'
)
{
    require master::common::mta

    exec { 'newaliases':
        path => '/usr/bin:/bin:/usr/sbin:/sbin',
        command => 'newaliases',
        refreshonly => true,
    }

    Mailalias {
        notify => Exec['newaliases']
    }

    # Miscellaneous standard aliases
    mailalias { 'mailer-daemon': ensure => present,
        recipient => $mailerdaemon,
    }
    mailalias { 'nobody': ensure => present,
        recipient => $nobody,
    }
    mailalias { 'hostmaster': ensure => present,
        recipient => $hostmaster,
    }
    mailalias { 'postmaster': ensure => present,
        recipient => $postmaster,
    }
    mailalias { 'usenet': ensure => present,
        recipient => $usenet,
    }
    mailalias { 'news': ensure => present,
        recipient => $news,
    }
    mailalias { 'www': ensure => present,
        recipient => $www,
    }
    mailalias { 'ftp': ensure => present,
        recipient => $ftp,
    }
    mailalias { 'noc': ensure => present,
        recipient => $noc,
    }
}
