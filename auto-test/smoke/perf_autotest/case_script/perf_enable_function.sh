#!/bin/bash

#N :N/A
#OUT:N/A

function fun_perf_list()
{
    :> ${PERF_TOP_DIR}/data/log/pmu_event.txt
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${PERF_TOP_DIR}/data/log/pmu_event.txt
    msum=$(cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep $1 | wc -l)
    acc="hisi_"
    enda="_start_counters"
    endb="_stop_counters"
    alla=${acc}$1${enda}
    allb=${acc}$1${endb}
    if [[ $msum -le 0 ]];then
        MESSAGE="Fail\t No $1 Perf Support Event!"
        return
    else 
        rand=$(awk 'NR==2 {print $1}' ${PERF_TOP_DIR}/data/log/pmu_event.txt)
        output=`dmesg -c`
        perf stat -a -e $rand -I 200 sleep 10s
        dmesg > ${PERF_TOP_DIR}/data/log/dmesg.txt
        en_flag=`cat ${PERF_TOP_DIR}/data/log/dmesg.txt | grep ${alla} | wc -l`
        dis_flag=`cat ${PERF_TOP_DIR}/data/log/dmesg.txt | grep ${allb} | wc -l`
        if [ $en_flag -lt 1 -a $dis_flag -lt 1 ];then 
            MESSAGE="Fail\t $1 Event disable/enable Function Test Fail!"
        else
            MESSAGE="Pass"
        fi
    fi
}

function l3c_perf_enable_function()
{
    Test_Case_Title="L3C perf disable/enable function test"

    fun_perf_list l3c
}

function hha_perf_enable_function()
{
    Test_Case_Title="HHA perf disable/enable function test"

    fun_perf_list hha
}

function main()
{
    test_case_function_run
}

main
