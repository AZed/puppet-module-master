module Puppet::Parser::Functions
  newfunction(:file_exists, :type => :rvalue) do |args|
    basepath = args[0]
    filepath = args[1]
    path = basepath + filepath

    File.exists?(path)
  end
end
