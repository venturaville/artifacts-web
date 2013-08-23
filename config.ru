require 'rack/parser'
require 'rack/uploads'
require 'lib/artifacts'
require 'lib/artifacts/web'
require 'lib/artifacts/handler'

module Rack
  class Uploads
    
  end
end

#use Rack::Parser
use Rack::Uploads

run Artifacts::Web
