#
# master::dev::audio
# ==================
#
# Packages for audio manipulation code development
#

class master::dev::audio {
  Package { ensure => latest }

  case $::operatingsystem {
    'centos','redhat': {
      package { 'alsa-lib-devel': }
      package { 'audiofile-devel': }
      package { 'esound-devel': }
      package { 'pulseaudio-libs-devel': }
      package { 'pulseaudio-utils': }
    }
    'debian': {
      package { 'liba52-0.7.4-dev': }
      package { 'libasound2-dev': }
      package { 'libasound2-plugins': }
      package { 'libaudiofile-dev': }
      package { 'libopencore-amrnb-dev': }
      package { 'libopencore-amrwb-dev': }
    }
    default: { }
  }
  nodefile { '/etc/asound.state': defaultensure => 'ignore' }
}
