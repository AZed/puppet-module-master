module Puppet::Parser::Functions
    newfunction(:template_exists, :type => :rvalue) do |args|
        modulename = args[0]
        filepath = args[1]

        environmentpath = lookupvar('settings::environmentpath')
        environment = lookupvar('environment')
        fqdn = lookupvar('fqdn')
        modulepath = environmentpath + '/' + environment + '/modules/'
        templatepath = modulepath + modulename + '/templates'
        path = templatepath + filepath

        File.exists?(path)
    end
end
