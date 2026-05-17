# Generated from trgen 0.23.44
set -e

java -jar '../pr-antlr/tool/target/antlr4-4.13.3-SNAPSHOT-complete.jar'  -encoding utf-8 -Dlanguage=CSharp   CSharpLexer.g4
java -jar '../pr-antlr/tool/target/antlr4-4.13.3-SNAPSHOT-complete.jar'  -encoding utf-8 -Dlanguage=CSharp   CSharpParser.g4

dotnet restore Test.csproj
dotnet build -c Release Test.csproj

exit 0
