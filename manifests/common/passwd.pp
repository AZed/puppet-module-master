#
# class master::common::passwd
# ============================
#
# Enforce ownership and perms on password and shadow files
#
class master::common::passwd {
    File { owner => root }

    case $operatingsystem {
        'centos','redhat': {
            $shadowgroup = 'root'
        }
        default: {
            $shadowgroup = 'shadow'
        }
    }
    file { '/etc/passwd':
        group => root, mode => '0644',
    }
    file { '/etc/group':
        group => root, mode => '0644',
    }
    file { '/etc/shadow':
        group => $shadowgroup, mode => '0640',
    }
    file { '/etc/gshadow':
        group => $shadowgroup, mode => '0640',
    }
}
