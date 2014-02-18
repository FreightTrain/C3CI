#!/bin/bash

# Setup required paths
# Run process as vcap (by default monit will use root)

BASE_DIR=/var/vcap
JOB_DIR=$BASE_DIR/jobs/redis
PACKAGE_DIR=$BASE_DIR/packages/redis
LOG_DIR="$BASE_DIR/sys/log/redis"
PID_DIR="$BASE_DIR/sys/run/redis"
STORE_DIR="$BASE_DIR/store/redis"

PID_FILE="${PID_DIR}/redis.pid"
USER=vcap

for DIR in $JOB_DIR $LOG_DIR $PID_DIR $STORE_DIR
do
  mkdir -p $DIR
  chown ${USER}:${USER} $DIR
done

case $1 in

  start)
    # The convention for BOSH is to send stdout and std err to the files shown below
    chpst -u $USER:$USER $PACKAGE_DIR/bin/redis-server $JOB_DIR/conf/redis.conf 1> $LOG_DIR/redis.stdout 2> $LOG_DIR/redis.stderr
    ;;

  stop)

  # There is no nice stop command for the redis-server process
  kill `cat ${PID_FILE}`
  rm -f $PID_FILE

    ;;

  *)
    echo "Usage: redis_ctl {start|stop}"

    ;;

esac
