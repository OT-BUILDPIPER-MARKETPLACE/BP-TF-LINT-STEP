FROM python:3.7-alpine

ADD https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip /usr/local/bin

RUN unzip /usr/local/bin/tflint_linux_amd64.zip -d /usr/local/bin

RUN addgroup -g 65522 buildpiper && \
    adduser -u 65522 -G buildpiper -D -h /home/buildpiper buildpiper && \
    mkdir -p \
      /app \
      /bp/data \
      /bp/execution_dir \
      /bp/workspace \
      /opt/buildpiper/shell-functions \
      /opt/buildpiper/data \
      /home/buildpiper/reports && \
    chown -R buildpiper:buildpiper /app /bp /opt /usr /home/buildpiper

RUN apk add --no-cache --upgrade bash
RUN apk add jq


COPY --chown=buildpiper:buildpiper build.sh /home/buildpiper/build.sh
COPY --chown=buildpiper:buildpiper BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

RUN chmod +x /home/buildpiper/build.sh && \
    chown -R buildpiper:buildpiper /bp/workspace && \
    chown -R buildpiper:buildpiper /home/buildpiper

ENV ACTIVITY_SUB_TASK_CODE BP-TFLINT-TASK
ENV FORMAT_ARG compact 
ENV CODE_PATH network_skeleton
ENV SLEEP_DURATION 5s

USER buildpiper

ENTRYPOINT [ "./build.sh" ]
