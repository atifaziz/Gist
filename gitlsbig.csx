#r "nuget: morelinq, 3.3.2"
#r "nuget: Mannex, 3.0.0"

using System.Text.RegularExpressions;
using Mannex;
using Mannex.Diagnostics;
using MoreLinq;

var result =
    from stdout in
        MoreEnumerable.Return(await new ProcessStartInfo
        {
            FileName = "git",
            Arguments = "log --pretty=oneline --numstat",
            WorkingDirectory = Args.Any() ? Args.First() : null,
            UseShellExecute = false,
            CreateNoWindow = true,
        }
        .StartAsync((_, stdout, stderr) => stdout))
    from s in stdout.SplitIntoLines()
                    .Segment(s => Regex.IsMatch(s, @"^[0-9a-f]{40,} "))
    select
        s.Index().Partition(e => e.Key == 0,
                            (hs, ns) => hs.Single().Value.Split(' ', 2).Fold((h, s) => new
                            {
                                Hash = h,
                                Subject = s,
                                Count = ns.Count()
                            }))
    into e
    orderby e.Count descending
    select $"{e.Count,5} {e.Hash} {e.Subject}";

foreach (var e in result)
    Console.WriteLine(e);
