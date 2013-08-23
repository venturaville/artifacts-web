require 'test/unit'
require 'pp'
require 'json'
require 'artifacts'
require 'artifacts/handler'

class TestPlugins < Test::Unit::TestCase
  def initialize(d)
    @basedir = '/tmp'
    @types = [
      'file',
      'deb',
      'rpm'#,
      #'gem'
    ]
    @h = Artifacts::Handler.new(@basedir)
    super
  end
  def test_create_groups()
    @types.each do |type|
      group = "#{type}test"
      groupdir = File.join(@basedir, group)
      group = Artifacts::Group.create(groupdir,group,type)
      assert_equal group.type,type
    end
  end
  def test_create_objects()
    @types.each do |type|
      group = "#{type}test"
      contents = "testing\n"
      filename = "test#{type}.#{type}"
      filepath = ::File.join(@basedir,group,filename)
      f = File.open(filepath,"w")
      f.write(contents)
      f.close()
      res = @h.process(type,group,filename)
      assert_equal res[:type], type
      nf = @h.download(type,group,filename)
      written_contents = nf.read()
      nf.close()
      assert_equal written_contents,contents
    end
  end
  def test_destroy_groups()
    @types.each do |type|
      group = "#{type}test"
      groupdir = File.join(@basedir, group)
      group = Artifacts::Group.delete(groupdir)
    end
  end
end
