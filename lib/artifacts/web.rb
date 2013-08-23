require 'rubygems'
require 'yajl'
require 'sinatra'
require 'sinatra/json'
require 'sinatra/config_file'
require 'artifacts'
require 'artifacts/handler'
require 'bundler/setup'
require 'rack/uploads'
require 'yellin-client'
require 'pp'

use Rack::Uploads

class Artifacts::Web < Sinatra::Base
  register Sinatra::ConfigFile
  helpers Sinatra::JSON

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="artifacts")
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
  end

  def initialize()
  end
  
  configure do
    config_file '/etc/artifacts/artifacts.yml'
  end

  get '/v2/groups' do
    dirs = Dir.glob(File.join(settings.objects_dir,'*/metadata.json'))
    groups = []
    dirs.each do |d|
      md = JSON.parse(File.open("/var/www/artifacts/testing/metadata.json").read)
      groups << {
        'name' => File.basename(File.dirname(d)),
        'method' => md['type']
      }
    end
    json groups
  end

  get '/v2/groups/:group' do
    path = File.join(settings.objects_dir,params[:group],'metadata.json')
    if not File.exist? path
      response.status = 404
    else
      md = JSON.parse(File.open(path).read)
      md['method'] = md['type']
      md.delete 'type'
      json md
    end
  end

  delete '/v2/groups/:group' do
    dir = File.join(settings.objects_dir, params[:group])
    if not params[:group].to_s.any? then
      response.status = 412
    elsif not File.exist? dir
      response.status = 404
    else
      Artifacts::Group.delete(dir)
      response.status = 200
    end
  end

  put '/v2/groups/:group' do
    dir = File.join(settings.objects_dir, params[:group])
    type = params[:type] || params[:method] || 'file'
    group = Artifacts::Group.create(dir,params[:group],type)
    json group
  end

  post '/v2/groups/:group' do # - create/update a particular group
    dir = File.join(settings.objects_dir, params[:group])
    type = params[:type] || params[:method] || 'file'
    group = Artifacts::Group.create(dir, params[:group], type)
    json group
  end

  get '/v2/files/:group/:artifact' do
    dir = File.join(settings.objects_dir, params[:group])
    g = Artifacts::Group.new(dir)
    fh = g.download(g.type,g.name,params[:artifact])
    return fh # --TODO pass the filehandle back?
  end
  
  put '/v2/files/:group/:artifact' do
    dir = File.join(settings.objects_dir, params[:group])
    g = Artifacts::Group.new(dir)
    json g.process(g.type,g.name,env['rack.uploads'].first.filename)
  end
  
  delete '/v2/files/:group/:artifact' do
    @h = Artifacts::Handler.new(settings.objects_dir)
    dir = File.join(settings.objects_dir, params[:group])
    g = Artifacts::Group.new(dir)
    @h.remove(g.type,g.name,params[:artifact])
    response.status = 200
  end

  get '/v2/files/:group' do
    @h = Artifacts::Handler.new(settings.objects_dir)
    dir = File.join(settings.objects_dir, params[:group])
    g = Artifacts::Group.new(dir)
    json @h.list(g.type,g.name)
  end

  #assumes using rack-uploads
  post '/v2/files/:group/:artifact' do # - create/update an artifact in a group
    @h = Artifacts::Handler.new(settings.objects_dir)
    dir = File.join(settings.objects_dir, params[:group])
    group = Artifacts::Group.new(dir)
    env['rack.request.form_hash'].each_pair do |artifact,upload|
      file = File.join(dir, artifact)
      FileUtils.mv(upload[:tempfile].path(),file)
      @h.process(group.type,group.name,file)
    end
    response.status = 201
  end

end

if $0 == __FILE__ 
  Artifacts::Web.run!
end

