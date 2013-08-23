require 'logger'
require 'mixlib/log'

class Artifacts
  class Log
    extend Mixlib::Log

    # Force initialization of the primary log device (@logger)
    init

    class Formatter
      def self.show_time=(*args)
        Mixlib::Log::Formatter.show_time = *args
      end
    end
  end
end

