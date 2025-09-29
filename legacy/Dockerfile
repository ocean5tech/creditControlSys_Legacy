# Legacy Credit Control System - Simplified Approach
FROM docker.io/library/tomcat:8.5-jdk8

LABEL description="Legacy Credit Control System - JDK8 + Tomcat 8.5"
LABEL version="1.0"

# Set environment variables
ENV CATALINA_HOME=/usr/local/tomcat
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Install additional packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ant \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Create application directories
RUN mkdir -p /app/logs /app/data /app/config /app/lib

# Download required libraries
RUN cd /app/lib && \
    wget https://jdbc.postgresql.org/download/postgresql-42.2.29.jar -O postgresql.jar || \
    echo "JDBC download failed" && \
    wget https://repo1.maven.org/maven2/log4j/log4j/1.2.17/log4j-1.2.17.jar -O log4j.jar || \
    echo "Log4j download failed" && \
    cp postgresql.jar $CATALINA_HOME/lib/ && \
    cp log4j.jar $CATALINA_HOME/lib/

# Copy application files
COPY src/main/webapp/ $CATALINA_HOME/webapps/ROOT/

# Create WEB-INF structure and compile Java sources
RUN mkdir -p $CATALINA_HOME/webapps/ROOT/WEB-INF/classes

# Copy and compile Java sources
COPY src/main/java/ /tmp/java-src/
RUN cd /tmp/java-src && \
    find . -name "*.java" > sources.txt && \
    javac -cp "$CATALINA_HOME/lib/*:$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/*" \
          -d $CATALINA_HOME/webapps/ROOT/WEB-INF/classes \
          @sources.txt && \
    rm -rf /tmp/java-src

# Copy startup script
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

# Configure Tomcat with multiple ports
RUN sed -i 's/8080/8080/g' $CATALINA_HOME/conf/server.xml && \
    sed -i 's/<\/Service>/    <Connector port="8081" protocol="HTTP\/1.1" connectionTimeout="20000" redirectPort="8443" \/>\n    <Connector port="8082" protocol="HTTP\/1.1" connectionTimeout="20000" redirectPort="8443" \/>\n  <\/Service>/' $CATALINA_HOME/conf/server.xml

# Expose ports
EXPOSE 8080 8081 8082

# Working directory
WORKDIR /app

# Default command
CMD ["/app/docker-entrypoint.sh"]