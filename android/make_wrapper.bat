@echo off
setlocal

set REAL_MAKE=C:\Users\wang1\Documents\trae_projects\cc\android_sdk\cmake\3.31.4\bin\make.exe

"%REAL_MAKE%" -j4 %*
exit /b %ERRORLEVEL%