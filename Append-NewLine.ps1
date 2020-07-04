<#
 # MIT License
 #
 # Copyright (c) 2020 Atif Aziz
 #
 # Permission is hereby granted, free of charge, to any person obtaining a copy
 # of this software and associated documentation files (the "Software"), to deal
 # in the Software without restriction, including without limitation the rights
 # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 # copies of the Software, and to permit persons to whom the Software is
 # furnished to do so, subject to the following conditions:
 #
 # The above copyright notice and this permission notice shall be included in
 # all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 # SOFTWARE.
 #>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param([Parameter(ValueFromPipeline = $true)]
      [string[]]$File)

BEGIN
{
    $ErrorActionPreference = 'Stop'
    $nl = [System.Environment]::NewLine.ToCharArray()
    [byte]$check = $nl[$nl.Length - 1]
}

PROCESS
{
    foreach ($f in $file)
    {
        try
        {
            $path = Resolve-Path $f
            $fs = [IO.File]::Open($path, [IO.FileMode]'Open')
            if ($fs.Length -eq 0)
            {
                Write-Warning "Skipping empty file: $f"
            }
            else
            {
                $fs.Seek(-1, [IO.SeekOrigin]'End') | Out-Null
                if ($fs.ReadByte() -ne $check -and $PSCmdlet.ShouldProcess($f)) {
                    $nl | % { $fs.WriteByte([char]$_) }
                    $fs.Close()
                    Write-Output $f
                }
            }
        }
        finally
        {
            if ($fs) {
                $fs.Close()
            }
        }
    }
}
