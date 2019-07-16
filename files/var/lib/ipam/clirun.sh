#!/bin/sh

# Uncomment and set this line if needed:
# JAVA_HOME=/opt/incontrol/jre; export JAVA_HOME
JAVA_HOME=/usr/lib/jvm/default-java; export JAVA_HOME

# Determine where Java lives
if [ -z "$JAVA_HOME" ] ; then
  if [ -x "../../jre/bin/java" ] ; then
    JAVA_HOME=../../jre; export JAVA_HOME
  else
    echo "JAVA_HOME is not set.  Please set JAVA_HOME to the location "
    echo "of your Java installation."
    exit
  fi
fi

# Set the classpath
CLASSPATH=.
alljars=`find classes -name '*.jar' -print`
for jar in $alljars ; do CLASSPATH=$CLASSPATH:$jar ; done
export CLASSPATH
LC_CTYPE=iso_8859_1;export LC_CTYPE
