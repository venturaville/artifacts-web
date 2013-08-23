# Deb Handler Plugin
require 'fileutils'

class Artifacts::Handler

  def settings_deb
    # --TODO -- this whole thing is really messy, it is begging to be cleaned up via some erb templates ....
    # --TODO lucid/main/binary-amd64/gnupgdir need to be taken in as parameters somehow... hard coded for now.....
    return {
      'dists' => ["lucid","precise"],
      'components' => ["main"],
      'arches' => ["amd64"],
      'gnupgdir' => "/etc/artifacts/gnupg"
    }
  end

  def rebuild_deb()
    ###### apt-ftparchive.conf #######
    f = ::File.new("apt-ftparchive.conf","w")
    f.write "Dir {\n  ArchiveDir \"./\";\n};\n"
    settings = settings_deb
    settings['dists'].each do |d|
      settings['components'].each do |c|
        settings['arches'].each do |a|
          f.write "BinDirectory \"dists/#{d}/#{c}/binary-#{a}\" {
  Packages \"dists/#{d}/#{c}/binary-#{a}/Packages\";
  Contents \"dists/#{d}/Contents-#{a}\";
};
"
        end
      end
    end
    settings['dists'].each do |d|
      settings['arches'].each do |a|
        f.write "Tree \"dists/#{d}\" {
    Sections \"#{settings['components'].join(' ')}\";
    Architectures \"#{a}\";
  };
"
      end
    end
    f.close

    ###### [distname]-release.conf #######
    settings['dists'].each do |d|
      settings['dists'].each do |a|
        f = ::File.new("#{d}-release.conf","w")
        f.write "APT::FTPArchive::Release::Origin \"DebOrigin\";
    APT::FTPArchive::Release::Label \"Deb Label\";
    APT::FTPArchive::Release::Suite \"#{d}\";
    APT::FTPArchive::Release::Codename \"#{d}\";
    APT::FTPArchive::Release::Architectures \"#{a}\";
    APT::FTPArchive::Release::Components \"#{settings['components'].join(' ')}\";
    APT::FTPArchive::Release::Description \"Deb Origin Repo\";
  "
        f.close
      end
    end

    ###### update-repo #######
    f = ::File.new("update-repo","w")
    f.write "#!/bin/sh
apt-ftparchive generate apt-ftparchive.conf
for i in *-release.conf; do
    DIST=`echo $i | sed s/-.*//`
    apt-ftparchive -c $i release dists/$DIST > dists/$DIST/Release
    gpg --homedir #{settings['gnupgdir']} --output dists/$DIST/Release.gpg -ba dists/$DIST/Release
done
"
    f.chmod(0755)
    f.close

    `./update-repo`

    return {:type => 'deb', :description => 'Deb Artifact Handler'}
    # requires gnupg setup in /etc/gnupg
  end

  def list_deb
    debs = []
    settings['dists'].each do |d|
      settings['components'].each do |c|
        settings['arches'].each do |a|
          begin
            debs += Dir.entries(::File.join("dists",d,c,"binary-#{a}")).select {|f| f.end_with? '.deb'}
          rescue
          end
        end
      end
    end
    return debs.uniq
  end

  def remove_deb(filename)
    settings = settings_deb()
    settings['dists'].each do |d|
      settings['components'].each do |c|
        settings['arches'].each do |a|
          FileUtils.rm(::File.join("dists",d,c,"binary-#{a}",filename))
        end
      end
    end
    return rebuild_deb()
  end

  def download_deb(filename)
    settings = settings_deb()
    settings['dists'].each do |d|
      settings['components'].each do |c|
        settings['arches'].each do |a|
          path = ::File.join("dists",d,c,"binary-#{a}",filename)
          if File.exist? path then
            return File.open(path,'r') # found a copy ...stop here and return a filehandle
          end
        end
      end
    end
    return nil # not found
  end

  def process_deb(filename)
    # make nested dirs needed and copy new deb file into each of them
    settings = settings_deb()
    settings['dists'].each do |d|
      settings['components'].each do |c|
        settings['arches'].each do |a|
          FileUtils.mkdir_p ::File.join("dists",d,c,"binary-#{a}")
          FileUtils.cp(filename,::File.join("dists",d,c,"binary-#{a}",filename))
        end
      end
    end
    FileUtils.rm(filename)
    return rebuild_deb()
  end
end

