#!/bin/bash


# fio tool to read and write disk.
# IN  : N/A
# OUT : N/A
function FIO_IO_read_write()
{
    Test_Case_Title="FIO_IO_read_write"

    # Get all disk partition information
    get_all_disk_part

    # Generate FIO configuration file
    fio_config
    echo "Begin to run FIO_IO_RW"
    IO_read_write
    [ $? -eq 1 ] && MESSAGE="FAIL\tFIO tool read and write disk failure." || MESSAGE="PASS"
}

function main()
{
    # call the implementation of the automation use cases
    test_case_function_run
}

main
