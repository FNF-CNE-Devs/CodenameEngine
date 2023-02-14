package funkin.options.type;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import funkin.ui.Alphabet;
import flixel.math.FlxMath;
using StringTools;

// unused, might not work idk
@:allow()
class StringOption extends TextOption {

    /**
	 * The text which shows the current number value.
	 */
    public var number:Alphabet;

    /**
	 * The current string value.
	 */
    public var value:String;

    /**
	 * Array of all possible string values.
	 */
    public var valueArray:Array<String>;

    /**
	 * Current index of the selected option.
	 */
    public var curSelected:Int = 0;

    /**
	 * Name of the option.
	 */
    public var optionName:String;

    public function new(text:String, desc:String, optionName:String, array:Array<String>) {
        super(text, desc, null);

        number = new Alphabet(__text.width+140, -30, Reflect.field(Options, optionName));
        number.color = 0x000000;
        add(number);

        this.optionName = optionName;
        this.value = Reflect.field(Options, optionName);
        this.valueArray = array;
        this.curSelected = Math.max(valueArray.indexOf(value), 0); // prevent returning -1
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (selected) change((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
    }

    public function change(v:Int)
    {
        if (v==0) return;
        
        curSelected = FlxMath.wrap(curSelected+v,0,valueArray.length-1);
        number.text = value = valueArray[curSelected];
        Reflect.setField(Options, optionName, value);
    }
}