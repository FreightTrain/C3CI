require_relative 'bosh-mediator/lib/bosh_mediator_factory'

include ::BoshMediator::BoshMediatorFactory

namespace :cf do

  desc 'Upload and deploy the release to the BOSH director'
  task :upload_and_deploy_release, [:release_file, :manifest_file, :director_url, :release_dir, :stemcell_resource_uri, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin')
    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], args[:manifest_file], args[:release_dir])
    deploy_release(args, bosh_mediator) {
      bosh_mediator.upload_release(args[:release_file])
    }
  end

  private

  def deploy_release(args, bosh_mediator, &upload_command)
    stemcell_uri = if args[:stemcell_resource_uri]
      args[:stemcell_resource_uri]
    else
      'http://bosh-jenkins-artifacts.s3.amazonaws.com/bosh-stemcell/vsphere/bosh-stemcell-1269-vsphere-esxi-centos.tgz'
    end
    stemcell_name_and_manifest = bosh_mediator.upload_stemcell_to_director(stemcell_uri)
    bosh_mediator.set_manifest_stemcell_and_version(stemcell_name_and_manifest, args[:manifest_file])

    yield upload_command
    bosh_mediator.deploy
  end

end