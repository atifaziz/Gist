var wshargs = WScript.Arguments;
var locator = new ActiveXObject('WbemScripting.SWbemLocator');
var computer = wshargs.length ? wshargs.item(0) : '.';
var service = locator.ConnectServer(computer, 'root\\cimv2');
var disks = service.ExecQuery('SELECT * FROM Win32_LogicalDisk');
for (var e = new Enumerator(disks); !e.atEnd(); e.moveNext()) {
    var disk = e.item();
    if (null == disk.Size || null == disk.FreeSpace)
        continue;
    WScript.Echo(disk.DeviceID 
                 + ' ' 
                 + prettyByteSize(disk.FreeSpace) 
                 + ' of ' 
                 + prettyByteSize(disk.Size)
                 + ' or '
                 + ('  ' + (disk.FreeSpace / disk.Size * 100).toFixed(0) + '%').slice(-4)
                 + ' free');
}
function prettyByteSize(size, precision) {
    var OneKiloByte = 1024.0, 
        OneMegaByte = OneKiloByte * 1024.0,
        OneGigaByte = OneMegaByte * 1024.0;
    var suffix;
    var ignorePrecision = false;
    if (size > OneGigaByte)
    {
        size /= OneGigaByte;
        suffix = 'GB';
    }
    else if (size > OneMegaByte)
    {
        size /= OneMegaByte;
        suffix = 'MB';
    }
    else if (size > OneKiloByte)
    {
        size /= OneKiloByte;
        suffix = 'KB';
    }
    else if (size == 1)
    {
        suffix = ' byte';
        ignorePrecision = true;
    }
    else 
    {
        suffix = ' bytes';
        ignorePrecision = true;
    }
    return size.toFixed(ignorePrecision ? 0 : (null == precision ? 2 : precision)) + suffix;
}
