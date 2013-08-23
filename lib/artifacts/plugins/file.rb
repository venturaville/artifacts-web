# File Handler Plugin
module HandlerPlugin::File
  include HandlerPlugin
  plugin_type "file"
  def process(filename)
    return {:type => 'file', :description => 'File Artifact Handler'}
  end
end

