package funkin.options.type;

import flixel.effects.FlxFlicker;

class TextOption extends OptionType {
	public var selectCallback:Void->Void;

	private var __text:Alphabet;

	public var text(get, set):String;
	private function get_text() {return __text.text;}
	private function set_text(v:String) {return __text.text = v;}

	public function new(text:String, desc:String, selectCallback:Void->Void) {
		super(desc);
		this.selectCallback = selectCallback;
		add(__text = new Alphabet(100, 20, text, true));
	}

	public override function draw() {
		super.draw();
	}
	public override function onSelect() {
		super.onSelect();
		CoolUtil.playMenuSFX(CONFIRM);
		FlxFlicker.flicker(this, 1, Options.flashingMenu ? 0.06 : 0.15, true, false);
		selectCallback();
	}
}