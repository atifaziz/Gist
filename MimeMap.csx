#r "System.Xml.Linq"

using System.IO;
using System.Xml.Linq;

static void Main(string[] args)
{
    var configPaths = args.Any() ? args.Take(1) : new[]
    {
        Environment.ExpandEnvironmentVariables(@"%windir%\system32\inetsrv\config\applicationHost.config"),
        $@"{Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments)}\IISExpress\config\applicationhost.config"
    };

    var configFilePath = configPaths.Where(File.Exists).FirstOrDefault();

    if (configFilePath == null)
        throw new FileNotFoundException($"IIS configuration file not found.");

    var q =
        from ms in new[]
        {
            XDocument.Load(configFilePath)
                     .Elements("configuration")
                     .Elements("system.webServer")
                     .Elements("staticContent")
                     .FirstOrDefault()?
                     .Elements("mimeMap")
        }
        where ms != null
        from msq in new[]
        {
            from m in ms
            select new
            {
                FileExtension = (string) m.Attribute("fileExtension"),
                MimeType      = (string) m.Attribute("mimeType"),
            }
        }
        from m in msq.Select(e => e.FileExtension).Contains(".*")
                ? msq
                : Enumerable.Repeat(new { FileExtension = ".*", MimeType = "application/octet-stream" }, 1)
                            .Concat(msq)
        select m;

    foreach (var e in q)
        Console.WriteLine($"{e.FileExtension,-15} {e.MimeType}");
}

try
{
    Main(Environment.GetCommandLineArgs()
                    .SkipWhile(arg => arg != "--")
                    .Skip(1)
                    .ToArray());
}
catch (Exception e)
{
    Console.Error.WriteLine(e.GetBaseException().Message);
    Environment.Exit(0xbad);
}
