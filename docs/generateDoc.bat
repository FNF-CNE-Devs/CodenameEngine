@ECHO OFF
cd ..
echo Building Game...
lime build windows --haxeflag="--macro include('scripting')" --haxeflag="-xml docs/doc.xml"
echo Generating Documentation...
haxelib run dox -i docs --include funkin --include scripting
echo Done!