using System.Reflection;

foreach (var arg in Environment.GetCommandLineArgs().SkipWhile(arg => arg != "--").Skip(1))
{
    var asm = Assembly.ReflectionOnlyLoadFrom(arg);
    Console.WriteLine(asm.GetName());
}
