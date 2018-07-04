#!/bin/bash


RAS_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
if [ x"$COM" = x"" ];then
    . ${RAS_TOP_DIR}/../config/common_config
    . ${RAS_TOP_DIR}/../config/common_lib
fi

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
        exec_script=`echo "${line}" | awk -F '|' '{print $6}'`
        TEST_CASE_FUNCTION_NAME=`echo "${line}" | awk -F '|' '{print $7}'`
        TEST_CASE_FUNCTION_SWITCH=`echo "${line}" | awk -F '|' '{print $8}'`

        #Get the test title from testcase.table
    	TEST_CASE_TITLE=`echo "${line}" | awk -F '|' '{print $2}'`

    	Tester=`echo "${line}" | awk -F '|' '{print $5}'`
        DateTime=`date "+%G-%m-%d %H:%M:%S"`
        if [ x"${DEVELOPER}" == x"" ]
        then
            Developer=`echo "${line}" | awk -F '|' '{print $4}'`
        else
            Developer=${DEVELOPER}
        fi
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
	MESSAGE=""
	echo "<<----------------------------------------->>"
	echo "Finish to run RAS test!"
	echo -e "\033[32mThe test report path locate at \033[0m\033[35m${PLINTH_TEST_WORKSPACE}/${Module}/${Date}/${NowTime}/ \033[0m"
    done
}

#mkdir the log path
InitDirectoryName

#mkdir test path
MkdirPath

#Output CI log header
LogHeader

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

