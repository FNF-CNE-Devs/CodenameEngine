@ECHO OFF
cd ..
echo Building Game...
lime build windows --haxeflag="--macro include('scripting')" --haxeflag="-xml docs/doc.xml" -D DOCUMENTATION --no-output
echo art

echo Generated the api xml file at docs/doc.xml
echo Please put this in FNF-CNE-Devs.github.io/api-generator/api/doc.xml