#!/bin/bash

#N :N/A
#OUT:N/A
function event_counts_judge()
{
    :> ${PERF_TOP_DIR}/data/log/event_judge.txt
    cat ${PERF_TOP_DIR}/data/log/counts.txt | while read mycount
    do
        if [ -n "$(echo $mycount | sed -n "/^[0-9]\+$/p")" ];then 
            if [ $mycount -ge 0 -a $mycount -le 65535 ];then
                echo "$mycount is normal"
                echo 1 > ${PERF_TOP_DIR}/data/log/event_judge.txt
            else
                echo "$mycount : the count is abmormal"
                echo 0 > ${PERF_TOP_DIR}/data/log/event_judge.txt
                break
            fi
        else 
            echo "$mycount : the count is not number!"
            echo 0 > ${PERF_TOP_DIR}/data/log/event_judge.txt
            break
        fi
    done
    if [ `cat ${PERF_TOP_DIR}/data/log/event_judge.txt | grep 0 | wc -l` -eq 0 ];then
        return 1
    else
        return 0
    fi
}

#N :N/A
#OUT:N/A
function fun_perf_list()
{
    :> ${PERF_TOP_DIR}/data/log/pmu_event.txt
    mflag=0
    perf list | grep $1| awk -F'[ \t]+' '{print $2}' > ${PERF_TOP_DIR}/data/log/pmu_event.txt
    msum=`cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep "$1" | wc -l`
    cat $msum $mflag
    if [ `cat /proc/cmdline | grep "acpi=force" | wc -l` -ne 1 ];then
        mflag=0
        MESSAGE="Fail\t No ACPI Support!"
    else
        if [ $msum -le 0 ];then
            mflag=0
            MESSAGE="Fail\t No $1 Perf Event Support!"
        else 
            mflag=1
        fi
    fi

    if [ $mflag -eq 1 ];then
        rand=$(awk 'NR==2 {print $1}' ${PERF_TOP_DIR}/data/log/pmu_event.txt)
        rand2=$(awk 'NR==16 {print $1}' ${PERF_TOP_DIR}/data/log/pmu_event.txt)
        perf stat -a -e $rand -e $rand2 -I 200 sleep 10s >& ${PERF_TOP_DIR}/data/log/perf_statu.log
        cat ${PERF_TOP_DIR}/data/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${PERF_TOP_DIR}/data/log/counts.txt
        event_counts_judge
        if [ $? -eq 1 ];then
            MESSAGE="Pass"
            echo ${MESSAGE}
        else
            MESSAGE="Fail\t Run $1 Event Err!"
        fi
    fi 
}

function hha_pmu_support_test()
{
    Test_Case_Title="Support HHA PMU events"

    fun_perf_list hha
}

function main()
{
    test_case_function_run
}

main
