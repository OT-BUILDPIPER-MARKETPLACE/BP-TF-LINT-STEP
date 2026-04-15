#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

code="$WORKSPACE/$CODEBASE_DIR"

# 1. Initialization Phase
logInfoMessage "Initiating Terraform linting process..."

add_event "TFLINT INITIATED" "InProgress" \
          "Starting Terraform code analysis" \
          "Target Directory: $code/${CODE_PATH}"

sleep $SLEEP_DURATION

# 2. Execution Phase
cd $code/${CODE_PATH}
logInfoMessage "Executing tflint in working directory: ${code}/${CODE_PATH}"

output=`tflint -f ${FORMAT_ARG}`
TASK_STATUS=$?

logInfoMessage "tflint execution output: ${output}"

# 3. Validation and Result Phase
if [ $TASK_STATUS -eq 0 ]; then
  logInfoMessage "Terraform linting completed successfully. No issues found."
  
  add_event "TFLINT COMPLETE" "Successful" \
            "Terraform code passed all linting checks" \
            "Format Output: ${FORMAT_ARG}"
else
  logErrorMessage "Terraform linting failed. Issues detected in the code."
  
  add_event "TFLINT COMPLETE" "Failed" \
            "Terraform code failed linting checks" \
            "Action: Review execution logs for details"
fi

# Save the final task status
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}