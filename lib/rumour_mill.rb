module RumourMill

  def self.project_root
    @project_root ||= Pathname.new(File.expand_path('../../../',__FILE__)).freeze
  end

  # if building a new package, create a new version, else read from VERSION file
  proposed_new_version = "0.0." + ENV.fetch('BUILD_NUMBER', '0')
  version_file = RumourMill.project_root.join('VERSION')
  VERSION = File.exists?(version_file) ? File.read(version_file).chomp : proposed_new_version

end
