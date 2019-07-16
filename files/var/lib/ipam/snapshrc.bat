@echo off
Title InControl Environment Settings
SET JAVA_HOME="C:\Program Files\Java\jre1.5.0_10"

if "%1" == "" goto params

set CLASSPATH=..\..\classes
FOR /F "eol=#" %%j IN (..\incjars.manifest) DO SET CLASSPATH=!CLASSPATH!;..\..\classes\%%j

REM Add the swiftmq classes
set INCCLASSPATH=.;%CLASSPATH%
goto done

:params
echo This file should only be used by ImportElementSnapshot and ImportServiceSnapshot and should not be called directly.
echo Aborting...

:done

