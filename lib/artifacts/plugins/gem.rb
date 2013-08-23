# Gem Handler Plugin
require 'fileutils'

class Artifacts::Handler

  def rebuild_gem()
    `gem generate_index`
  end

  def list_gem()
      return Dir.entries('gems').select {|f| f.end_with? '.gem' }
  end

  def remove_gem(filename)
    FileUtils.rm_f(::File.join('gems',filename))
    rebuild_gem()
  end

  def download_gem(filename)
    return File.open(::File.join('gems',filename),"r")
  end

  def process_gem(filename)
    Dir.mkdir('gems') unless File.directory? 'gem'
    begin
      FileUtils.mv(filename, ::File.join('gems',filename), :force => true)
      rebuild_gem()
    rescue Exeception => e
      return {:message => e.message, :backtrace => e.backtrace.inspect}
    end
    return {:type => 'gem', :description => 'Gem Artifact Handler'}
  end
end

