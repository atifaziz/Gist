#region License and Terms
// MoreLINQ - Extensions to LINQ to Objects
// Copyright (c) 2008 Jonathan Skeet. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#endregion

#region Imports

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;

#endregion

static partial class MoreEnumerable
{
    public static IEnumerable<TResult> Pairwise<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, TSource, TResult> resultSelector)
    {
        if (source == null) throw new ArgumentNullException("source");
        if (resultSelector == null) throw new ArgumentNullException("resultSelector");
        return PairwiseImpl(source, resultSelector);
    }

    private static IEnumerable<TResult> PairwiseImpl<TSource, TResult>(IEnumerable<TSource> source, Func<TSource, TSource, TResult> resultSelector)
    {
        Debug.Assert(source != null);
        Debug.Assert(resultSelector != null);

        using (var e = source.GetEnumerator())
        {
            if (!e.MoveNext())
                yield break;

            var previous = e.Current;
            while (e.MoveNext())
            {
                yield return resultSelector(previous, e.Current);
                previous = e.Current;
            }
        }
    }
}

#region Copyright (c) 2011 Atif Aziz. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
#endregion

partial class StackTraceParser
{
    const string Space = @"[\x20\t]";
    const string NotSpace = @"[^\x20\t]";

    static readonly Regex Regex = new Regex(@"
            ^
            " + Space + @"*
            \w+ " + Space + @"+
            (?<frame>
                (?<type> " + NotSpace + @"+ ) \.
                (?<method> " + NotSpace + @"+? ) " + Space + @"*
                (?<params>  \( ( " + Space + @"* \)
                               |                    (?<pt> .+?) " + Space + @"+ (?<pn> .+?)
                                 (, " + Space + @"* (?<pt> .+?) " + Space + @"+ (?<pn> .+?) )* \) ) )
                ( " + Space + @"+
                    ( # Microsoft .NET stack traces
                    \w+ " + Space + @"+
                    (?<file> [a-z] \: .+? )
                    \: \w+ " + Space + @"+
                    (?<line> [0-9]+ ) \p{P}?
                    | # Mono stack traces
                    \[0x[0-9a-f]+\] " + Space + @"+ \w+ " + Space + @"+
                    <(?<file> [^>]+ )>
                    :(?<line> [0-9]+ )
                    )
                )?
            )
            \s*
            $",
        RegexOptions.IgnoreCase
        | RegexOptions.Multiline
        | RegexOptions.ExplicitCapture
        | RegexOptions.CultureInvariant
        | RegexOptions.IgnorePatternWhitespace
        | RegexOptions.Compiled,
        // Cap the evaluation time to make it obvious should the expression
        // fall into the "catastrophic backtracking" trap due to over
        // generalization.
        // https://github.com/atifaziz/StackTraceParser/issues/4
        TimeSpan.FromSeconds(5));

    public static IEnumerable<T> Parse<T>(
        string text,
        Func<string, string, string, string, IEnumerable<KeyValuePair<string, string>>, string, string, T> selector)
    {
        if (selector == null) throw new ArgumentNullException("selector");

        return Parse(text, (idx, len, txt) => txt,
                            (t, m) => new { Type = t, Method = m },
                            (pt, pn) => new KeyValuePair<string, string>(pt, pn),
                            // ReSharper disable once PossibleMultipleEnumeration
                            (pl, ps) => new { List = pl, Items = ps },
                            (fn, ln) => new { File = fn, Line = ln },
                            (f, tm, p, fl) => selector(f, tm.Type, tm.Method, p.List, p.Items, fl.File, fl.Line));
    }

    public static IEnumerable<TFrame> Parse<TToken, TMethod, TParameters, TParameter, TSourceLocation, TFrame>(
        string text,
        Func<int, int, string, TToken> tokenSelector,
        Func<TToken, TToken, TMethod> methodSelector,
        Func<TToken, TToken, TParameter> parameterSelector,
        Func<TToken, IEnumerable<TParameter>, TParameters> parametersSelector,
        Func<TToken, TToken, TSourceLocation> sourceLocationSelector,
        Func<TToken, TMethod, TParameters, TSourceLocation, TFrame> selector)
    {
        if (tokenSelector == null) throw new ArgumentNullException("tokenSelector");
        if (methodSelector == null) throw new ArgumentNullException("methodSelector");
        if (parameterSelector == null) throw new ArgumentNullException("parameterSelector");
        if (parametersSelector == null) throw new ArgumentNullException("parametersSelector");
        if (sourceLocationSelector == null) throw new ArgumentNullException("sourceLocationSelector");
        if (selector == null) throw new ArgumentNullException("selector");

        return from Match m in Regex.Matches(text)
                select m.Groups into groups
                let pt = groups["pt"].Captures
                let pn = groups["pn"].Captures
                select selector(Token(groups["frame"], tokenSelector),
                                methodSelector(
                                    Token(groups["type"], tokenSelector),
                                    Token(groups["method"], tokenSelector)),
                                parametersSelector(
                                    Token(groups["params"], tokenSelector),
                                    from i in Enumerable.Range(0, pt.Count)
                                    select parameterSelector(Token(pt[i], tokenSelector),
                                                            Token(pn[i], tokenSelector))),
                                sourceLocationSelector(Token(groups["file"], tokenSelector),
                                                        Token(groups["line"], tokenSelector)));
    }

    static T Token<T>(Capture capture, Func<int, int, string, T> tokenSelector)
    {
        return tokenSelector(capture.Index, capture.Length, capture.Value);
    }
}

partial interface IStackTraceFormatter<T>
{
    T Text(string text);
    T Type(T markup);
    T Method(T markup);
    T ParameterType(T markup);
    T ParameterName(T markup);
    T File(T markup);
    T Line(T markup);
    T BeforeFrame { get; }
    T AfterFrame { get; }
    T BeforeParameters { get; }
    T AfterParameters { get; }
}

static partial class StackTraceFormatter
{
    public static IEnumerable<T> Format<T>(string text, IStackTraceFormatter<T> formatter)
    {
        Debug.Assert(text != null);

        var frames = StackTraceParser.Parse
            (
                text,
                (idx, len, txt) => new
                {
                    Index = idx,
                    End = idx + len,
                    Text = txt,
                    Markup = formatter.Text(txt),
                },
                (t, m) => new
                {
                    Type = new { t.Index, t.End, Markup = formatter.Type(t.Markup) },
                    Method = new { m.Index, m.End, Markup = formatter.Method(m.Markup) }
                },
                (t, n) => new
                {
                    Type = new { t.Index, t.End, Markup = formatter.ParameterType(t.Markup) },
                    Name = new { n.Index, n.End, Markup = formatter.ParameterName(n.Markup) }
                },
                (p, ps) => new { List = p, Parameters = ps.ToArray() },
                (f, l) => new
                {
                    File = f.Text.Length > 0
                            ? new { f.Index, f.End, Markup = formatter.File(f.Markup) }
                            : null,
                    Line = l.Text.Length > 0
                            ? new { l.Index, l.End, Markup = formatter.Line(l.Markup) }
                            : null,
                },
                (f, tm, p, fl) =>
                    from tokens in new[]
                    {
                        new[]
                        {
                            new { f.Index, End = f.Index, Markup = formatter.BeforeFrame },
                            tm.Type,
                            tm.Method,
                            new { p.List.Index, End = p.List.Index, Markup = formatter.BeforeParameters },
                        },
                        from pe in p.Parameters
                        from e in new[] { pe.Type, pe.Name }
                        select e,
                        new[]
                        {
                            new { Index = p.List.End, p.List.End, Markup = formatter.AfterParameters },
                            fl.File,
                            fl.Line,
                            new { Index = f.End, f.End, Markup = formatter.AfterFrame },
                        },
                    }
                    from token in tokens
                    where token != null
                    select token
            );

        return
            from token in MoreEnumerable.Pairwise(Enumerable.Repeat(new { Index = 0, End = 0, Markup = default(T) }, 1)
                                                            .Concat(from tokens in frames from token in tokens select token),
                                                  (prev, curr) => new { Previous = prev, Current = curr })
            from m in new[]
            {
                formatter.Text(text.Substring(token.Previous.End, token.Current.Index - token.Previous.End)),
                token.Current.Markup,
            }
            select m;
    }
}

static class Marker
{
    public static readonly Action None = delegate { };
    public static Action Background(ConsoleColor color) => () => Console.BackgroundColor = color;
    public static Action Foreground(ConsoleColor color) => () => Console.ForegroundColor = color;
}

sealed class StackTraceConsoleFormatter : IStackTraceFormatter<Action>
{
    readonly Action _defaultForeground;
    readonly Action _defaultBackground;

    public StackTraceConsoleFormatter()
    {
        _defaultForeground = Marker.Foreground(Console.ForegroundColor);
        _defaultBackground = Marker.Background(Console.BackgroundColor);
    }

    Action ForeColor(ConsoleColor color, Action markup) => Marker.Foreground(color) + markup + _defaultForeground;

    public Action Text(string text)            => () => Console.Write(text);
    public Action Type(Action markup)          => ForeColor(ConsoleColor.DarkCyan  , markup);
    public Action Method(Action markup)        => ForeColor(ConsoleColor.Cyan      , markup);
    public Action ParameterType(Action markup) => ForeColor(ConsoleColor.DarkYellow, markup);
    public Action ParameterName(Action markup) => ForeColor(ConsoleColor.Gray      , markup);
    public Action File(Action markup)          => ForeColor(ConsoleColor.Yellow    , markup);
    public Action Line(Action markup)          => ForeColor(ConsoleColor.Magenta   , markup);
    public Action BeforeFrame                  => Marker.None;
    public Action AfterFrame                   => Marker.None;
    public Action BeforeParameters             => Marker.None;
    public Action AfterParameters              => Marker.None;
}

var input = Console.In.ReadToEnd();
foreach (var marker in StackTraceFormatter.Format(input, new StackTraceConsoleFormatter()))
    marker();
Console.WriteLine();
