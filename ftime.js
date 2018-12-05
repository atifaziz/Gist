// Windows (WSH) script to print file times
// Copyright (c) 2015, 2018 Atif Aziz
// Portions Copyright 2010-2015 Mike Bostock
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

Array.prototype.forEach = function (callback, thisArg) {
    var len = this.length >>> 0;
    for (var i = 0; i < len; i++)
        if (i in this) callback.call(thisArg, this[i], i, this);
};

Array.prototype.map = function (callback, thisArg) {
    var result = [];
    this.forEach(function (item, idx, arr) {
        result.push(callback.call(this, item, idx, arr));
    }, thisArg);
    return result;
};

Object.prototype.keys = function () {
    var keys = [];
    for (var k in this)
        if (this.hasOwnProperty(k)) keys.push(k);
    return keys;
};

function interval(floori, count) {

    var t0 = new Date, t1 = new Date;

    function interval(date) {
        return floori(date = new Date(+date)), date;
    }

    if (count) interval.count = function (start, end) {
        t0.setTime(+start), t1.setTime(+end);
        floori(t0), floori(t1);
        return Math.floor(count(t0, t1));
    };

    return interval;
}

var day = interval(
    function (date) { date.setHours(0, 0, 0, 0); },
    function (start, end) { return (end - start - (end.getTimezoneOffset() - start.getTimezoneOffset()) * 6e4) / 864e5; });

var year = interval(
    function (date) { date.setHours(0, 0, 0, 0); date.setMonth(0, 1); },
    function (start, end) { return end.getFullYear() - start.getFullYear(); });


function weekday(i) {
    return interval(
        function (date) {
            date.setHours(0, 0, 0, 0);
            date.setDate(date.getDate() - (date.getDay() + 7 - i) % 7);
        },
        function (start, end) { return (end - start - (end.getTimezoneOffset() - start.getTimezoneOffset()) * 6e4) / 6048e5; });
}

var sunday = weekday(0);
var monday = weekday(1);

var locale = {
    dateTime: '%a %b %e %X %Y',
    date: '%m/%d/%Y',
    time: '%H:%M:%S',
    periods: ['AM', 'PM'],
    days: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    shortDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    shortMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
};

function pad(value, fill, width) {
    var sign = value < 0 ? "-" : "",
        string = (sign ? -value : value) + "",
        length = string.length;
    return sign + (length < width ? new Array(width - length + 1).join(fill) + string : string);
}

function formatShortWeekday(d) { return locale.shortDays[d.getDay()]; }
function formatWeekday(d) { return locale.days[d.getDay()]; }
function formatShortMonth(d) { return locale.shortMonths[d.getMonth()]; }
function formatMonth(d) { return locale.months[d.getMonth()]; }
function formatPeriod(d) { return locale.periods[+(d.getHours() >= 12)]; }
function formatDayOfMonth(d, p) { return pad(d.getDate(), p, 2); }
function formatHour24(d, p) { return pad(d.getHours(), p, 2); }
function formatHour12(d, p) { return pad(d.getHours() % 12 || 12, p, 2); }
function formatDayOfYear(d, p) { return pad(1 + day.count(year(d), d), p, 3); }
function formatMilliseconds(d, p) { return pad(d.getMilliseconds(), p, 3); }
function formatMonthNumber(d, p) { return pad(d.getMonth() + 1, p, 2); }
function formatMinutes(d, p) { return pad(d.getMinutes(), p, 2); }
function formatSeconds(d, p) { return pad(d.getSeconds(), p, 2); }
function formatWeekNumberSunday(d, p) { return pad(sunday.count(year(d), d), p, 2); }
function formatWeekdayNumber(d) { return d.getDay(); }
function formatWeekNumberMonday(d, p) { return pad(monday.count(year(d), d), p, 2); }
function formatYear(d, p) { return pad(d.getFullYear() % 100, p, 2); }
function formatFullYear(d, p) { return pad(d.getFullYear() % 10000, p, 4); }
function formatZone(d) {
    var z = d.getTimezoneOffset();
    return (z > 0 ? '-' : (z *= -1, '+'))
        + pad(z / 60 | 0, '0', 2)
        + pad(z % 60, '0', 2);
}

var formats = {
    'a': { f: formatShortWeekday, h: "abbreviated weekday name." },
    'A': { f: formatWeekday, h: "full weekday name." },
    'b': { f: formatShortMonth, h: "abbreviated month name." },
    'B': { f: formatMonth, h: "full month name." },
    'c': { f: null, h: "the locale's date and time, such as %a %b %e %H:%M:%S %Y." },
    'd': { f: formatDayOfMonth, h: "zero-padded day of the month as a decimal number [01,31]." },
    'e': { f: formatDayOfMonth, h: "space-padded day of the month as a decimal number [ 1,31]." },
    'H': { f: formatHour24, h: "hour (24-hour clock) as a decimal number [00,23]." },
    'I': { f: formatHour12, h: "hour (12-hour clock) as a decimal number [01,12]." },
    'j': { f: formatDayOfYear, h: "day of the year as a decimal number [001,366]." },
    'L': { f: formatMilliseconds, h: "milliseconds as a decimal number [000,999]." },
    'm': { f: formatMonthNumber, h: "month as a decimal number [01,12]." },
    'M': { f: formatMinutes, h: "minute as a decimal number [00,59]." },
    'p': { f: formatPeriod, h: "either AM or PM." },
    'S': { f: formatSeconds, h: "second as a decimal number [00,61]." },
    'U': { f: formatWeekNumberSunday, h: "Sunday-based week of the year as a decimal number [00,53]." },
    'w': { f: formatWeekdayNumber, h: "Sunday-based weekday as a decimal number [0,6]." },
    'W': { f: formatWeekNumberMonday, h: "Monday-based week of the year as a decimal number [00,53]." },
    'x': { f: null, h: "the locale's date, such as %m/%d/%Y." },
    'X': { f: null, h: "the locale's time, such as %H:%M:%S." },
    'y': { f: formatYear, h: "year without century as a decimal number [00,99]." },
    'Y': { f: formatFullYear, h: "year with century as a decimal number." },
    'Z': { f: formatZone, h: "time zone offset, such as -0700, -07:00, -07, or Z." },
    '%': { f: function () { return "%"; }, h: "a literal percent sign (%)." }
};


var pads = { '-': '', '_': ' ', '0': '0' };

function format(specifier, formats) {
    return function (date) {
        var string = [],
            i = -1,
            j = 0,
            n = specifier.length,
            c,
            pad,
            format;

        while (++i < n) {
            if (specifier.charCodeAt(i) === 37) {
                string.push(specifier.slice(j, i));
                if ((pad = pads[c = specifier.charAt(++i)]) != null) c = specifier.charAt(++i);
                else pad = c === 'e' ? ' ' : '0';
                if (format = formats[c]) c = format.f(date, pad);
                string.push(c);
                j = i + 1;
            }
        }

        string.push(specifier.slice(j, i));
        return string.join('');
    };
}

formats.c.f = format(locale.dateTime, formats);
formats.x.f = format(locale.date, formats);
formats.X.f = format(locale.time, formats);

function UTCDate(d) { this.d = typeof d === 'undefined' ? new Date() : new Date(+d); }

UTCDate.prototype.getFullYear = function () { return this.d.getUTCFullYear(); };
UTCDate.prototype.getMonth = function () { return this.d.getUTCMonth(); };
UTCDate.prototype.getDate = function () { return this.d.getUTCDate(); };
UTCDate.prototype.getDay = function () { return this.d.getUTCDay(); };
UTCDate.prototype.getHours = function () { return this.d.getUTCHours(); };
UTCDate.prototype.getMinutes = function () { return this.d.getUTCMinutes(); };
UTCDate.prototype.getSeconds = function () { return this.d.getUTCSeconds(); };
UTCDate.prototype.getMilliseconds = function () { return this.d.getUTCMilliseconds(); };
UTCDate.prototype.getTimezoneOffset = function () { return 0; };
UTCDate.prototype.valueOf = function () { return this.d.getTime(); };

UTCDate.prototype.setMonth = function (m, d) { return this.d.setUTCMonth(m, d); };
UTCDate.prototype.setDate = function (d) { return this.d.setUTCDate(d); };
UTCDate.prototype.setHours = function (h, m, s, ms) { return this.d.setUTCHours(h, m, s, ms); };
UTCDate.prototype.setTime = function (v) { return this.d.setTime(v); };

UTCDate.prototype.toString = function () { return format('%a %b %-e %H:%M:%S UTC%Z %Y', formats)(this); };

var stdin = WScript.StdIn,
    stdout = WScript.StdOut,
    stderr = WScript.StdErr;

var console = {
    log: function (s) { stdout.WriteLine(s); },
    error: function (s) { stderr.WriteLine(s); }
};

function exit(code) { WScript.Quit(code || 0); }

try {
    main((
        function (args) {
            var result = [ WScript.ScriptName.replace(/\.[^.]+$/, '') ];
            for (var i = 0; i < args.length; i++)
                result.push(args(i));
            return result;
        })(WScript.Arguments));
} catch (e) {
    console.error(e.message || e.toString());
    exit(0xbad);
}

function main(args) {

    var timeMap = {
        'mtime': 'DateLastModified',
        'atime': 'DateLastAccessed',
        'btime': 'DateCreated'
    };

    var name = args.shift(),
        arg,
        showHelp = false,
        time = function (d) { return d || new Date(); },
        filePath,
        tsSpecifier,
        property = 'DateLastModified';

    function getOptionValue(name) {
        var value = args.shift();
        if (!value)
            throw new Error('Option "' + name + '" is missing its value!');
        return value;
    }

    while (!showHelp && typeof filePath === 'undefined' && (arg = args.shift())) {
        switch (arg) {
            case '-h':
            case '-?':
            case '--help':
                showHelp = true;
                break;
            case '-u':
                time = function (d) { return new UTCDate(d); };
                break;
            case '-t':
            case '--time':
                property = getOptionValue(arg);
                if (1 === property.length)
                    property += 'time';
                property = timeMap[property];
                if (!property) {
                    throw new Error('Invalid value for option "' + arg + '"! Specify one of: ' + timeMap.keys().join(', '));
                }
                break;
            case '-f':
            case '--format':
                tsSpecifier = getOptionValue(arg);
                break;
            default:
                if (arg[0] === '-')
                    throw new Error('Invalid argument: ' + arg);
                filePath = arg;
                break;
        }
    }

    var now;

    if (showHelp) {

        now = time();

        var help = [
            name + ' 1.0',
            'Copyright (c) 2015, 2018 Atif Aziz.',
            'Portions Copyright 2010-2015 Mike Bostock.',
            '',
            'Prints the creation, modification or last access time for a file.',
            '',
            'Usage: ' + name + ' OPTIONS FILE',
            '',
            'where OPTIONS are:',
            '',
            '-t FIELD       where FIELD is:',
            '               - b|btime = creation time',
            '               - m|mtime = modification time',
            '               - a|atime = last access time',
            '-f SPECIFIER   format printed time per SPECIFIER',
            '-u             changes printed time to be in UTC',
            '-h|-?|--help   displays this help',
            '',
            'SPECIFIER may contain the following directives:',
            '',
            function () {
                return formats.keys().map(function (d) { return '  %' + d + ' - ' + formats[d].h; });
            },
            '',
            'Examples of what each directive yields for the current date & time of',
            now + ':',
            '',
            function () {
                return formats.keys().map(function (d) { return '  %' + d + ' => ' + format('%' + d, formats)(now); });
            },
        ];

        Array.prototype.concat.apply([], help.map(function (h) { return typeof h === 'function' ? h() : h; }))
            .forEach(console.log);

        WScript.Quit(0);
    }

    if (!filePath)
        throw new Error('Missing file specification!');

    var fso = new ActiveXObject("Scripting.FileSystemObject");
    var file = fso.GetFile(filePath);
    now = time(new Date(file[property]));

    var tsfmt = tsSpecifier
        ? format(tsSpecifier, formats)
        : function (d) { return d.toString(); };

    console.log(tsfmt(now));
}

// The formatting code is dervided from the d3-time-format[1] project.
// [1] https://github.com/d3/d3-time-format

/* -------------------------- d3-time-format LICENSE --------------------------

Copyright 2010-2015 Mike Bostock
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the author nor the names of contributors may be used to
  endorse or promote products derived from this software without specific prior
  written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-----------------------------------------------------------------------------*/
