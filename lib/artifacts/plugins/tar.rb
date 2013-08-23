
require 'fileutils'
require 'zlib'
require 'archive/tar/minitar'
include Archive::Tar

# Tar Handler Plugin
class Artifacts::Handler
  def unpack_tar(filename)
    if filename.end_with? '.tar.gz' or filename.end_with? '.tgz' then
      fh = Zlib::GzipReader.new(File.open(filename, 'rb'))
    elsif filename.end_with? '.tar'
      fh = File.open(filename,'r')
    else # unsupported type (--TODO what about bzip?/zip?)
      return false
    end
    Minitar.unpack(fh,FileUtils.pwd)
    return true
  end
  def list_tar()
    return Dir.entries('.').select { |f|
      f.end_with? '.tar' or f.end_with? '.tgz' or f.end_with? '.tar.gz'
    }
  end
  def rebuild_tar()
    # rebuild_tar: we cheat by simply removing everything but the tarballs + metadata, and then re-untarring everything
    entries = Dir.entries('.').select { |f|
      not (%w{ .. . metadata.json }.include?(f) or f.end_with? '.tar' or f.end_with? '.tgz' or f.end_with? '.tar.gz')
    }
    FileUtils.rm_rf(entries) if entries.any?
    list_tar(filename).each do |f|
      unpack_tar(filename)
    end
  end
  def remove_tar(filename)
    FileUtils.rm_rf(filename)
    rebuild_tar()
  end
  def download_tar(filename)
    return File.open(filename,'r')
  end
  def process_tar(filename)
    unpack_tar(filename)
    return {:type => 'tar', :description => 'Tar Artifact Handler'}
  end
end

