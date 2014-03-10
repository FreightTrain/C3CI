#!/bin/bash

echo -e "\nThis script must be run from within its directory\n"

# This script retrieves Jenkins jobs configured on the server you specify
# and turns them into templates for BOSH

LOCAL_CONFIG_DIR="./jobs/jenkins_master/templates/config/"
LOCAL_JOBS_DIR="./jobs/jenkins_master/templates/jenkins_jobs/"

REMOTE_JOBS_DIR="/var/vcap/store/jenkins_master/jobs"
REMOTE_CONFIG_DIR="/var/vcap/store/jenkins_master/"

downloadJenkinsJobs() 
{
    local server=$1
    local job_names=`ssh -q vcap@${server} "ls -1 ${REMOTE_JOBS_DIR}"`

    if [[ $? == 0 ]]
      then true
      else
        echo "Error retriving job names"
    fi

    for job in ${job_names}
    do
        rsync -az vcap@${server}:${REMOTE_JOBS_DIR}/${job}/config.xml ${LOCAL_JOBS_DIR}/${job}.xml
    done
}

replace()
{
    local pattern=$1
    local replacement=$2
    local file=$3

    perl -0777 -p -i -e "s|${pattern}|${replacement}|g" ${file}
 
}

# ------------------------------------------------------------------------------
# Download the Jenkins config file and replace variables with properties from the 
# Jenkins bosh release
#
downloadJenkinsConfig() 
{
    local server="$1"
    local jenkinsConfigTemplate="${LOCAL_CONFIG_DIR}/config.xml.erb"

    rsync -az vcap@${server}:${REMOTE_CONFIG_DIR}/hudson.tasks.Maven.xml "${LOCAL_CONFIG_DIR}/hudson.tasks.Maven.xml"
    rsync -az vcap@${server}:${REMOTE_CONFIG_DIR}/config.xml ${jenkinsConfigTemplate}
    
    replace  "<string>AWS_ACCESS_ID</string>.*\n[^<]*<string>[^<]*</string>" \
             "<string>AWS_ACCESS_ID</string>\n          <string><%= p('amazon.accesskey') %></string>" \
             ${jenkinsConfigTemplate}

    replace  "<string>AWS_SECRET_KEY</string>.*\n[^<]*<string>[^<]*</string>" \
             "<string>AWS_SECRET_KEY</string>\n          <string><%= p('amazon.secretkey') %></string>" \
             ${jenkinsConfigTemplate}

    replace  "<string>BOSH_MICRO_IP</string>.*\n[^<]*<string>[^<]*</string>" \
             "<string>BOSH_MICRO_IP</string>\n          <string><%= p('bosh.micro_ip') %></string>" \
             ${jenkinsConfigTemplate}

    replace  "<string>CONFIG_REPO</string>.*\n[^<]*<string>[^<]*</string>" \
             "<string>CONFIG_REPO</string>\n          <string><%= p('jenkins_jobs.config_git_repository.giturl') %></string>" \
             ${jenkinsConfigTemplate}

    replace  "<string>CONFIG_REPO_BRANCH</string>.*\n[^<]*<string>[^<]*</string>" \
             "<string>CONFIG_REPO_BRANCH</string>\n          <string><%= p('jenkins_jobs.config_git_repository.branch') %></string>" \
             ${jenkinsConfigTemplate}

    replace  "<string>INFRASTRUCTURE_DIR</string>.*\n[^<]*<string>[^<]*</string>" \
             "<string>INFRASTRUCTURE_DIR</string>\n          <string><%= p('jenkins_jobs.infrastructure_directory') %></string>" \
             ${jenkinsConfigTemplate}
}

main()
{
    # Takes two args, the server to log in to and the mode to run in
    local server=$1
    local mode=$2

    if [[ ${server} == "" ]]
    then
        echo "Please specify a Jenkins server to connect to"
        exit 1
    fi

    if [[ ${mode} == "config" ]]
    then
        echo "Downloading Jenkins config.xml"
        downloadJenkinsConfig ${server}
    else
        echo "Downloading Jenkins jobs"
        downloadJenkinsJobs ${server}
    fi
}

main $@
