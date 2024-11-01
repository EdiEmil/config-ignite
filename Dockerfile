# Use OpenJDK as a base image
FROM openjdk:21-jdk-slim

# Set working directory in the container
WORKDIR /app

# Copy all necessary JARs and configuration files to the container
COPY ignite-core-2.17.0-SNAPSHOT.jar spring-core-5.3.22.jar spring-beans-5.3.22.jar spring-context-5.3.22.jar spring-aop-5.3.22.jar spring-expression-5.3.22.jar cache-api-1.1.1.jar commons-logging-1.2.jar jmx_prometheus_javaagent-1.0.1.jar ignite-nodeconfig.xml jmx-exporter-config.yml /app/

# Copy control.sh and helper scripts
COPY control.sh /app/
COPY bin/include /app/bin/include
COPY ignite-master /app/ignite-master  

# Expose the port for the Java agent
EXPOSE 9511

# Set IGNITE_HOME to /app so control.sh can locate it
#ENV IGNITE_HOME= /app/ignite-master

# Run the Java application with your specified command
CMD ["java", "--add-opens", "java.base/java.nio=ALL-UNNAMED", \
             "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED", \
             "--add-opens", "java.base/java.io=ALL-UNNAMED", \
             "--add-opens", "java.base/java.lang=ALL-UNNAMED", \
             "--add-opens", "java.base/java.util=ALL-UNNAMED", \
             "-DIGNITE_QUIET=false", \
             "-javaagent:/app/jmx_prometheus_javaagent-1.0.1.jar=9511:/app/jmx-exporter-config.yml", \
             "-cp", "/app/ignite-core-2.17.0-SNAPSHOT.jar:/app/spring-core-5.3.22.jar:/app/spring-beans-5.3.22.jar:/app/spring-context-5.3.22.jar:/app/spring-aop-5.3.22.jar:/app/*", \
             "org.apache.ignite.startup.cmdline.CommandLineStartup", "/app/ignite-nodeconfig.xml"]
