#
# master::user::audio
# ===================
#
# End-user audio support
#
# ALSA is enabled by default.  OSS and PulseAudio are optional.
# Turning both OSS and PulseAudio on at the same time may produce
# unexpected results.
#

class master::user::audio (
    # Permissions on audio devices
    $dev_mode = '0660',

    # Owner of audio devices
    $dev_owner = 'root',

    # Group of audio devices
    $dev_group = 'audio',

    # Members of group audio
    $groupmembers = '',

    # Enable legacy OSS support?  (This may break PulseAudio)
    $oss = false,

    # Enable Pulse Audio? (This may sometimes interfere with ALSA)
    $pulseaudio = false
)
{
    Package { ensure => latest }

    package { 'alsa-utils': }
    package { 'alsamixergui': }

    templatelayer { '/etc/udev/rules.d/99-audio_permissions.rules': }

    groupmembers { 'audio': members => $groupmembers }

    if $pulseaudio {
        package { 'pulseaudio': }
    }
    else {
        package { 'pulseaudio': ensure => absent }
    }
    case $osfamily {
        'RedHat': {
            package { 'alsa-lib': }
            templatelayer { '/etc/modprobe.d/dist-oss.conf': }
        }
        default: {
        }
    }
}
