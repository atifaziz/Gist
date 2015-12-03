/*  Copyright (c) 2012, Atif Aziz. All rights reserved.
 *  Written by Atif Aziz, http://www.raboof.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

var wshargs = WScript.Arguments;
var locator = new ActiveXObject('WbemScripting.SWbemLocator');
var computer = wshargs.length ? wshargs.item(0) : '.';
var service = locator.ConnectServer(computer, 'root\\cimv2');
var disks = service.ExecQuery('SELECT * FROM Win32_LogicalDisk');
for (var e = new Enumerator(disks); !e.atEnd(); e.moveNext()) {
    var disk = e.item();
    if (null == disk.Size || null == disk.FreeSpace)
        continue;
    var size = parseFloat(disk.Size), free = parseFloat(disk.FreeSpace);
    WScript.Echo(disk.DeviceID 
                 + ('  ' + (free / size * 100).toFixed(0) + '%').slice(-4)
                 + ' or '
                 + prettyByteSize(free)
                 + ' of '
                 + prettyByteSize(size)
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
