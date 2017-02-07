:: Copyright (c) 2017 Atif Aziz
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

@echo off
pushd "%~dp0"
call :main %*
popd
goto :EOF

:main
setlocal
for /f "tokens=1,3,*" %%f in ('git ls-files -s') do @if %%f==120000 call :mklink "%%h"
goto :EOF

:mklink
setlocal
dir %1 | findstr "/c:<SYMLINK>" > nul && (
    echo>&2 Skipping %1 ^(already linked?^)
    goto :EOF
)
for /f %%f in ('type %1') do set TARGET=%%f
del %1 ^
  && mklink %1 %TARGET% ^
  && git update-index --assume-unchanged %1
goto :EOF
