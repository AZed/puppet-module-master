require 'puppet/parser/files'
require 'puppet/parser/scope'
require 'erb'
require 'puppet/file_system'

# A simple wrapper for templates, so they don't have full access to
# the scope objects.
#
# This forces the legacy invocation of scope.to_hash from Puppet v3 so
# that templates inside defines retain access to the scope of the
# class calling the define.
class Puppet::Parser::TemplateWrapperV3
  include Puppet::Util
  Puppet::Util.logmethods(self)

  Puppet::Parser::Scope.class_eval {
      def to_hash_v3(recursive = true)
          if recursive and parent
              target = parent.to_hash_v3(recursive)
          else
              target = Hash.new
          end

          # add all local scopes
          @ephemeral.last.add_entries_to(target)
          target
      end
  }

  def initialize(scope)
    @__scope__ = scope
  end

  # @return [String] The full path name of the template that is being executed
  # @api public
  def file
    @__file__
  end

  # @return [Puppet::Parser::Scope] The scope in which the template is evaluated
  # @api public
  def scope
    @__scope__
  end

  # Find which line in the template (if any) we were called from.
  # @return [String] the line number
  # @api private
  def script_line
    identifier = Regexp.escape(@__file__ || "(erb)")
    (caller.find { |l| l =~ /#{identifier}:/ }||"")[/:(\d+):/,1]
  end
  private :script_line

  # Should return true if a variable is defined, false if it is not
  # @api public
  def has_variable?(name)
    scope.include?(name.to_s)
  end

  # @return [Array<String>] The list of defined classes
  # @api public
  def classes
    scope.catalog.classes
  end

  # @return [Array<String>] The tags defined in the current scope
  # @api public
  def tags
    scope.tags
  end

  # @return [Array<String>] All the defined tags
  # @api public
  def all_tags
    scope.catalog.tags
  end

  # @api private
  def file=(filename)
    unless @__file__ = Puppet::Parser::Files.find_template(filename, scope.compiler.environment)
      raise Puppet::ParseError, "Could not find template '#{filename}'"
    end
  end

  # @api private
  def result(string = nil)
    if string
      template_source = "inline template"
    else
      string = File.read(@__file__)
      template_source = @__file__
    end

    # Expose all the variables in our scope as instance variables of the
    # current object, making it possible to access them without conflict
    # to the regular methods.
    benchmark(:debug, "Bound template variables for #{template_source}") do
      scope.to_hash_v3.each do |name, value|
        realname = name.gsub(/[^\w]/, "_")
        instance_variable_set("@#{realname}", value)
      end
    end

    result = nil
    benchmark(:debug, "Interpolated template #{template_source}") do
      template = ERB.new(string, 0, "-")
      template.filename = @__file__
      result = template.result(binding)
    end

    result
  end

  def to_s
    "template[#{(@__file__ ? @__file__ : "inline")}]"
  end
end

Puppet::Parser::Functions::newfunction(:template_v3, :type => :rvalue, :arity => -2, :doc =>
  "Loads an ERB template from a module, evaluates it, and returns the resulting
  value as a string.

  The argument to this function should be a `<MODULE NAME>/<TEMPLATE FILE>`
  reference, which will load `<TEMPLATE FILE>` from a module's `templates`
  directory. (For example, the reference `apache/vhost.conf.erb` will load the
  file `<MODULES DIRECTORY>/apache/templates/vhost.conf.erb`.)

  This function can also accept:

  * An absolute path, which can load a template file from anywhere on disk.
  * Multiple arguments, which will evaluate all of the specified templates and
  return their outputs concatenated into a single string.") do |vals|
    vals.collect do |file|
      # Use a wrapper, so the template can't get access to the full
      # Scope object.
      debug "Retrieving template #{file}"

      wrapper = Puppet::Parser::TemplateWrapperV3.new(self)
      wrapper.file = file
      begin
        wrapper.result
      rescue => detail
        info = detail.backtrace.first.split(':')
        raise Puppet::ParseError,
          "Failed to parse template #{file}:\n  Filepath: #{info[0]}\n  Line: #{info[1]}\n  Detail: #{detail}\n"
      end
    end.join("")
end
