require 'fileutils'
require 'yaml'

module BoshMediator
  class ManifestWriter

    def initialize(manifest_file, stemcell_name_and_version, spiff_dir = nil)
      @manifest_file = manifest_file
      @stemcell_name_and_version = stemcell_name_and_version
      @spiff_dir = spiff_dir
    end

    def parse_and_merge_file
      output_manifest = File.join(Dir.pwd, 'output-manifest.yml')

      Dir.mktmpdir do |dir|
        parsed_erb = set_manifest_stemcell_and_version
        output_erb = File.join(dir, 'output-erb.yml')

        File.open(output_erb, 'w') do |f|
          f.write(parsed_erb)
        end

        if @spiff_dir
          spiff_merge(output_erb, output_manifest)
        else
          FileUtils.cp(output_erb, output_manifest)
        end
      end

      output_manifest
    end

    private

    def set_manifest_stemcell_and_version
      unless [:name, :version].all?{|k| @stemcell_name_and_version[k]}
        raise 'The provided stemcell name and version was malformed'
      end
      unless File.exists? @manifest_file
        raise "The provided release manifest - #{@manifest_file} - does not exist"
      end
      sc_name = @stemcell_name_and_version[:name]
      sc_version = @stemcell_name_and_version[:version]

      puts "*** Updating stemcell name and version ***"
      puts "*** - on template manifest #{@manifest_file} ***"

      eruby = Erubis::Eruby.new(File.read(@manifest_file), :pattern=>'<!--% %-->')
      eruby.result(
        'stemcell_name' => sc_name,
        'stemcell_version' => sc_version
      )
    end

    def spiff_merge(erb_output_manifest, output_manifest)
      files = Dir.glob(File.join(@spiff_dir, "*")).join(' ')
      puts "*** Merging in Spiff templates ***"
      puts "*** - from #{@spiff_dir} ***"
      puts "*** - to #{output_manifest} ***"

      `spiff merge #{erb_output_manifest} #{files} > #{output_manifest}`
      raise "Spiff error" unless $?.success?
    end

  end
end