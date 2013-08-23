require 'rubygems'
require 'tempfile'
require 'yajl'

class Artifacts
  
  def self.atomic_write(file_name, mode=0644)
    temp_file = Tempfile.new(".artifacts." + File.basename(file_name), File.dirname(file_name))
    yield temp_file
    temp_file.close
    # Overwrite original file with temp file
    FileUtils.mv(temp_file.path, file_name)
    FileUtils.chmod(mode, file_name)
  end
  
  class Group
    attr_accessor :name
    attr_accessor :type
    def initialize(dir)
      g = Yajl::Parser.parse(IO.read(File.join(dir, "metadata.json")))
      @name = g['name']
      @type = g['type']
    end

    def self.delete(dir)
      FileUtils.rm_rf(dir)
    end

    def self.create(dir, name, type="file")
      begin
        Dir.mkdir(dir)
      rescue Errno::EEXIST
      end
      g = { :name => name, :type => type }
      Artifacts::atomic_write(File.join(dir, "metadata.json")) do |f|
        f.write Yajl::Encoder.encode(g)
      end
      #puts(dir)
      new(dir)
    end
     
    def to_json
      Yajl::Encoder.encode(:name => @name, :type => @type)
    end
  end
  
end
