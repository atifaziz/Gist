#!/usr/bin/env dotnet-script

// For more information, see:
// https://docs.microsoft.com/en-us/dotnet/core/dependency-loading/default-probing

var entries =
    from n in new[]
    {
        "TRUSTED_PLATFORM_ASSEMBLIES",
        "PLATFORM_RESOURCE_ROOTS",
        "NATIVE_DLL_SEARCH_DIRECTORIES",
        "APP_PATHS",
        "APP_NI_PATHS",
    }
    select KeyValuePair.Create(n, AppContext.GetData(n) is string sd
                                  ? from s in sd.Split(Path.PathSeparator)
                                    select s.Trim() into s
                                    where s.Length > 0
                                    select s
                                  : Enumerable.Empty<string>())
    into e
    select KeyValuePair.Create(e.Key, e.Value.ToArray());

foreach (var (name, values) in entries)
{
    Console.WriteLine($"{name} ({values.Length}):");
    foreach (var value in values)
        Console.WriteLine($"- {value}");
    Console.WriteLine();
}
