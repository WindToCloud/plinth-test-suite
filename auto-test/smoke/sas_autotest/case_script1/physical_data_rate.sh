#!/bin/bash

# Disk negotiated link rate query
# IN : N/A
# OUT: N/A
function disk_negotiated_link_rate_query()
{
    Test_Case_Title="disk_negotiated_link_rate_query"

    echo "Begin to run disk_negotiated_link_rate_query function"

    local dir_info
    dir_info=`ls ${PHY_FILE_PATH}`

    for dir in ${dir_info}
    do
        num=`echo "${dir}" | awk -F ":" '{print $NF}'`
        type=`cat ${PHY_FILE_PATH}/${dir}/target_port_protocols`
        if [ x"${type}" == x"none" -o ${num} -gt ${EFFECTIVE_PHY_NUM} ]
        then
            continue
        fi

        if [ x"${type}" == x"ssp" -o x"${type}" == x"sata" ]
        then
            rate_value=`cat ${PHY_FILE_PATH}/${dir}/negotiated_linkrate | awk -F ' ' '{print $1}'`
            BRate=1
            rate_info=`echo $DISK_NEGOTIATED_LINKRATE_VALUE | sed 's/|/ /g'`
            for rate in ${rate_info}
            do
                bool=`echo "${rate_value} ${rate}"|awk '{if($1=$2){print 0}else{print 1}}'`
                if [ ${bool} -eq 0 ]
                then
                    BRate=0
                    break
                fi
            done
            if [ $BRate -eq 1 ]
            then
                MESSAGE="FAIL\t\"${dir}\" negotiated link rate query ERROR."
                return 1
            fi
        fi
    done
    MESSAGE="PASS"
    echo ${MESSAGE}
}

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
