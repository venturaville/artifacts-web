
# RPM Handler Plugin
class Artifacts::Handler
  def rebuild_rpm()
    `createrepo .`
  end
  def list_rpm()
      return Dir.entries('.').select {|f| f.end_with? '.rpm' }
  end
  def remove_rpm(filename)
    FileUtils.rm(filename) unless not File.exist? filename
    rebuild_rpm()
  end
  def download_rpm(filename)
    return File.open(filename,"r")
  end
  def process_rpm(filename)
    rebuild_rpm()
    return {:type => 'rpm', :description => 'RPM Artifact Handler'}
  end
end

