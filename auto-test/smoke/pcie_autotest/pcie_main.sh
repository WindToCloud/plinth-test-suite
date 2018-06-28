#!/bin/bash

PCIE_TOP_DIR=$( cd "`dirname $0`" ; pwd )
PCIE_CASE_DIR=${PCIE_TOP_DIR}/case_script

# Load the public configuration library
if [ x"$COM" = x"" ];then
    . ${HNS_TOP_DIR}/../config/common_config
    . ${HNS_TOP_DIR}/../config/common_lib
fi

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

        exec_script=`echo "${line}" | awk -F '|' '{print $6}'`
        TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '|' '{print $7}'`
        TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '|' '{print $8}'`
        TEST_CASE_TITLE=`echo "${line}" | awk -F '|' '{print $2}'`
        Tester=`echo "${line}" | awk -F '|' '{print $5}'`
        DateTime=`date "+%G-%m-%d %H:%M:%S"`
        if [ x"${DEVELOPER}" == x"" ]
        then
            Developer=`echo "${line}" | awk -F '|' '{print $4}'`
        else
            Developer=${DEVELOPER}
        fi

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
    done
    echo "<<----------------------------------------->>"
    echo "Finish to run PCIE test!"
    echo -e "\033[32mThe test report path locate at \033[0m\033[35m${PLINTH_TEST_WORKSPACE}/${Module}/${Date}/${NowTime}/ \033[0m"
}
check_ENV_OK_exists
if [ $? -eq 1 ]
then
    . ${PCIE_TOP_DIR}/../pre_autotest/pre_main.sh
fi

#mkdir the log path
InitDirectoryName

#mkdir test path
MkdirPath

#Output CI log header
LogHeader
#global_prepare_env

if [ x"$g_server_ip" == x"" ];then
	g_get_default_sip
    if [ $? -eq 0 ];then
        echo "Get the default server ip!"
    else
        echo "MAC is not including in pre-cfg list, not get the default server ip!" 
        exit 1
    fi
fi

echo "Get the server ip as $g_server_ip"

LOCAL_IP=$g_server_ip
#LOCAL_IP="192.168.50.152"
echo ${LOCAL_IP}

#init_client_ip
if [ x"$g_client_ip" = x"" ];then
	BACK_IP=${sip_cip[$g_server_ip]}
else
        BACK_IP=$g_client_ip
fi

#BACK_IP="192.168.50.153"
echo "The client ip is "${BACK_IP}

#check connect between server and client
ping $BACK_IP -c 5

if [ $? -eq 0 ];then
	echo "Connect between server and client is OK!"
else
	echo "Client is not good!"
fi

#set passwd
setTrustRelation

main

# clean exit so lava-test can trust the results
exit 0

