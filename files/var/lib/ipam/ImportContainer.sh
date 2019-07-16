#!/bin/sh
# ---------------------------------------------------------------------------
# Script for the ImportContainer CLI
#----------------------------------------------------------------------------

# Class to run
CLASSNAME=com.diamondip.netcontrol.cli.ImportContainerCLI

# Get standard environment variable
PRGDIR=`dirname "$0"`
cd $PRGDIR

if [ -r ./clirun.sh ]; then
    . ./clirun.sh
fi

$JAVA_HOME/jre/bin/java -Duser.dir=. -cp $CLASSPATH $CLASSNAME "$@"

exit $?
