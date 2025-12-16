#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

code="$WORKSPACE/$CODEBASE_DIR"


logInfoMessage "I'll lint tf code repository"
sleep $SLEEP_DURATION
logInfoMessage "Executing command"
logInfoMessage "Linting tf code repository"

cd $code/${CODE_PATH}
logInfoMessage "${code}/${CODE_PATH}"
output=`tflint -f ${FORMAT_ARG}`
logInfoMessage "${output}"

TASK_STATUS=$?
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
