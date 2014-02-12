# C3CI

This repo contains a BOSH deployed Jenkins with jobs that can automate a CloudFoundry deployment and verify its functionality.

Also supplied is a BOSH deployed VPN server.

In order to have a fully functional deployment you will need to:

1. Deploy a Jenkins customised for your environment
2. Have a customised CF manifest for your environment available to Jenkins

## Using BOSH mediator

BOSH mediator is invoked through a rake task, which takes the following arguments:

* release_file - yaml file containing BOSH final release information
* manifest_file - BOSH deployment manifest
* director_url - Full BOSH director URL, e.g. https://10.0.0.10:25555
* release_dir - Path to your BOSH release
* stemcell_resource_uri - URL to the stemcell
* username - (Optional) BOSH director username, default 'admin'
* password - (Optional) BOSH director password, default 'admin'
