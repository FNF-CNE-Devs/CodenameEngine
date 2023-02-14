package funkin.options.type;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import funkin.ui.Alphabet;
import flixel.math.FlxMath;

@:allow()
class NumberOption extends TextOption {

    /**
	 * The text which shows the current number value.
	 */
    public var number:Alphabet;

    /**
	 * The current value.
	 */
    public var value:Float;

    /**
	 * Minimum possible value
	 */
    public var min:Float;

    /**
	 * Maximum possible value
	 */
    public var max:Float;

    /**
	 * The rate at which the value increases upon change.
	 */
    public var step:Float;

    /**
	 * The name of the option.
	 */
    public var optionName:String;

    public function new(text:String, desc:String, optionName:String, min:Float, max:Float, ?interval:Float = 1) {
        super(text, desc, null);
        number = new Alphabet(__text.width+140, -30, Reflect.field(Options, optionName));
        number.color = 0x000000;
        add(number);
        this.optionName = optionName;
        this.value = optionName.length > 0 ? Reflect.field(Options, optionName) : min;
        this.step = interval;
        this.min = min;
        this.max = max;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (selected) changeValue((controls.LEFT_P ? -step : 0) + (controls.RIGHT_P ? step : 0));
    }

    public function changeValue(v:Float)
    {
        if (v==0) return;
        value = FlxMath.bound(value+v,min,max);
        number.text = Std.string(value);
        Reflect.setField(Options, optionName, value);
    }
}