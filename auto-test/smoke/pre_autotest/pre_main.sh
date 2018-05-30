#!/bin/bash


SAS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
. ${SAS_TOP_DIR}/../config/common_config
. ${SAS_TOP_DIR}/../config/common_lib

#check the image commit id 

commit_id=`cat /proc/version | awk -F' ' '{print $3}'`

echo "kernel commit ID is $commit_id"

lava_report "Prepare_cmd" "pass" ${commit_id} 

lava_report "Prepare_test" "pass" ${commit_id} 

# clean exit so lava-test can trust the results
exit 0
