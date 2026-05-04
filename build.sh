#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

code="$WORKSPACE/$CODEBASE_DIR"

# 1. Initialization Phase
logInfoMessage "> Initiating Terraform linting process..."
logInfoMessage "> Scan target: ${code}/${CODE_PATH}"
logInfoMessage "> Format: ${FORMAT_ARG}"

sleep $SLEEP_DURATION

add_event "INITIALIZATION" "Successful" \
    "Terraform lint initialization completed" \
    "Target: ${code}/${CODE_PATH}"

# 2. Execution Phase
cd $code/${CODE_PATH} || {
    logErrorMessage "> Cannot cd into ${code}/${CODE_PATH}"
    add_event "DIRECTORY_ACCESS" "Failed" \
        "Failed to access target directory" \
        "Directory: ${code}/${CODE_PATH}"
    saveTaskStatus 1 ${ACTIVITY_SUB_TASK_CODE}
    exit 1
}

add_event "DIRECTORY_ACCESS" "Successful" \
    "Target directory accessed" \
    "Directory: ${code}/${CODE_PATH}"

logInfoMessage "> Executing tflint in working directory: ${code}/${CODE_PATH}"

add_event "TFLINT_INITIATION" "Successful" \
    "tflint scan started" \
    "Format: ${FORMAT_ARG}"

output=$(tflint -f ${FORMAT_ARG})
TASK_STATUS=$?

logInfoMessage "> tflint exit code: ${TASK_STATUS}"
logInfoMessage "> tflint execution output: ${output}"

# parse issue count from output
ISSUE_COUNT=$(echo "$output" | grep -c "Warning\|Error" || true)

# print summary table
echo ""
echo "> TFLint Scan Summary"
printf '+%-25s+%-40s+\n' '-------------------------' '----------------------------------------'
printf '| %-23s | %-38s |\n' "Parameter" "Value"
printf '+%-25s+%-40s+\n' '-------------------------' '----------------------------------------'
printf '| %-23s | %-38s |\n' "Scan Path" "${code}/${CODE_PATH}"
printf '+%-25s+%-40s+\n' '-------------------------' '----------------------------------------'
printf '| %-23s | %-38s |\n' "Format" "${FORMAT_ARG}"
printf '+%-25s+%-40s+\n' '-------------------------' '----------------------------------------'
printf '| %-23s | %-38s |\n' "Issues Found" "${ISSUE_COUNT}"
printf '+%-25s+%-40s+\n' '-------------------------' '----------------------------------------'
echo ""

# print issues table if any
if [ -n "$output" ]; then
    echo "> TFLint Output:"
    printf '+%-90s+\n' '------------------------------------------------------------------------------------------'
    printf '| %-88s |\n' "Details"
    printf '+%-90s+\n' '------------------------------------------------------------------------------------------'
    while IFS= read -r line; do
        printf '| %-88s |\n' "${line:0:88}"
    done <<< "$output"
    printf '+%-90s+\n' '------------------------------------------------------------------------------------------'
    echo ""
fi

# 3. Validation and Result Phase
if [ $TASK_STATUS -eq 0 ]; then
    logInfoMessage "> Terraform linting completed successfully - No issues found"
    logInfoMessage "> Congratulations tf succeeded!!!"
    add_event "TFLINT_SUCCESS" "Successful" \
        "Terraform code passed all linting checks" \
        "Format: ${FORMAT_ARG} | Issues: ${ISSUE_COUNT}"
else
    logErrorMessage "> Terraform linting failed - Issues detected in the code"
    add_event "TFLINT_FAILED" "Failed" \
        "Terraform code failed linting checks" \
        "Format: ${FORMAT_ARG} | Issues: ${ISSUE_COUNT} | Review logs for details"
fi

# Save the final task status
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}

TASK_LABEL=$( [ $TASK_STATUS -eq 0 ] && echo "Success" || echo "Failure" )
logInfoMessage "> Task completed with status: ${TASK_LABEL}"