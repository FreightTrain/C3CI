require_relative './jenkins/cli'
Dir.glob(File.dirname(__FILE__) + '/jenkins/tasks/*.rb', &method(:require))

module Jenkins
  class Configurator

    def initialize(options = {})
      @options = options
    end

    def configure
      tasks.each { |t| t.execute }
    end

    def tasks
      cli = Cli.new
      [
        ::Jenkins::Tasks::CreateTempDirectory.new(store_dir),
        ::Jenkins::Tasks::AddGithubSshHostKey.new(ssh_known_hosts_path),
        ::Jenkins::Tasks::DownloadCli.new,
        ::Jenkins::Tasks::InstallPlugins.new(
          {:plugins => Array(@options[:plugins]), :cli => cli}),
        ::Jenkins::Tasks::UpdateConfig.new(
          {:job_dir => job_dir, :store_dir => store_dir, :cli => cli}),
        ::Jenkins::Tasks::CreateJobs.new({:job_dir => job_dir, :cli => cli})
      ]
    end

    private

    def store_dir
      @options[:store_dir] || '/var/vcap/store/jenkins_master'
    end

    def job_dir
      @options[:job_dir] || '/var/vcap/jobs/jenkins_master'
    end

    def ssh_known_hosts_path
      @options[:known_hosts_path] || '/home/vcap/.ssh/known_hosts'
    end

  end
end
