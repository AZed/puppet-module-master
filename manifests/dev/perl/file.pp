#
# class master::dev::perl::file
# =============================
#
# Install Perl packages related to file handling
#

class master::dev::perl::file {
    include master::dev::perl::base

    case $::operatingsystem {
        'debian': {
            package { 'libfile-basedir-perl': }
            package { 'libfile-cache-perl': }
            package { 'libfile-chdir-perl': }
            package { 'libfile-copy-recursive-perl': }
            package { 'libfile-counterfile-perl': }
            package { 'libfile-desktopentry-perl': }
            package { 'libfile-find-rule-perl': }
            package { 'libfile-flat-perl': }
            package { 'libfile-homedir-perl': }
            if versioncmp($::operatingsystemrelease,'7.0') >= 0 {
                package { 'libfile-inplace-perl': }
                package { 'libfile-keepass-perl': }
            }
            package { 'libfile-mimeinfo-perl': }
            package { 'libfile-mmagic-perl': }
            package { 'libfile-mmagic-xs-perl': }
            package { 'libfile-modified-perl': }
            package { 'libfile-ncopy-perl': }
            package { 'libfile-next-perl': }
            package { 'libfile-nfslock-perl': }
            package { 'libfile-path-expand-perl': }
            package { 'libfile-pid-perl': }
            package { 'libfile-readbackwards-perl': }
            package { 'libfile-remove-perl': }
            package { 'libfile-rsync-perl': }
            package { 'libfile-slurp-perl': }
            package { 'libfile-sync-perl': }
            package { 'libfile-tail-perl': }
            package { 'libfile-type-perl': }
            package { 'libfile-which-perl': }
            package { 'libfilehandle-unget-perl': }
            package { 'libfilesys-diskspace-perl': }
        }
        'centos','redhat': {
            package { 'perl-File-BaseDir': }
            package { 'perl-File-DesktopEntry': }
            package { 'perl-File-Find-Rule': }
            if versioncmp($::operatingsystemrelease,'7.0') >= 0 {
                package { 'perl-File-Flat': }
                package { 'perl-File-Sync': }
            }
            package { 'perl-File-HomeDir': }
            package { 'perl-File-Inplace': }
            package { 'perl-File-KeePass': }
            package { 'perl-File-MimeInfo': }
            package { 'perl-File-MMagic': }
            package { 'perl-File-Next': }
            package { 'perl-File-NFSLock': }
            package { 'perl-File-Pid': }
            package { 'perl-File-ReadBackwards': }
            package { 'perl-File-Remove': }
            package { 'perl-File-RsyncP': }
            package { 'perl-File-Slurp': }
            package { 'perl-File-Tail': }
            package { 'perl-File-Type': }
            package { 'perl-File-Which': }
            package { 'perl-FileHandle-Unget': }
            package { 'perl-Filesys-Df': }
        }
        default: {
            notify { "${title}-unknown-os":
                message => "WARNING: ${title} is not configured for ${::operatingsystem}!",
                loglevel => warning,
            }
        }
    }
}
