# Tar Handler Plugin
module HandlerPlugin::Tar
  include HandlerPlugin
  plugin_type "tar"
  def process(filename)
    # --TODO do tar repository setup
    return {:type => 'tar', :description => 'Tar Artifact Handler'}
  end
end

