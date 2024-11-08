# ELK tracing and logging setup


## Traces

1. ### APM agent 
    - Copy the [apm_agent](apm_agent) folder to the server (preferably in the wildfly installation location)
    - edit the `environment` variable in [elasticapm.properties](apm_agent/elasticapm.properties#L3) and set it to `{location}-{enviroment}`
        - Ex: if the server is in `Hyderabad` and it is a `sandbox` server set `environment` to `hyd-sandbox`
    - edit [standalone.conf](bin/wildfly/standalone.conf#L95) / [standalone.conf.bat](bin/wildfly/standalone.conf.bat#L95) in bin folder of wildfly installation to include apm javaagent
2. restart wildfly
3. check if traces are visible in APM section of kibana


## Logging

1. ### WAR file changes
    - create a Logs folder inside wildfly 
    - in application.properties of war file ensure that `logging.file.name` is set to `{wildfly-location}/Logs/{service}.log`
        - Ex: if wildfly is deployed at `E:\wildfly` and service is Common API then set `logging.file.name=E:/wildfly/Logs/common-api.log`
2. ### Filebeat
    - Download and install [filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html)
    - download [http_ca.crt](http_ca.crt) to the server (preferably in the filebeat installation location)
    - edit filebeat.yml in filebeat installation folder and replace its contents with [filebeat.yml](filebeat.yml)
        - set the [paths](filebeat.yml#L5) to Logs folder created in step 1 `{wildfly-location}/Logs`
            - Ex: if wildfly is deployed at `E:\wildfly` then set paths to `E:/wildfly/Logs/*.json`
        - set the [environment](filebeat.yml#L13) to match the one set in APM agent
            - Ex: if the server is in `Hyderabad` and it is a `sandbox` server set `environment` to `hyd-sandbox`
        - set [API KEY](filebeat.yml#L17) used for filebeat to communicate with elasticsearch
        - set the [certificate](filebeat.yml#L19) location of http_ca.crt
3. restart filebeat
4. check for logs under filebeat in kibana

