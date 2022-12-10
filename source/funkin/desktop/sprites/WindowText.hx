package funkin.desktop.sprites;

import flixel.text.FlxText;
import flixel.addons.ui.FlxUIText;
import funkin.desktop.theme.Theme.ThemeData;

class WindowText extends FlxText
{
	public function new(x:Float, y:Float, w:Float, t:String)
	{
		super(x, y, w, t);
		color = 0xFF000000;
		scrollFactor.set();
		applyFontSettings(DesktopMain.theme.window);
		// setFormat(Paths.font(.font))
	}

	public function applyFontSettings(data:ThemeData)
	{
		var fontPath = Paths.font(data.font);
		if (data.font.startsWith("file://"))
		{
			fontPath = data.font.substr(7);
			while (fontPath.charAt(0) == "/")
				fontPath = fontPath.substr(1);
		}
		setFormat(fontPath, Std.int(data.fontSize), data.textColor);
	}
}
