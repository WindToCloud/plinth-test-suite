#!/bin/bash


END_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
. ${END_TOP_DIR}/../config/common_config
. ${END_TOP_DIR}/../config/common_lib

check_ENV_OK_exists
if [ $? -eq 1 ]
then
    . ${END_TOP_DIR}/../pre_autotest/pre_main.sh
fi


lava_report "debug-test-1" fail "Linyunsheng" "fail	fuck "

lava_report "debug-test-2" fail "Linyunsheng" "fail	fuck fe"

lava_report "debug-test-3" fail "Linyunsheng" "fail	fuck ee"

# clean exit so lava-test can trust the results
