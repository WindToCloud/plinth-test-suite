#!/bin/bash

PCIE_TOP_DIR=$( cd "`dirname $0`" ; pwd )
PCIE_CASE_DIR=${PCIE_TOP_DIR}/case_script

# Load the public configuration library
. ${PCIE_TOP_DIR}/../config/common_config
. ${PCIE_TOP_DIR}/../config/common_lib

# Load module configuration library
. ${PCIE_TOP_DIR}/config/pcie_test_config
. ${PCIE_TOP_DIR}/config/pcie_test_lib

# Main operation function
# IN : N/A
# OUT: N/A
function main()
{
    echo "Begin to run "$Module_Name" test"
    local MaxRow=$(sed -n '$=' "${PCIE_TOP_DIR}/${TEST_CASE_DB_FILE}")
    local RowNum=0

    while [ ${RowNum} -lt ${MaxRow} ]
    do
        let RowNum+=1
        local line=$(sed -n "${RowNum}p" "${PCIE_TOP_DIR}/${TEST_CASE_DB_FILE}")

        exec_script=`echo "${line}" | awk -F '\t' '{print $6}'`
        TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '\t' '{print $7}'`
        TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '\t' '{print $8}'`
                
        TEST_CASE_TITLE=`echo "${line}" | awk -F '\t' '{print $3}'`

        echo "TestCaseInfo "${TEST_CASE_TITLE}" "${exec_script}" "${TEST_CASE_FUNCTION_NAME}" "${TEST_CASE_FUNCTION_SWITCH} 

        if [ x"${exec_script}" == x"" ]
        then
            MESSAGE="unimplemented automated test cases."
        else
            if [ ! -f "${PCIE_CASE_DIR}/${exec_script}" ]
            then
                MESSAGE="FILE\tcase_script/${exec_script} execution script does not exist, please check."
            else
                if [ x"${TEST_CASE_FUNCTION_SWITCH}" == x"on"  ]
                then
                    echo "Begint to run test "${TEST_CASE_TITLE}
                    source ${PCIE_CASE_DIR}/${exec_script}
                else
                    echo "Skip the script!"
                fi
            fi
        fi
        echo -e "${line}${MESSAGE}" >> ${PCIE_TOP_DIR}/${OUTPUT_TEST_DB_FILE}
        MESSAGE=""
    done
}
check_ENV_OK_exists
if [ $? -eq 1 ]
then
    . ${SAS_TOP_DIR}/../pre_autotest/pre_main.sh
fi

#global_prepare_env
# Output log file header
writeLogHeader

main

# clean exit so lava-test can trust the results
exit 0

