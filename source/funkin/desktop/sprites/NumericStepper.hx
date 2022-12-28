package funkin.desktop.sprites;

import flixel.math.FlxMath;

// TODO: FIX MEMORY GOING BRRRRRRRRRRRRRRRRRRRRR
class NumericStepper extends InputBox {
    public var decimals:Int = 0;
    public var increment:Float = 1;
    
    @:isVar public var value(get, set):Float = 0;

    public var onValueChange:Void->Void;

    public var addButton:Button;
    public var subButton:Button;

    public function new(x:Float, y:Float, w:Float, v:Float, ?onValueChange:Void->Void) {
        super(x, y, w, Std.string(v));
        addButton = new Button(w - (height * 2), 0, "+", onAdd);
        addButton.resize(height, height);

        subButton = new Button(w - (height), 0, "-", onSub);
        subButton.resize(height, height);

        onConfirm = onManualChange;
    }

    public override function resize(width:Float, height:Float) {
        super.resize(width - (height * 2), height);
    }

    public override function update(elapsed:Float) {
        addButton.update(elapsed);
        subButton.update(elapsed);
        super.update(elapsed);
    }

    public override function additionalDraw() {
        addButton.copyProperties(this);
        subButton.copyProperties(this);
        addButton.x += width;
        subButton.x += width + height;

        addButton.draw();
        subButton.draw();
    }

    private inline function onSub()
        value--;

    private inline function onAdd()
        value++;

    private function onManualChange() {
        var v = Std.parseFloat(text);
        if (!v.isNaN()) {
            value = round(v);
        } else {
            set_value(value);
        }
    }

    private function set_value(nv:Float) {
        if (this.value != (this.value = nv))
            if (onValueChange != null)
                onValueChange();
        text = Std.string(round(this.value));
        return this.value;
    }

    private inline function get_value()
        return this.value;

    private inline function round(value:Float) {
        return decimals <= 0 ? Std.int(value) : FlxMath.roundDecimal(value, decimals);
    }
}