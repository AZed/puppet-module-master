require 'puppet/file_serving/configuration'
require 'puppet/file_serving/fileset'

module Puppet::Parser::Functions
  newfunction(:recursive_copy, :type => :statement) do |args|
    dest_path = args[0]
    source = args[1]

    fconfig = Puppet::FileServing::Configuration.create
    fpath = fconfig.file_path(source, :node => compiler.node.name)
    files = Puppet::FileServing::Fileset.new(fpath, :recurse =>
true).files
    files.delete('.')
    files.each do |rel_path|
      full_path = File.join(fpath, rel_path)
      stat = File.stat(full_path)
      dest_file = File.join(args[0], rel_path)
      src_file = File.join('puppet://', source, rel_path)
      res = Puppet::Parser::Resource.new({:type => :file, :title =>
dest_file, :scope => self})
      {:path => dest_file, :source => src_file, :owner => stat.uid,
:group => stat.gid,
       :mode => sprintf("%o", stat.mode)[-3..-1]}.each do |n,v|
         res.set_parameter(n,v)
      end
      self.compiler.add_resource(self, res)
    end
  end
end
