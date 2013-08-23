Gem::Specification.new do |s|
  s.name = "artifacts-web"
  s.version = "0.1.0"
  s.email = "david-vv@nicklay.com"
  s.authors = ["David Nicklay"]
  s.summary = "Artifacts API"
  s.files = Dir['lib/**/*.rb'] + Dir['bin/*']
  s.description = "Artifacts Uploading API"
  s.bindir = "bin"
  s.executables = %w{ }
  %w{ sinatra mongoid unicorn SystemTimer bson_ext }.each do |d|
    s.add_dependency d
  end
end
