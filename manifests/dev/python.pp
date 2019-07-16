#
# class master::dev::python
# =========================
#
# Installs a Python 2 development environment
#

class master::dev::python {
    include master::dev::python::base
    include master::dev::python::crypt

    package { 'python-chardet': }
    package { 'python-configobj': }
    package { 'python-docutils': }
    package { 'python-kerberos': }
    package { 'python-lxml': }
    package { 'python-matplotlib': }
    package { 'python-pmw': }
    package { 'python-psycopg2': }
    package { 'python-pycurl': }
    package { 'python-pygments': }
    package { 'python-requests': }
    package { 'python-sqlalchemy': }
    package { 'python-unittest2': }
    package { 'python-werkzeug': }

    case $::operatingsystem {
        'centos','redhat': {
            package { 'Cython': }
            package { 'h5py': }
            package { 'libiptcdata-python': }
            package { 'libxml2-python': }
            package { 'netcdf4-python': }
            package { 'newt-python': }
            package { 'numpy': }
            package { 'numpy-f2py': }
            package { 'pychart': }
            package { 'pygpgme': }
            package { 'PyQt4': }
            package { 'PyQt4-devel': }
            package { 'PyYAML': }
            package { 'python-basemap': }
            package { 'python-beautifulsoup4': }
            package { 'python-dns': }
            package { 'python-GnuPGInterface': }
            package { 'python2-gnupg': }
            package { 'python-ipython': }
            package { 'python-tools': }
            package { 'pytz': }
            package { 'rrdtool-python': }
            package { 'scipy': }
            package { 'sip-devel': }
            package { 'vtk-python': }
        }
        'debian': {
            package { 'cython': }
            package { 'eric': }
            package { 'idle': }
            package { 'ipython': }
            package { 'pyqt4-dev-tools': }
            package { 'python-bs4': }
            package { 'python-django': }
            package { 'python-dnspython': }
            package { 'python-egenix-mxdatetime': }
            package { 'python-egenix-mxtools': }
            package { 'python-gnupg': }
            package { 'python-gpgme': }
            package { 'python-h5py': }
            package { 'python-iptcdata': }
            package { 'python-libxml2': }
            package { 'python-mpi4py': }
            package { 'python-mpltoolkits.basemap': }
            package { 'python-newt': }
            package { 'python-numexpr': }
            package { 'python-numpy': }
            package { 'python-pkg-resources': }
            package { 'python-pychart': }
            package { 'python-pyvtk': }
            package { 'python-qt4-dev': }
            package { 'python-qt4-gl': }
            package { 'python-roman': }
            package { 'python-rrdtool': }
            package { 'python-scikits-learn': }
            package { 'python-scipy': }
            package { 'python-shapely': }
            package { 'python-sip': }
            package { 'python-tables': }
            package { 'python-textile': }
            package { 'python-tz': }
            package { 'python-urllib3': }
            package { 'python-webpy': }
            package { 'python-webunit': }
            package { 'python-yaml': }
            package { 'spyder': }

            if versioncmp($::operatingsystemrelease, '9.0') < 0 {
                package { 'python-netcdf': }
            }
            else {
                package { 'python-netcdf4': }
            }
        }
        'sles': {
            package { 'python-idle': }
            package { 'python-gpgme': }
            package { 'python-numpy': }
            package { 'python-rrdtool': }
        }
        default: { }
    }
}
