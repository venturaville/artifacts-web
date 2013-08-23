
require 'mongoid'
require 'artifacts/cli'

class Artifacts

  def self.configure!
    cli = Artifacts::CLI.new
    cli.parse_options
    cli.run
    ENV['RACK_ENV'] = Artifacts::Config[:environment]
    Mongoid.logger = nil
    Mongoid.load!(Artifacts::Config[:mongoid])
  end

  class Artifact
    include Mongoid::Document
    field :name, :type => String
    field :version, :type => String
    field :filename, :type => String
    belongs_to :group, :class_name => "Artifacts::Group"
  end
  
  class Group
    include Mongoid::Document
    field :name, :type => String
    field :method, :type => String
    validates_uniqueness_of :name
    has_many :artifact, :class_name => "Artifacts::Artifact"
  end

end
