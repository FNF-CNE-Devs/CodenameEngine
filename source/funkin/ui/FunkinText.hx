package funkin.ui;

import flixel.util.FlxColor;
import flixel.text.FlxText;

class FunkinText extends FlxText {
    public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 16, EmbeddedFont:Bool = true) {
        super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
        setFormat(Paths.font("vcr.ttf"), Size, FlxColor.WHITE);
        borderStyle = OUTLINE;
        borderSize = 1;
        borderColor = 0xFF000000;
    }
}