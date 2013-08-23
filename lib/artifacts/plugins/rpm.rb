
# RPM Handler Plugin
module HandlerPlugin::Rpm
  include HandlerPlugin
  plugin_type "rpm"
  def process(filename)
    `createrepo .`
    return {:type => 'rpm', :description => 'RPM Artifact Handler'}
  end
end

