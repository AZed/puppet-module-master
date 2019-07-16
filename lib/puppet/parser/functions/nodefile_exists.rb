module Puppet::Parser::Functions
    newfunction(:nodefile_exists, :type => :rvalue) do |args|
        filepath = args[0]

        environmentpath = lookupvar('settings::environmentpath')
        environment = lookupvar('environment')
        fqdn = lookupvar('fqdn')
        modulepath = environmentpath + '/' + environment + '/modules'
        nodefilepath = modulepath + '/nodefiles/files/' + fqdn
        path = nodefilepath + filepath

        File.exists?(path)
    end
end
