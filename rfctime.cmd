@:: Prints current date and time in the RFC 2822 format
@:: Example: Fri, 29 Jan 2016 10:33:55 +0100
@PowerShell -C """$([DateTimeOffset]::Now.ToString('ddd, dd MMM yyyy HH:mm:ss', [Globalization.CultureInfo]::InvariantCulture)) $([DateTimeOffset]::Now.ToString('zzz', [Globalization.CultureInfo]::InvariantCulture) -replace ':', '')"""
