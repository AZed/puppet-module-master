# Pull remote changes into a local mercurial repository and update to
# new branch head
#
define master::hg_pull($repo, $remote="") {
    include master::common::mercurial

    exec { "hg-pull-${title}":
        command => "hg pull -f -u ${remote}",
        cwd     => $repo,
        path    => "/bin:/usr/bin",
        require => Class["master::common::mercurial"],
    }
}
