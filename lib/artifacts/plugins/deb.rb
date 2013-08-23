# Deb Handler Plugin
require 'fileutils'
module HandlerPlugin::Deb
  include HandlerPlugin
  plugin_type "deb"
  def process(filename)
    # --TODO -- this whole thing is really messy, it is begging to be cleaned up via some erb templates ....
    # --TODO lucid/main/binary-amd64/gnupgdir need to be taken in as parameters somehow... hard coded for now.....

    dists = ["lucid","precise"]
    components = ["main"]
    gnupgdir = "/etc/artifacts/gnupg"

    # make nested dirs needed and copy new deb file into each of them
    FileUtils.mkdir_p ::File.join("pool","main")
    dists.each do |d|
      components.each do |c|
        FileUtils.mkdir_p ::File.join("dists",d,c,"binary-amd64")
      end
    end

    FileUtils.cp(filename,::File.join("pool","main",filename))
    FileUtils.rm(filename)

    ###### apt-ftparchive.conf #######
    f = ::File.new("apt-ftparchive.conf","w")
    f.write '
Dir {
  ArchiveDir "./";
};
Default {
  Packages::Extensions ".deb";
  Packages::Compress ". gzip bzip2";
  Contents::Compress "gzip bzip2";
};
TreeDefault {
  Directory "pool/main";
  Packages "$(DIST)/$(SECTION)/binary-$(ARCH)/Packages";
  Contents "$(DIST)/Contents-$(ARCH)";
};

'
    dists.each do |d|
      components.each do |c|
        f.write "
BinDirectory \"dists/#{d}/#{c}/binary-amd64\" {
  Packages \"dists/#{d}/#{c}/binary-amd64/Packages\";
  Contents \"dists/#{d}/Contents-amd64\";
};
"
      end
    end
    dists.each do |d|
      f.write "
Tree \"dists/#{d}\" {
  Sections \"#{components.join(' ')}\";
  Architectures \"amd64\";
};
"
    end
    f.close

    ###### [distname]-release.conf #######
    dists.each do |d|
      f = ::File.new("#{d}-release.conf","w")
      f.write "APT::FTPArchive::Release::Origin \"DebOrigin\";
  APT::FTPArchive::Release::Label \"Deb Label\";
  APT::FTPArchive::Release::Suite \"#{d}\";
  APT::FTPArchive::Release::Codename \"#{d}\";
  APT::FTPArchive::Release::Architectures \"amd64\";
  APT::FTPArchive::Release::Components \"#{components.join(' ')}\";
  APT::FTPArchive::Release::Description \"Deb Origin Repo\";
"
      f.close
    end

    ###### update-repo #######
    f = ::File.new("update-repo","w")
    f.write "#!/bin/sh
apt-ftparchive generate apt-ftparchive.conf
for i in *-release.conf; do
    DIST=`echo $i | sed s/-.*//`
    apt-ftparchive -c $i release dists/$DIST > dists/$DIST/Release
    gpg --homedir #{gnupgdir} --output dists/$DIST/Release.gpg --yes -ba dists/$DIST/Release
done
"
    f.chmod(0755)
    f.close

    `./update-repo`

    return {:type => 'deb', :description => 'Deb Artifact Handler'}
    # requires gnupg setup in /etc/gnupg
  end
end

