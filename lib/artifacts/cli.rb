require 'mixlib/cli'
require 'mixlib/config'
require 'artifacts/log'

class Artifacts
  class Config
    extend(Mixlib::Config)
    chef_config '/etc/chef/client.rb'
  end
  
  class CLI
    include Mixlib::CLI
  
    option :config_file,
    :short => "-c CONFIG",
    :long  => "--config CONFIG",
    :default => '/etc/artifacts/artifacts.rb',
    :description => "The configuration file to use"
    
    option :chef_config,
    :short => "-C CONFIG",
    :long  => "--chef-config CONFIG",
    :description => "config file for chef client"

    option :log_level,
    :short        => "-l LEVEL",
    :long         => "--log_level LEVEL",
    :description  => "Set the log level (debug, info, warn, error, fatal)",
    :proc         => lambda { |l| l.to_sym },
    :default => "warn".to_sym

    option :log_location,
    :short        => "-L LOGLOCATION",
    :long         => "--logfile LOGLOCATION",
    :description  => "Set the log file location, defaults to STDOUT - recommended for daemonizing",
    :proc         => nil
    
    def run(argv=ARGV)
      parse_options(argv)
      Artifacts::Config.from_file(config[:config_file])
      Artifacts::Config.merge!(config)
      Artifacts::Log.init(Artifacts::Config[:log_location])
      Artifacts::Log.level = Artifacts::Config[:log_level]
      Artifacts::Log.level = config[:log_level] if config[:log_level] != nil
    end
  end
end
