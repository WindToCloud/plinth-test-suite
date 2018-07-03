#!/bin/bash

#IN :N/A
#OUT:N/A

function fun_perf_list()
{
    :> ${PERF_TOP_DIR}/data/log/pmu_event.txt
    :> ${PERF_TOP_DIR}/data/log/judgement.txt
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${PERF_TOP_DIR}/data/log/pmu_event.txt
    msum=$(cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep $1 | wc -l)
    if [[ $msum -le 0 ]];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
        return
    else 
        rand=$(awk 'NR==2 {print $1}' ${PERF_TOP_DIR}/data/log/pmu_event.txt)
        output=`dmesg -c`
        perf stat -a -e $rand -I 200 sleep 10s
        dmesg | grep "PERF_WRITE_TEST:" > ${PERF_TOP_DIR}/data/log/write_dmesg.txt
        cat ${PERF_TOP_DIR}/data/log/write_dmesg.txt | awk -n '{print $NF}' > ${PERF_TOP_DIR}/data/log/write_data.txt
        if [ `cat ${PERF_TOP_DIR}/data/log/write_dmesg.txt | grep -i "PERF_WRITE_TEST:" | wc -l` -lt 1 ];then 
            MESSAGE="Fail\t $1 Event WRITE Function Test Fail!"
        else
            tmp=0
            flag=0
            cat ${PERF_TOP_DIR}/data/log/write_data.txt | while read mydata
            do
                if [ $flag -eq 0 ];then
                    tmp=$mydata
                    flag=1
                    echo $tmp $flag
                else
                    if [ $((16#$mydata)) -ge $((16#$tmp)) ];then
                        echo 1 > ${PERF_TOP_DIR}/data/log/judgement.txt
                    else
                        echo 0 > ${PERF_TOP_DIR}/data/log/judgement.txt
                    fi
                fi
                tmp=$mydata
            done
            if [ `cat ${PERF_TOP_DIR}/data/log/judgement.txt | grep 0 | wc -l` -eq 1 ];then
                MESSAGE="Fail\t $1 Event WRITE Function Test Fail,data error!"
            else
                MESSAGE="Pass"
            fi
        fi
    fi
}

function l3c_perf_write_function()
{
    Test_Case_Title="L3C perf write function test"

    fun_perf_list l3c
}

function ddrc_perf_write_function()
{
    Test_Case_Title="DDRC perf write function test"

    fun_perf_list ddrc
}

function hha_perf_write_function()
{
    Test_Case_Title="HHA perf write function test"

    fun_perf_list hha
}

function main()
{
    test_case_function_run
}

main
