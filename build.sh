# Generated from trgen 0.23.44
set -e
if [ -f transformGrammar.py ]; then python3 transformGrammar.py ; fi

version=`dotnet trxml2 Other.csproj | fgrep 'PackageReference/@Version' | awk -F= '{print $2}'`

java -jar 'C:\msys64\home\Kenne\issues\a4-4938\tool\target\antlr4-4.13.3-SNAPSHOT-complete.jar'  -encoding utf-8 -Dlanguage=CSharp   CSharpLexer.g4
java -jar 'C:\msys64\home\Kenne\issues\a4-4938\tool\target\antlr4-4.13.3-SNAPSHOT-complete.jar'  -encoding utf-8 -Dlanguage=CSharp   CSharpParser.g4


dotnet restore Test.csproj
dotnet build Test.csproj

exit 0
