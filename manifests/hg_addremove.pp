# Prepare all files in a repository for commit
#
define master::hg_addremove($repo) {
    include master::common::mercurial

    exec { "hg-addremove-${title}":
        command => "hg addremove",
        cwd     => $repo,
        path    => "/bin:/usr/bin",
        onlyif  => "test -d ${repo}/.hg",
        require => [ Templatelayer["/etc/mercurial/hgrc"],
                     Templatelayer["/etc/mercurial/hgrc.d/hgext.rc"] ]
    }
}
