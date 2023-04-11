#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check for all 5 parameters
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# CPU specs
specs=`lscpu`

# Save machine statistics in MB and current machine hostname to variables
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

#Retrieve hardware specification variables
#xargs is a trick to trim leading and trailing white spaces
cpu_number=$(echo "$specs" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$specs" | egrep "^Architecture:" | awk '{print $2}' | xargs)
# {$1=$2=""; print $0} will print all columns except first two
cpu_model=$(echo "$specs" | egrep "^Model name:" | awk '{$1=$2=""; print $0}' | xargs)
cpu_mhz=$(echo "$specs" | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$specs" | egrep "^L2 cache:" | awk '{print $3}' | xargs)
timestamp=$(date "+%F %T")
total_mem=$(echo "$vmstat_mb" | tail -1 | awk '{print $4}')

# Insert Data into host_info table
insert_stmt="INSERT INTO host_info (
                  hostname, cpu_number, cpu_architecture, cpu_model,
                  cpu_mhz, l2_cache, timestamp, total_mem
                  )
                  VALUES(
                  '$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model',
                  '$cpu_mhz', '${l2_cache%%K}', '$timestamp', '$total_mem'
                  )";

#set up env var for psql cmd
export PGPASSWORD=$psql_password

#Insert data into a database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?