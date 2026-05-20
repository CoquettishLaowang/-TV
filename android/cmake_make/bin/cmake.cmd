@echo off
setlocal enabledelayedexpansion

set "REAL_CMAKE=C:\Users\wang1\Documents\trae_projects\cc\android_sdk\cmake\3.31.4\bin\cmake.exe"
set "REAL_MAKE=C:\Users\wang1\Documents\trae_projects\cc\android_sdk\cmake\3.31.4\bin\make.exe"
set "COLLECTED_ARGS="

:parse
if "%~1"=="" goto run
if "%~1"=="-GNinja" (
    set "COLLECTED_ARGS=!COLLECTED_ARGS! -G "Unix Makefiles""
) else (
    set "arg=%~1"
    if "!arg!"=="!arg:-DCMAKE_MAKE_PROGRAM=!" (
        set "COLLECTED_ARGS=!COLLECTED_ARGS! %~1"
    ) else (
        set "COLLECTED_ARGS=!COLLECTED_ARGS! -DCMAKE_MAKE_PROGRAM=!REAL_MAKE!"
    )
)
shift
goto parse

:run
"%REAL_CMAKE%" !COLLECTED_ARGS!
exit /b %ERRORLEVEL%