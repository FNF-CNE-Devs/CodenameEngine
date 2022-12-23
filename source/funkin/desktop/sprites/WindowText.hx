package funkin.desktop.sprites;

import flixel.text.FlxText;
import flixel.addons.ui.FlxUIText;
import funkin.desktop.theme.Theme.ThemeData;

class WindowText extends FlxText {
    public function new(x:Float, y:Float, w:Float, t:String) {
        super(x, y, w, t);
        color = 0xFF000000;
        scrollFactor.set();
        size = 12;
        applyFontSettings(DesktopMain.theme.window);

        scrollFactor.set();
    }

    public function applyFontSettings(data:ThemeData) {
        if (data.font != null) {
            var fontPath:String;
            if (data.font.startsWith("file://")) {
                fontPath = data.font.substr(7);
                while(fontPath.charAt(0) == "/") fontPath = fontPath.substr(1);
            } else {
                fontPath = Paths.font(data.font);
            }
            font = fontPath;
        }
        if (data.fontSize != null)
            size = Std.int(data.fontSize);
        if (data.textColor != null)
            color = data.textColor;
    }
}