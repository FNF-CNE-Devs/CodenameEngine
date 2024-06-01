package funkin.backend.system.framerate;

import openfl.text.TextFormat;
import openfl.display.Sprite;
import openfl.text.TextField;

class SafeModeChecker extends Sprite {
	public var safemode:TextField;

	public var isSafeMode:Bool;

	public function new()
	{
		super();

		isSafeMode = Options.safemode;

		safemode = new TextField();
		safemode.autoSize = LEFT;
		safemode.x = 0;
		safemode.y = 0;
		safemode.text = (isSafeMode) ? '[SAFE MODE]' : 'FPS';
		safemode.multiline = safemode.wordWrap = false;
		safemode.defaultTextFormat = new TextFormat(Framerate.fontName, 12, 0xFF00FF26, true);

		addChild(safemode);
	}

	public override function __enterFrame(t:Int)
	{
		if (alpha <= 0.05) return;
		super.__enterFrame(t);

		isSafeMode = Options.safemode;

		safemode.text = (isSafeMode) ? '[SAFE MODE]' : '';
	}
}