#!/usr/bin/ruby 
require 'rubygems'
require 'yellin-client'
require 'sinatra'
require 'pp'
require 'json'
require 'yajl/json_gem'

#require 'mongoid'
gem 'mongoid', '~> 2.2'
  # There is a bug that mongoid 2.3.0 is tickling with ruby 1.8.7 patch  (force version 2.2.x)
  # see: http://www.datatravels.com/technotes/2010/02/24/ruby-187-patchlevel-inconsistency-super-called-out/

require 'artifacts'

require 'artifacts/handler'

class ArtifactsWeb < Sinatra::Base
  BASIC_REALM = 'IO Artifacts'

  set :show_exceptions, true

  configure do
    Artifacts.configure!
    set :yellin_server, Artifacts::Config[:yellin_server]
  end
  
  helpers do
    def json(data) 
      content_type :json
      body JSON.pretty_generate(data)
    end

    def disabled!
      throw(:halt, [405, "This API call has been disabled.\n"])
    end

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="#{BASIC_REALM}")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      if @auth = Yellin::Client::Rack.authorize(request, settings, 'artifacts') then
        return true
      else
        return false
      end
    end

  end
  
  before do
    protected!
    
    #merge in any json data we have received. allows us to recieve url encoded, query string, etc
    #XXX: this is not working???
    if %w{ PUT, POST }.include? request.request_method
      if request.body && request.content_length  && request.content_length.to_i > 0
        if request.media_type == 'application/json'
          #    request.body.rewind
          # params is nil here??
          #    params = params.merge(Yajl::Parser.parse(request.body.read) || {})
        end
      end
    end
  end
  
  get '/v1/data' do # - get a list of all artifacts
    json Artifacts::Artifact.where()
  end

  get '/v1/data/:group' do # - get a list of all artifacts in a group
    if g = Artifacts::Group.where(:name => params[:group]).first then
      json g.artifact.where()
    else
      error 404, "group not found"
    end
  end

  get '/v1/data/:group/:artifact' do # - get information about a single artifact
    if g = Artifacts::Group.where(:name => params[:group]).first then
      if a = g.artifact.where(:name => params[:artifact]) then
        json a
      else
        error 404, "artifact not found in given group"
      end
    else
      error 404, "group not found"
    end
  end

  put '/v1/data/:group/:artifact/:filename' do # - create/update an artifact in a group
	# --FIXME ... net/http or sinatra is not handling ?query parameters in the URI properly
	STDERR.puts params.inspect
	params[:version] = 1
    if g = Artifacts::Group.where(:name => params[:group]).first then
      if a = g.artifact.find_or_create_by(:name => params[:artifact]) then
        #f = File.new( File.join(Artifacts::Config[:objects_dir],params[:group],params[:artifact]), "w" )
        #f.write(request.body.read)
        request.body.rewind
        f = File.new( File.join(Artifacts::Config[:objects_dir],params[:group],params[:filename]), "w" )
        f.write(request.body.read)
        f.close
        a.version = params[:version]
        a.filename = params[:filename]
        a.save!
#       begin
          Dir.chdir( File.join(Artifacts::Config[:objects_dir],params[:group]) )
          ah = ArtifactHandler.new(g.method)
          res = ah.process(params[:filename])
          Dir.chdir( Artifacts::Config[:objects_dir] )
#        rescue
#          return -1
#        end
        #return json res
        
        json a
      else
        error 404, "artifact not found in given group"
      end
    else
      error 404, "group not found"
    end
  end

  delete '/v1/data/:group/:artifact' do # delete an artifact in a group
    if g = Artifacts::Group.where(:name => params[:group]).first then
      if a = g.artifact.where(:name => params[:artifact]).first then
        j = json a
        File.unlink( File.join(Artifacts::Config[:objects_dir],params[:group],params[:artifact]) )
        a.delete
        return j
      else
        error 404, "artifact not found in given group"
      end
    else
      error 404, "group not found"
    end
  end

  put '/v1/groups/:group' do # - create/update a particular group
    if g = Artifacts::Group.where(:name => params[:group]).first
    else
      g = Artifacts::Group.new(:name => params[:group])
    end
    pp g
    g.method = params[:method]
    g.save!
    begin
      Dir.mkdir( File.join(Artifacts::Config[:objects_dir],params[:group]) )
    rescue Errno::EEXIST
    end
    json g
  end

  get '/v1/groups' do # - get a list of all artifact groups
    g = Artifacts::Group.where()
    json g
  end

  get '/v1/groups/:group' do # - get a particular artifact group
    if g = Artifacts::Group.where(:name => params[:group]).first then
      json g
    else
      error 404, "group not found"
    end
  end

  delete '/v1/groups/:group' do # - delete a particular group
    j = nil
    if g = Artifacts::Group.where(:name => params[:group]).first then
      j = json g
      begin
        Dir.rmdir( File.join(Artifacts::Config[:objects_dir],params[:name]) )
      rescue
      end
      g.delete
    end
    return j
  end

end

if $0 == __FILE__ 
  ArtifactsWeb.run!
end

