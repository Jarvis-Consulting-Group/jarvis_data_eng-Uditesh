# Introduction
This Linux app is the Minimum Viable Product(MVP) that 
helps the Linux Cluster Administration(LCA) team to meet 
their business needs. Here a PostgreSQL instance is set to persevere 
all the data which is delivered using docker. This app 
records the hardware specification and resource usage information of multiple 
servers which are connected internally through a switch and communicate 
through internal IPv4 addresses. Moreover, the app utilizes a 
monitoring agent which runs and collects data every minute automatically
through a cron job. Then, the collected data is stored in the PostgreSQL 
database. This data is used to perform data analytics for future resource
planning purposes. Technologies used to build this app are Linux commands, 
Bash scripts, PostgreSQL, Docker, and Git.

# Quick Start

- start docker if docker server is not running

```
sudo systemctl status docker || sudo systemctl start docker
```

- Start a psql instance using psql_docker.sh

``` 
bash ./scripts/psql_docker.sh start|stop|create [db_username][db_password]

# Examples
bash ./scripts/psql_docker.sh start
bash ./scripts/psql_docker.sh stop
```

- Create tables using ddl.sql

```
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
```

- Insert hardware specs data into the DB using host_info.sh

```
bash ./scripts/host_info.sh psql_host psql_port database_name psql_username psql_password

#Example
bash ./scripts/host_info.sh "localhost" 5432 "host_agent" "postgres" "password"
```

- Insert hardware usage data into the DB using host_usage.sh

```
bash ./scripts/host_uasge.sh psql_host psql_port database_name psql_username psql_password

#Example
bash ./scripts/host_usage.sh "localhost" 5432 "host_agent" "postgres" "password"
```

- Crontab setup

```
bash> crontab -e

# Add to beginning
# It will run every minute
* * * * * bash /home/centos/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log

#Check if Crontab instance running
crontab -l
```

# Implementation

The Linux app is implemented by the use of various bash scripts
which query each server to record the hardware specification and 
resource usage information to perform the data analytics. Docker 
container is used to set the PostgreSQL instance which will store
the data into RDBMS every minute by using the crontab. 

## Architecture
<hr>

## Scripts
<hr>

- psql_docker.sh

```
It is used to check the status of the docker container and 
automate the process of creating, starting or 
stopping a docker container.
```
- host_info.sh

```
This script collects the  hardware specification and then 
insert the data into PostgreSQL database. All hardware specifications 
are static, so it will be executed only once.
```
- host_usage.sh

```
This script will collect the server usage information and then 
inserts the data into the PostgreSQL database.
```

- crontab

```
It deploys the monitoring app to each server and collects the 
data points every minute by running host_usage script. 
```

- queries.sql

```
This script will contain different SQL queries which can be 
used to analyze the stored data in the PostgreSQL database. By using
this script, LCA can manage the cluster better and do the planning for 
future recourses.
```

## Database Modeling
<hr>

- `host_info`

This table stores information about the hardware specifications of the host.

| Columns | Description                                  |
| ------- |----------------------------------------------|
| id | unique id for the host                       |
| hostname | Name of the host                             |
| cpu_number | Number of cores in the CPU                   |
| cpu_architecture | Architecture information of the CPU          |
| cpu_model | Model name of the CPU                        |
| cpu_mhz | CPU's clock speed in mhz unit                |
| l2_cache | Size of the secondary cache in KB            |
| timestamp | Date and time of when the data was collected |
| total_mem | Total amount of memory in the CPU            |

- `host_usage`

This table stores the information about resource usage data.

| Columns | Description                                  |
| ----- |----------------------------------------------|
| timestamp | Date and time of when the data was collected |
| host_id | unique id of the host                        |
| memory_free | Amount of free memory in the CPU             |
| cpu_idel | Percentage of time when CPU is idle          |
| cpu_kernel | Percentage of time when Kernel is running |
| disk_io | Number of disks currently in I/O process |
| disk_available | Root directory avaiable disk in MB |

# Test
<hr>

- Run ddl.sql to create the tables
```
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql
```

- Run the host_info.sh and host_usage.sh
```
bash ./scripts/host_info.sh "localhost" 5432 "host_agent" "postgres" "password"
bash ./scripts/host_usage.sh localhost 5432 host_agent postgres password
```

- Test the crontab jobs
```
bash> crontab -l
```

# Deployment

For the deployment of the Linux app, all the features were 
pushed to the features branches of the git. Then they were merged
to the develop and release to ensure the best practices of the
git is maintained without any conflict. Docker container is 
developed to set the PostgreSQL instance. Crontab is used to 
collect the resource usage information on every minute to understand
the report on the resources.

# Improvements

- Handle all the hardware updates
- Generate visual reports
- Detect the unsecure server by monitoring agent