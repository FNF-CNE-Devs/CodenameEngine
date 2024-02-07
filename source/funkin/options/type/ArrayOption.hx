package funkin.options.type;

import flixel.effects.FlxFlicker;

class ArrayOption extends OptionType {
	public var selectCallback:String->Void;

	private var __text:Alphabet;
	private var __selectiontext:Alphabet;

	public var options:Array<Dynamic>;

	public var currentSelection:Int;

	var optionName:String;

	public var parent:Dynamic;

	public var text(get, set):String;
	private function get_text() {return __text.text;}
	private function set_text(v:String) {return __text.text = v;}

	public function new(text:String, desc:String, options:Array<Dynamic>, optionName:String, ?selectCallback:String->Void = null, ?parent:Dynamic) {
		super(desc);
		this.selectCallback = selectCallback;
		this.options = options;
		if (parent == null)
			parent = Options;

		this.parent = parent;

		if(Reflect.field(parent, optionName) != null)
			this.currentSelection = options.indexOf(Reflect.field(parent, optionName));
		
		this.optionName = optionName;
		
		add(__text = new Alphabet(100, 20, text, true));
		add(__selectiontext = new Alphabet(__text.width + 120, -30, formatTextOption(), false));
	}

	public override function draw() {
		super.draw();
	}

	public override function onChangeSelection(change:Float):Void
	{
		if(currentSelection <= 0 && change == -1 || currentSelection >= options.length - 1 && change == 1 ) return;
		currentSelection += Math.round(change);
		__selectiontext.text = formatTextOption();
		Reflect.setField(parent, optionName, options[currentSelection]);
		if(selectCallback != null)
			selectCallback(options[currentSelection]);
	}

	private function formatTextOption() {
		var currentOptionString = ": ";
		if((currentSelection > 0))
			currentOptionString += "< ";
		else
			currentOptionString += "  ";

		currentOptionString +=  options[currentSelection];

		if(!(currentSelection >= options.length - 1))
			currentOptionString += " >";

		return currentOptionString;
	}
}