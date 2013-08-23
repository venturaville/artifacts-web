# File Handler Plugin
class Artifacts::Handler

    def rebuild_file()
      # noop
      return true
    end

    def list_file()
      return Dir.entries('.').select {|f| not %w{ . .. metadata.json }.include? f }
    end

    def remove_file(filename)
      FileUtils.rm_f(filename)
      return rebuild_file()
    end

    def download_file(filename)
      return File.open(filename,"r")
    end

    def process_file(filename)
      # do nothing
      rebuild_file()
      return {:type => 'file', :description => 'File Artifact Handler', :name => filename}
    end
end

