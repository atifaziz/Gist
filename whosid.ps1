[CmdletBinding()]
param(
    [parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [string[]]$SidString)
Process
{
    foreach ($CurrentSidString in $SidString) {
        try
        {
            $Sid = New-Object Security.Principal.SecurityIdentifier($CurrentSidString)
            New-Object PSObject -Property @{ SidString = $Sid.Value; NTAccount = $Sid.Translate([System.Security.Principal.NTAccount]).Value }
        } catch [Security.Principal.IdentityNotMappedException]
        {
            New-Object PSObject -Property @{ SidString = $Sid.Value; NTAccount = $Null }
        }
     }
}
