# Clone a Mercurial repository into a specified path
#
# Does nothing if the destination directory already exists
#
# Parameters:
#   $repo: The URI of the repository
#   $path: The filesystem path to clone into (not including the directory
#          of the repository itself).  This defaults to "/usr/local/src"
#          and must exist before this define is used.
#
define master::hg_clone($repo, $path="/usr/local/src") {
    include master::common::mercurial

    exec { "hg-clone-${title}":
        command => "hg clone ${repo}",
        cwd     => $path,
        path    => "/bin:/usr/bin",
        unless  => "test -d $(basename ${repo} .hg)",
        require => Class["master::common::mercurial"],
    }
}
