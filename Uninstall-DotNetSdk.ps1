<#
 # MIT License
 #
 # Copyright (c) 2019 Atif Aziz
 # Copyright (c) 2018 Scott Hanselman
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

 [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param ([Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = 'Version')]
       [string[]]$Version,
       [switch]$List)

begin
{
    $products =
        Get-WmiObject -Query 'SELECT DisplayName, ProdId
                              FROM Win32reg_AddRemovePrograms
                              WHERE DisplayName LIKE ''.NET Core SDK %''
                                 OR DisplayName LIKE ''Microsoft .NET Core SDK %''' |
        Where-Object { $_.DisplayName -match '(?<= )[0-9]+(?:\.[0-9]+){2}(?: - preview[1-9])?' } |
        ForEach-Object {
            [pscustomobject]@{
                DisplayName = $_.DisplayName;
                Version     = $Matches[0];
                Id          = $_.ProdID
            }
        }
}

process
{
    if ($list)
    {
        $products
    }
    else
    {
        foreach ($v in $version)
        {
            $product = $products | Where-Object { $_.Version -eq $v }
            if ($PSCmdlet.ShouldProcess($product.DisplayName))
            {
                Start-Process msiexec -ArgumentList '/x', $_.Id -Wait
            }
        }
    }
}
