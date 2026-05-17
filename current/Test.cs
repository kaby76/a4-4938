// Generated from trgen 0.23.44

using Antlr4.Runtime;
using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Tree;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UtfUnknown;
public class Program
{
    public static CSharpParser Parser { get; set; }
    public static CSharpLexer Lexer { get; set; }
    public static ITokenStream TokenStream { get; set; }
    public static ICharStream CharStream { get; set; }
    public static IParseTree Tree { get; set; }
    public static List<IParseTree> Trees { get; set; }
    public static string StartSymbol { get; set; } = "prog";
    public static string Input { get; set; }
    public static bool HeatMap { get; set; } = false;

    static bool show_token_count = false;
    static long total_count = 0;
    static bool old = false;
    static bool two_byte = false;
    static int exit_code = 0;
    static string file_encoding = "";
    static int string_instance = 0;
    static string prefix = "";
    static bool quiet = false;
    static int limit = 0; // 0 = unlimited

    static void Main(string[] args)
    {
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        List<bool> is_fns = new List<bool>();
        List<string> inputs = new List<string>();
        for (int i = 0; i < args.Length; ++i)
        {
            if (args[i] == "-tc")
            {
                show_token_count = true;
            }
            else if (args[i] == "-two-byte")
            {
                two_byte = true;
            }
            else if (args[i] == "-old")
            {
                old = true;
            }
            else if (args[i] == "-prefix")
            {
                prefix = args[++i] + " ";
            }
            else if (args[i] == "-input")
            {
                inputs.Add(args[++i]);
                is_fns.Add(false);
            }
            else if (args[i] == "-encoding")
            {
                ++i;
                file_encoding = args[i];
            }
            else if (args[i] == "-x")
            {
                for (; ; )
                {
                    var line = System.Console.In.ReadLine();
                    line = line?.Trim();
                    if (line == null || line == "")
                    {
                        break;
                    }
                    inputs.Add(line);
                    is_fns.Add(true);
                }
            }
            else if (args[i] == "-q")
            {
                quiet = true;
            }
            else if (args[i] == "--limit" || args[i].StartsWith("--limit="))
            {
                if (args[i].StartsWith("--limit="))
                {
                    int.TryParse(args[i].Substring(8), out limit);
                }
                else if (i + 1 < args.Length)
                {
                    int.TryParse(args[++i], out limit);
                }
            }
            else if (args[i][0] == '-')
            {
                // Ignore unknown option.
            }
            else
            {
                 inputs.Add(args[i]);
                 is_fns.Add(true);
            }
        }
        if (inputs.Count() == 0)
        {
            ParseStdin();
        }
        else
        {
            DateTime before = DateTime.Now;
            for (int f = 0; f < inputs.Count(); ++f)
            {
                if (is_fns[f])
                    ParseFilename(inputs[f], f);
                else
                    ParseString(inputs[f], f);
            }
            DateTime after = DateTime.Now;
            if (!quiet) System.Console.Error.WriteLine(prefix + "Total Time: " + (after - before).TotalSeconds);
            if (show_token_count) System.Console.Error.WriteLine("TC: " + total_count);
        }
        Environment.ExitCode = exit_code;
    }

    static void ParseStdin()
    {
        ICharStream str = null;
        str = CharStreams.fromStream(System.Console.OpenStandardInput());
        DoParse(str, "stdin", 0);
    }

    static void ParseString(string input, int row_number)
    {
        ICharStream str = null;
        str = CharStreams.fromString(input);
        DoParse(str, "string" + string_instance++, row_number);
    }

    static void ParseFilename(string input, int row_number)
    {
        ICharStream str = null;
        if (two_byte)
            str = new TwoByteCharStream(input);
        else if (old)
        {
            FileStream fs = new FileStream(input, FileMode.Open);
            str = new Antlr4.Runtime.AntlrInputStream(fs);
        }
        else if (file_encoding == null || file_encoding == "")
        {
            var detected = CharsetDetector.DetectFromFile(input);
            var enc = detected.Detected?.Encoding ?? Encoding.UTF8;
            str = CharStreams.fromPath(input, enc);
        }
        else {
            var encoding = Encoding.GetEncoding(
                file_encoding,
                new EncoderReplacementFallback("(unknown)"),
                new DecoderReplacementFallback("(error)"));
            if (encoding == null)
                throw new Exception(@"Unknown encoding. Must be an Internet Assigned Numbers Authority (IANA) code page name. https://www.iana.org/assignments/character-sets/character-sets.xhtml");
            str = CharStreams.fromPath(input, encoding);
        }
        DoParse(str, input, row_number);
    }

    static void DoParse(ICharStream str, string input_name, int row_number)
    {
        var lexer = new CSharpLexer(str);
        CommonTokenStream tokens = null;
        tokens = new CommonTokenStream(lexer);
        var parser = new CSharpParser(tokens);
        var output = System.Console.Error;
        DateTime before = DateTime.Now;
        var tree = parser.prog();
        DateTime after = DateTime.Now;
    }
}

