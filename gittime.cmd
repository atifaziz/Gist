@:: Prints current date and time formatted like in Git logs
@:: Example: Fri Jan 29 10:58:40 2016 +0100
@PowerShell -C """$([DateTimeOffset]::Now.ToString('ddd MMM dd HH:mm:ss yyyy', [Globalization.CultureInfo]::InvariantCulture)) $([DateTimeOffset]::Now.ToString('zzz', [Globalization.CultureInfo]::InvariantCulture) -replace ':', '')"""
