class ArtifactHandler
  attr_accessor :type
  def initialize(type)
    @type = type
    if plugin=Module.plugin_type.find{|type, plugin| @type == type}
      extend plugin.last
    else
      extend HandlerPlugin::File
    end
  end
end

class Module
  def plugin_type(type=nil)
    @@plugins ||= {}
    @@plugins[type] ||= self unless type.nil?
    return @@plugins
  end
end

module HandlerPlugin
end

Dir[File.join(File.dirname(__FILE__), 'plugins', '*.rb')].each {|file| require file }

