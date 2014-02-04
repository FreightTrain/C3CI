module Jenkins
  module Tasks
    class AddGithubSshHostKey

      def initialize(known_hosts_path)
        raise ArgumentError, 'Path to known_hosts must be specified' if known_hosts_path.to_s.empty?
        @known_hosts_path = known_hosts_path
      end

      def execute
        Dir.mkdir(ssh_config_dir, 0700) unless Dir.exists? ssh_config_dir
        unless ssh_host_key_present?('github.com')
          add_ssh_host_key("\ngithub.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==\n")
        end
      end

      def to_s
        'add_github_ssh_host_key'
      end

      private

      def ssh_known_hosts_path
        @known_hosts_path
      end

      def ssh_config_dir
        File.dirname(ssh_known_hosts_path)
      end

      def ssh_host_key_present?(hostname)
        File.readable?(ssh_known_hosts_path) and IO.readlines(ssh_known_hosts_path).any? do |host_key|
          host_key.start_with?(hostname)
        end
      end

      def add_ssh_host_key(host_key)
        File.open(ssh_known_hosts_path, 'a'){|f| f.write(host_key)}
      end

    end
  end
end
