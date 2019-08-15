#!/bin/bash
#

REPO_BASE="indy/var/lib/indy/data/indy"
ETC_BASE="indy/etc/indy"

DIR=$(dirname $(realpath $0)) #"/opt/app-root"
INDY_HOME="${DIR}/indy"

if [ "x${TEST_REPOS}" != "x" ]; then
  TEST_REPOS=$(realpath $TEST_REPOS)
fi

if [ "x${TEST_ETC}" != "x" ]; then
  TEST_ETC=$(realpath $TEST_ETC)
fi

pushd $DIR

if [ "x${TEST_REPOS}" != "x" ]; then
  echo "Copying repository definitions from: ${TEST_REPOS}"
  rm -rf $REPO_BASE/*
  mkdir -p $REPO_BASE
  cp -rvf $TEST_REPOS/* $REPO_BASE
else
  echo "No test repositories specified."
fi

if [ "x${TEST_ETC}" != "x" ]; then
  echo "Copying test configuration from: ${TEST_ETC}"
  cp -rvf $TEST_ETC/* $ETC_BASE
else
  echo "No test configuration specified."
  cat > $ETC_BASE/logging/logback.xml <<-EOF
<configuration>
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <!-- encoders are assigned the type
         ch.qos.logback.classic.encoder.PatternLayoutEncoder by default -->
    <encoder>
      <pattern>[%thread] %-5level %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>${INDY_HOME}/var/log/indy/indy.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
      <fileNamePattern>${INDY_HOME}/var/log/indy/indy.%i.log</fileNamePattern>

      <maxHistory>20</maxHistory>
    </rollingPolicy>

    <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
        <maxFileSize>100MB</maxFileSize>
    </triggeringPolicy>

    <encoder>
      <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} x-forward=%X{x-forwarded-for} - %msg%n</pattern>
    </encoder>
  </appender>

  <logger name="org.jboss.resteasy" level="DEBUG" />
  <logger name="org.jboss" level="ERROR"/>
  <logger name="org.commonjava" level="DEBUG" />
  <logger name="org.apache.http.wire" level="DEBUG" />
  <root level="INFO">
    <appender-ref ref="STDOUT" />
    <appender-ref ref="FILE" />
  </root>
</configuration>
EOF
fi

popd

exec $DIR/indy/bin/indy.sh
