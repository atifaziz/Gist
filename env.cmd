:: Copyright (c) 2020 Atif Aziz
::
:: Permission is hereby granted, free of charge, to any person obtaining
:: a copy of this software and associated documentation files (the
:: "Software"), to deal in the Software without restriction, including
:: without limitation the rights to use, copy, modify, merge, publish,
:: distribute, sublicense, and/or sell copies of the Software, and to
:: permit persons to whom the Software is furnished to do so, subject to
:: the following conditions:
::
:: The above copyright notice and this permission notice shall be
:: included in all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
:: EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
:: MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
:: NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
:: BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
:: ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
:: CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
:: SOFTWARE.
::
:: Sets environment variables that are then inherited by a launched program.
:: Environment variables must be the initial arguments to this script and
:: follow the syntax "NAME=VALUE" (the quotes are significant). Once one of
:: the initial arguments no longer follow that syntax then the remaining
:: arguments make up the command-line interface of the program to execute.
::
:: CMD.EXE usage examples:
::
::     call env "FOO=bar" "BAR=baz" program arg1 arg2 arg3
::
:: Set the environment variable "FOO" to "bar" and "BAR" to "baz", then
:: launches "program" with the arguments "arg1", "arg2" and "arg3".
::
@echo off
setlocal
:loop
if "%~1"=="" goto :EOF
set NAME=
set VALUE=
for /f "tokens=1,2 delims==" %%a in ("%~1") do (
    set NAME=%%a
    set VALUE=%%b
)
if not "%~1"=="%NAME%=%VALUE%" goto :cli
set %NAME%=%VALUE%
shift /1
goto :loop
:cli
set CLI=%CLI% %1
shift /1
if "%~1"=="" goto :run
goto :cli
:run
%CLI%
