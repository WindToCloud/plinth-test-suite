#!/bin/bash


RAS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
. ${RAS_TOP_DIR}/../config/common_config
. ${RAS_TOP_DIR}/../config/common_lib

# Load module configuration library
. ${RAS_TOP_DIR}/config/ras_test_config
. ${RAS_TOP_DIR}/config/ras_test_lib

# Main operation function
# IN : N/A
# OUT: N/A
function main()
{
    echo "Begin to run RAS test!"

    cat ${RAS_TOP_DIR}/${TEST_CASE_DB_FILE} | while read line
    do         
        exec_script=`echo "${line}" | awk -F '\t' '{print $6}'`
        TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '\t' '{print $7}'`
        TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '\t' '{print $8}'`

        #Get the test title from testcase.table
	TEST_CASE_TITLE=`echo "${line}" | awk -F '\t' '{print $5}'`

        echo "CaseInfo "${TEST_CASE_TITLE}" "${exec_script}" "${TEST_CASE_FUNCTION_NAME}" "${TEST_CASE_FUNCTION_SWITCH}

        if [ x"${exec_script}" == x"" ]
        then
            MESSAGE="unimplemented automated test cases."
	    echo ${MESSAGE}
        else
            if [ ! -f "${RAS_TOP_DIR}/case_script/${exec_script}" ]
            then
                MESSAGE="FILE\tcase_script/${exec_script} execution script does not exist, please check!"
		echo ${MESSAGE}
            else
		echo "Begin to run test "${TEST_CASE_TITLE}
                source ${RAS_TOP_DIR}/case_script/${exec_script}
            fi
        fi
        echo -e "${line}\t${MESSAGE}" >> ${RAS_TOP_DIR}/${OUTPUT_TEST_DB_FILE}
	MESSAGE=""
	echo "Finish run test "${TEST_CASE_TITLE}
    done
}

#Output log file header
writeLogHeader

main

# clean exit so lava-test can trust the results
exit 0

