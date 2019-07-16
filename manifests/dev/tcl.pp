class master::dev::tcl {
    Package { ensure => latest }
    case $::operatingsystem {
        'debian': {
            $dev_tcl_packages =
            [
                'blt',
                'tcl', 'tcl-dev',
                'tcl-doc',
                'tcl-tls',
                'tix',
                'tk', 'tk-dev',
                'tk-doc',
                'tkcon',
            ]
            # tclreadline changed to tcl-tclreadline in Wheezy
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { 'tclreadline': }
            }
            else {
                package { 'tcl-tclreadline': }
            }
        }
        'centos','redhat': {
            $dev_tcl_packages =
            [
                'blt', 'blt-devel',
                'tcl', 'tcl-devel',
                'tclx', 'tclx-devel',
                'tk', 'tk-devel',
            ]
        }
    }
    package { $dev_tcl_packages: }
}
