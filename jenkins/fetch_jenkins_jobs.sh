#!/bin/bash

# This script retrieves Jenkins jobs configured on the server you specify
# and turns them into templates for BOSH


jobs_home=/var/vcap/store/jenkins_master/jobs

# takes one argument, the server to log in to
server=$1

if [[ ${server} == "" ]]
  then
      echo "Please specify a Jenkins server to connect to"
      exit 1
fi

job_names=`ssh -q vcap@${server} "ls -1 ${jobs_home}"`
if [[ $? == 0 ]]
  then true
  else
    echo "Error retriving job names"
fi

for job in ${job_names}
  do
    rsync -az vcap@${server}:${jobs_home}/${job}/config.xml ${job}.xml
done
