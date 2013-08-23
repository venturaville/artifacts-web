# Gem Handler Plugin
require 'fileutils'
module HandlerPlugin::Gem
  include HandlerPlugin
  plugin_type "gem"
  def process(filename)
    begin
      Dir.mkdir('gems')
    rescue
    end
    begin
      # --TODO -- need to move gems to a gems directory under here
      FileUtils.mv(filename, "gems/#{filename}", :force => true)
      `gem generate_index`
    rescue Exeception => e
      return {:message => e.message, :backtrace => e.backtrace.inspect}
    end
    return {:type => 'gem', :description => 'Gem Artifact Handler'}
  end
end

