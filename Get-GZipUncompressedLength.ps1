# Copyright (c) 2019 Atif Aziz. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$File)

BEGIN
{
    $ErrorActionPreference = 'Stop'
    $buffer = New-Object byte[] 4
}

PROCESS
{
    foreach ($f in $file) {
        if ($f -isnot [IO.FileSystemInfo]) {
            $f = Get-ChildItem -File $f
        }
        $size = $null
        if ($f -is [IO.FileInfo]) {
            $fs = [IO.File]::OpenRead($f.FullName)
            try
            {
                # http://www.onicos.com/staff/iz/formats/gzip.html

                # is at least minimum gzip header size?
                if ($fs.Length -ge 18) {
                    $fs.Read($buffer, 0, 2) | Out-Null
                    # has magic header?
                    if ($buffer[0] -eq 0x1f -and $buffer[1] -eq 0x8b) {
                        # last 4 bytes = uncompressed input size modulo 2^32
                        $fs.Seek(-4, 'End') | Out-Null
                        if ($fs.Read($buffer, 0, 4) -eq 4) {
                            $size =      ([UInt32]$buffer[3] -shl 24) `
                                    -bor ([UInt32]$buffer[2] -shl 16) `
                                    -bor ([UInt32]$buffer[1] -shl  8) `
                                    -bor ([UInt32]$buffer[0])
                        }
                    }
                }
            }
            finally
            {
                $fs.Close()
            }
        }
        $f | Add-Member -NotePropertyName UncompressedLength `
                        -NotePropertyValue $size `
                        -PassThru
    }
}
