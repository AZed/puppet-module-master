#
# master::user::sci::octave::forge
# ================================
#
# Octave Forge packages
# This will also install the base Octave packages required to support them.
#

class master::user::sci::octave::forge {
    include master::user::sci::octave::base

    case $::osfamily {
        'RedHat': {
            # Forge packages aren't available
            $forge_packages = []
        }
        'Debian': {
            $forge_packages = [
                octave-biosig,
                octave-communications,
                octave-control,
                octave-data-smoothing,
                octave-econometrics,
                octave-financial,
                octave-general,
                octave-gsl,
                octave-image,
                octave-io,
                octave-linear-algebra,
                octave-miscellaneous,
                octave-missing-functions,
                octave-nan,
                octave-odepkg,
                octave-optim,
                octave-optiminterp,
                octave-pfstools,
                octave-signal,
                octave-sockets,
                octave-specfun,
                octave-splines,
                octave-statistics,
                octave-strings,
                octave-struct,
                octave-symbolic,
                octave-tsa,
                octave-vrml,
                octave-zenity,
            ]
        }
        default: {
            $forge_packages = []
        }
    }
    ensure_packages($forge_packages)
}
