#
# class master::common::locate
# ============================
#
# Sets up the locate command and the associated database generation
#
# The default prune values have been created by merging values from
# CentOS, Debian, and Suse, and are expected to be better defaults
# than any of the OS defaults.
#

class master::common::locate (
    # Parameters
    # ----------
    #
    # ### prune_bind_mounts
    # Skip bind mounts and any filesystems mounted below bind mounts.
    # Must be one of  the  strings '0', 'no', '1' or 'yes'
    # Not valid for Suse
    $prune_bind_mounts = 'yes',

    # ### prunenames
    # Directory names (without paths) that should be excluded from scanning
    # Not valid for Suse
    $prunenames = false,

    # ### prunepaths
    # Directory path names (exactly in the form as would be reported
    # by locate) that should be excluded from scanning
    $prunepaths = [ '/tmp', '/var/spool', '/media', '/sys',
                    '/var/cache/ccache', '/var/lib/puppet/clientbucket',
                    '/var/lib/yum/yumdb', '/var/spool/cups',
                    '/var/spool/postfix', '/var/spool/squid', '/var/tmp', ],

    # ### prunefs
    # File system types (as used in /etc/mtab) which should not be scanned
    $prunefs = [ '9p', 'afs', 'anon_inodefs', 'auto', 'autofs', 'bdev',
                 'binfmt_misc', 'cgroup', 'cifs', 'coda', 'configfs',
                 'curlftpfs', 'cpuset', 'debugfs', 'devfs', 'devpts',
                 'ecryptfs', 'exofs', 'fuse', 'fuse.glusterfs', 'fuse.sshfs',
                 'fusectl', 'ftpfs', 'gfs', 'gfs2', 'gpfs', 'hugetlbfs',
                 'inotifyfs', 'iso9660', 'jffs2', 'lustre', 'mfs', 'mqueue',
                 'ncpfs', 'nfs', 'nfs4', 'nfsd', 'pipefs', 'proc', 'ramfs',
                 'rpc_pipefs', 'securityfs', 'selinuxfs', 'sfs', 'shfs',
                 'smbfs', 'sockfs', 'sysfs', 'tmpfs', 'ubifs', 'udf', 'usbfs',
                 ],
){
    case $::operatingsystem {
        'SLES': {
            if versioncmp($::operatingsystemrelease, '12.0') < 0 {
                package { 'findutils-locate': }
                templatelayer { '/etc/sysconfig/locate': }
            }
            else {
                package { 'mlocate': }
                templatelayer { '/etc/updatedb.conf': }
            }
        }
        default: {
            package { 'mlocate': }
            templatelayer { '/etc/updatedb.conf': }
        }
    }
}
