#
# debian.rb
#
# List Debian codename information and archived status
#
# The Debian testing release codename is defined to be always the one
# ahead of the main release, irrespective of what the current debian
# testing release symlink actually points to.  This provides a stable
# referent for a system designed at a particular point in time.
#

Facter.add('debian_release_codename') do
    confine :operatingsystem => 'Debian'
    setcode do
        osrelease = Facter.value('operatingsystemrelease')
        case osrelease
        when /^1\.1\./
            'buzz'
        when /^1\.2\./
            'rex'
        when /^1\.3\./
            'bo'
        when /^2\.0\./
            'hamm'
        when /^2\.1\./
            'slink'
        when /^2\.2\./
            'potato'
        when /^3\.0\./
            'woody'
        when /^3\.1\./
            'sarge'
        when /^4\./
            'etch'
        when /^5\./
            'lenny'
        when /^6\./
            'squeeze'
        when /^7\./
            'wheezy'
        when /^8\./
            'jessie'
        when /^9\./
            'stretch'
        else
            ''
        end
    end
end


Facter.add('debian_testing_codename') do
    confine :operatingsystem => 'Debian'
    setcode do
        osrelease = Facter.value('operatingsystemrelease')
        case osrelease
        when /^1\.1\./
            'rex'
        when /^1\.2\./
            'bo'
        when /^1\.3\./
            'hamm'
        when /^2\.0\./
            'slink'
        when /^2\.1\./
            'potato'
        when /^2\.2\./
            'woody'
        when /^3\.0\./
            'sarge'
        when /^3\.1\./
            'etch'
        when /^4\./
            'lenny'
        when /^5\./
            'squeeze'
        when /^6\./
            'wheezy'
        when /^7\./
            'jessie'
        when /^8\./
            ''
        else
            ''
        end
    end
end


Facter.add('debian_release_archived') do
    confine :operatingsystem => 'Debian'
    setcode do
        osrelease = Facter.value('operatingsystemrelease')
        case osrelease
        when /^1\.1\./
            true
        when /^1\.2\./
            true
        when /^1\.3\./
            true
        when /^2\.0\./
            true
        when /^2\.1\./
            true
        when /^2\.2\./
            true
        when /^3\.0\./
            true
        when /^3\.1\./
            true
        when /^4\./
            true
        when /^5\./
            true
        else
            ''
        end
    end
end
