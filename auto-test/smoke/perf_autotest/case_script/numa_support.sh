#!/bin/bash

#IN :N/A
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

#IN :N/A
#out:N/A
function mode_numa_support()
{
    :> ${PERF_TOP_DIR}/data/log/pmu_event.txt
    :> ${PERF_TOP_DIR}/data/log/counts.txt
    perf list | grep $1 | awk -F'[ \t]+' '{print $2}' > ${PERF_TOP_DIR}/data/log/pmu_event.txt
    msum=`cat ${PERF_TOP_DIR}/data/log/pmu_event.txt | grep "$1" | wc -l`
    if [ $msum -le 0 ];then
        MESSAGE="Fail\t No $1 Event Support!"
	echo 0 >> ${PERF_TOP_DIR}/data/log/numa_support.txt
    else
        rand=$(awk 'NR==2 {print $1}' ${PERF_TOP_DIR}/data/log/pmu_event.txt)
        rand2=$(awk 'NR==16 {print $1}' ${PERF_TOP_DIR}/data/log/pmu_event.txt)
        perf stat -C $NUMA_CPU -A -e $rand -e $rand2 -I 200 sleep 10s >& ${PERF_TOP_DIR}/data/log/perf_statu.log
        cat ${PERF_TOP_DIR}/data/log/perf_statu.log | awk -F '[ \t]+'  '{print $4}' | sed 's/counts//g' | grep -v "^$" > ${PERF_TOP_DIR}/data/log/counts.txt
        event_counts_judge
        if [ $? -eq 1 ];then
            echo 1 >> ${PERF_TOP_DIR}/data/log/numa_support.txt
        else
            echo 0 >> ${PERF_TOP_DIR}/data/log/numa_support.txt
        fi
    fi 
}
#IN :N/A
#OUT:N/A
function numa_support_test()
{
    Test_Case_Title="NUMA support"
    :> ${PERF_TOP_DIR}/data/log/numa_support.txt
    mode_numa_support l3c
    mode_numa_support ddrc
    mode_numa_support hha
    if [ `cat ${PERF_TOP_DIR}/data/log/numa_support.txt | grep 0 | wc -l` -eq 0 ];then
        MESSAGE="Pass"
    else
        MESSAGE="Fail\t numa support have some mode err!"
    fi
}

function main()
{
    test_case_function_run
}

main
