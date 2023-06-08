#!/bin/bash

source  functions.sh
source  log-functions.sh
source  str-functions.sh
source  file-functions.sh
source  aws-functions.sh

code="$WORKSPACE/$CODEBASE_DIR"
echo "${code}/${CODE_PATH}"

logInfoMessage "I'll lint tf code repository"
sleep $SLEEP_DURATION
logInfoMessage "Executing command"
logInfoMessage "Linting tf code repository"

cd $code/${CODE_PATH}
output=`tflint -f ${FORMAT_ARG}`
echo "${output}"

