#!/bin/bash
echo "Enter User name:"
read -r USER
echo "Enter Password:"
read -r PASS
SERVICE_ENDPOINT="10.0.0.255:9999"
LOG_FILE="./task_runner.log"

# INPUT:
# Service listens on the same host, public IP. Accepts params by GET/POST.
# API token expires in 5mins.
# If task is not started, returns 404 code with "Not found" message.
# When task completed successfully - returns 200 code with some log output containing "RESULT: INTEGER" line.
# Otherwise - 500 code with log output and "ERROR: STRING" line.
# We need to start task, control its result and restart if failed or every 60 seconds. 
# The process must work on permanent basis in background.

# OBJECTIVE:
# 1) Universalize;
# 2) Optimize;
# 3) Secure.

while true; do
API_TOKEN=$(curl http://$SERVICE_ENDPOINT/apitoken?user=$USER&pass=$PASS)
TASK_STATUS=$(curl -s -i http://$SERVICE_ENDPOINT/task?api_token=$API_TOKEN |head -n1 |awk '{print $2}')
if [[ $TASK_STATUS -eq 404 ]];
then
        START_DATA=$(curl -s -i http://$SERVICE_ENDPOINT/task/start?api_token=$API_TOKEN)
	START_STATUS=$(echo $START_DATA |head -n1 |awk '{print $2}')
	case $START_STATUS in
	200)
		echo $START_DATA |grep "RESULT" > $LOG_FILE
		sleep 60
		;;
	500)
		echo $START_DATA |grep "ERROR" > $LOG_FILE
		;;
	*)
		echo "${START_CODE} is not recognized by system"
		;;
	esac
fi
done
