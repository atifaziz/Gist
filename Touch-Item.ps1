# Copyright (c) 2013 Atif Aziz. All rights reserved.
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

function Touch-Item
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true,
                   HelpMessage = "Specifies the path to the item to touch")]
        [string[]]$Path,
        [switch]$Force = $false
    )

    PROCESS 
    {
        ForEach ($path In $path) 
        {
            $file = Get-Item $path -ea Stop `
                  | ? { !$_.PSIsContainer `
                        -and 0 -eq ($file.Attributes -band ([IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System)) }

            if ($file -eq $null)
            {
                Write-Verbose "Skipping directory: $path"
                continue
            }
            if (!$pscmdlet.ShouldProcess("$file"))
            {
                continue
            }
            
            $attributes = $file.Attributes
            $ro = [IO.FileAttributes]::ReadOnly -eq ($attributes -band [IO.FileAttributes]::ReadOnly)
            if ($ro)
            {
                if (!$force)
                {
                    Write-Warning "Skipping file ""$file"" as it is read-only. Use -Force to still touch the file."
                    continue
                }

                $file.Attributes = $attributes -band (-bnot [IO.FileAttributes]::ReadOnly)
            }
            
            $file.LastWriteTime = Get-Date
            if ($ro)
            {
                $file.Attributes = $file.Attributes -bor [IO.FileAttributes]::ReadOnly
            }

            Write-Output $file
        }
    }
}
 
<#    
dir * | Touch-Item -WhatIf
#>
