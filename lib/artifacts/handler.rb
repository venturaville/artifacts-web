require 'fileutils'
class Artifacts::Handler

  def cd_groupdir(group)
    groupdir = File.join(@basedir,group)
    return false unless File.directory? groupdir
    FileUtils.cd(groupdir)
    return true
  end

  def list(type,group)
    return false unless cd_groupdir(group)
    return self.send("list_#{type}".to_sym)
  end

  def download(type,group,filename)
    return false unless cd_groupdir(group)
    return self.send("download_#{type}".to_sym,filename)
  end

  def remove(type,group,filename)
    return false unless cd_groupdir(group)
    return self.send("cleanup_#{type}".to_sym,filename)
  end

  def process(type,group,filename)
    return false unless cd_groupdir(group)
    return self.send("process_#{type}".to_sym,filename)
  end

  def initialize(basedir)
    @basedir = basedir
  end

end

Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }
