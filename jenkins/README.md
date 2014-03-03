# BOSH deployed Jenkins for CloudFoundry CI

Based on the Jenkins release by Dr Nic.

Includes jobs to deploy CloudFoundry in an automated way. 

Additional features include automatic install of plugins from manifest, automatic Jenkins server configuration, automatic Jenkins job configuration with bundled jobs and job accessable environmental variables for ease of use.


## OVFTools

OVFtools is required if you want to be able to build VSphere stemcells on your Jenkins box. 

However as we are prohibited from distributing the OVFTools binary you will need to go and [download it from VMware](https://my.vmware.com/group/vmware/details?downloadGroup=OVFTOOL350&productId=353).

After downloading you will need to accept the EULA and perform the following steps, on a linux 64bit system, to package the OVFtools to be installed by Bosh. 


    $ chmod +x VMware-ovftool-*.x86_64.bundle
    $ sudo ./VMware-ovftool-*.x86_64.bundle
    
    Accept EULAS & install with defaults
    
    $ cd /usr/lib/
    $ tar -cvzf /tmp/ovftool.tar.gz vmware-ovftool
    $ cp /tmp/ovftool.tar.gz <jenkins_release>/blobs/

These steps will be necessary as the blob is not stored in the C3CI blob-store.