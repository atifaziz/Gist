// Windows (WSH) script to print input head or tail
// Copyright (c) 2013 Atif Aziz
// 
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files 
// (the "Software"), to deal in the Software without restriction, including 
// without limitation the rights to use, copy, modify, merge, publish, 
// distribute, sublicense, and/or sell copies of the Software, and to permit 
// persons to whom the Software is furnished to do so, subject to the 
// following conditions:
// 
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

var args = WScript.Arguments, 
    stdin = WScript.StdIn,
    stdout = WScript.StdOut,
    stderr = WScript.StdErr;
var count = args.length > 0 ? parseInt(args(0)) : 10;
if (isNaN(count)) {
    stderr.WriteLine('Invalid argument');
    WScript.Quit(1);
}
var readln = function(ts) { return ts.AtEndOfStream ? null : ts.ReadLine(); }
if (count >= 0) {
    for (var line = readln(stdin); count-- > 0 && line != null; line = readln(stdin))
        stdout.WriteLine(line);
    while (readln(stdin)) { /* NOP */ }
}
else {
    var lines = [];
    for (var line = readln(stdin); line != null; line = readln(stdin)) {
        lines.push(line);
        if (lines.length > -count)
            lines.shift();
    }
    for (var i = 0; i < lines.length; i++)
        stdout.WriteLine(lines[i]);
}