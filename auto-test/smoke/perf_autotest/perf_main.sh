#!/bin/bash


PERF_TOP_DIR=$(cd "`dirname $0`" ; pwd)

# Load the public configuration library
if [ x"$COM" = x"" ];then
	. ${PERF_TOP_DIR}/../config/common_config
	. ${PERF_TOP_DIR}/../config/common_lib
fi

# Load module configuration library
. ${PERF_TOP_DIR}/config/perf_test_config
. ${PERF_TOP_DIR}/config/perf_test_lib

# Main operation function
# IN : N/A
# OUT: N/A
function main()
{
    echo "Begin to run PERF test!"

    cat ${PERF_TOP_DIR}/${TEST_CASE_DB_FILE} | while read line
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
            if [ ! -f "${PERF_TOP_DIR}/case_script/${exec_script}" ]
            then
                MESSAGE="FILE\tcase_script/${exec_script} execution script does not exist, please check."
		echo ${MESSAGE}
            else
		echo "Begin to run test "${TEST_CASE_TITLE}
                source ${PERF_TOP_DIR}/case_script/${exec_script}
            fi
        fi
	echo "<<----------------------------------------->>"
	echo "Finish to run PERF test!"
	echo -e "\033[32mThe test report path locate at \033[0m\033[35m${PLINTH_TEST_WORKSPACE}/${Module}/${Date}/${NowTime}/ \033[0m"
    done
}

#install perf
InstallPerf

#mkdir the log path
InitDirectoryName

#mkdir test path
MkdirPath

#Output CI log header
LogHeader

main

# clean exit so lava-test can trust the results
exit 0

