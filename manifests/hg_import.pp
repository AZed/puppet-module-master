# Import an exported patch back into a Mercurial repository
#
# $repo is the full path to the repository
#
# $summary is a unique string found in the summary of the patch, and
# will be used to determine if the patch has already been applied
#
define master::hg_import($repo, $summary) {
    include master::common::mercurial

    exec { "hg-import-${title}":
        command => "hg import ${title}",
        cwd     => $repo,
        path    => '/bin:/usr/bin',
        onlyif  => "test -d ${repo}/.hg",
        unless  => "hg log -k '${summary}' | grep -q .",
        require => [ Templatelayer['/etc/mercurial/hgrc'],
                     Templatelayer['/etc/mercurial/hgrc.d/hgext.rc'] ]
    }
}
