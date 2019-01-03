FROM gcr.io/apigee-microgateway/edgemicro:latest
USER root
RUN apk update && \
    apk upgrade && \
    apk add zip && \
    mkdir /opt/apigee/customplugins && \
    chown apigee:apigee /opt/apigee/customplugins
COPY plugins /opt/apigee/plugins/
# RUN su - apigee -c "unzip /opt/apigee/customplugins/plugins.zip -d /opt/apigee/customplugins"
EXPOSE 8000
EXPOSE 8443
USER apigee
ENTRYPOINT ["entrypoint"]
