@echo off
::
:: Copyright (c) 2019 Atif Aziz
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
echo %%0    = %0
echo %%~0   = %~0
echo %%~d0  = %~d0
echo %%~p0  = %~p0
echo %%~n0  = %~n0
echo %%~x0  = %~x0
echo %%~s0  = %~s0
echo %%~ds0 = %~ds0
echo %%~ps0 = %~ps0
echo %%~ns0 = %~ns0
echo %%~xs0 = %~xs0
echo %%~a0  = %~a0
echo %%~t0  = %~t0
echo %%~z0  = %~z0
echo.
echo.Legend:
echo.
echo   %%~I  - expands %%I removing any surrounding quotes (")
echo   %%~fI - expands %%I to a fully qualified path name
echo   %%~dI - expands %%I to a drive letter only
echo   %%~pI - expands %%I to a path only
echo   %%~nI - expands %%I to a file name only
echo   %%~xI - expands %%I to a file extension only
echo   %%~sI - expanded path contains short names only
echo   %%~aI - expands %%I to file attributes of file
echo   %%~tI - expands %%I to date/time of file
echo   %%~zI - expands %%I to size of file
