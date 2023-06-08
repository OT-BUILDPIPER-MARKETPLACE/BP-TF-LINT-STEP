FROM python:3.7-alpine

ADD https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip /usr/local/bin

RUN unzip /usr/local/bin/tflint_linux_amd64.zip -d /usr/local/bin
USER root
RUN apk add --no-cache --upgrade bash
RUN apk add jq
COPY build.sh .
COPY BP-BASE-SHELL-STEPS .
RUN chmod +x build.sh
ENV ACTIVITY_SUB_TASK_CODE BP-TFLINT-TASK
ENV FORMAT_ARG compact 
ENV CODE_PATH network_skeleton
ENV SLEEP_DURATION 5s
ENTRYPOINT [ "./build.sh" ]
