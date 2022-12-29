package funkin.desktop.sprites;

import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxObject;

class Checkbox extends WindowText {
    public var checked:CheckState = UNCHECKED;
    public var disabled:Bool = false;
    public var checkboxSprite:FlxSprite;

    public function new(x:Float, y:Float, w:Float, t:String, checked:CheckState = UNCHECKED) {
        super(x, y, w, t);
        this.checked = checked;
        offset.x -= 20;

        var t = DesktopMain.theme.checkbox;

        checkboxSprite = new FlxSprite(0, (20 - t.height) / 2);
        checkboxSprite.loadGraphic(Paths.image(t.sprite), true, Std.int(t.width), Std.int(t.height));
        checkboxSprite.animation.add("checkbox", [for(i in 0...checkboxSprite.frames.frames.length) i], 0, true);
        checkboxSprite.animation.play("checkbox");

        scrollFactor.set();
    }

    public function setChecked(checked:Bool) {
        this.checked = cast checked;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        checkboxSprite.update(elapsed);

        var overlaps = DesktopMain.mouseInput.overlapsRect(this, new FlxRect(x, y, width + 20, height), camera);
        var pressed = DesktopMain.mouseInput.pressed;

        if (overlaps) {
            // cancel so that sprites in the bg dont get hovered as well
            if (!disabled && DesktopMain.mouseInput.justPressed) {
                checked = switch(checked) {
                    case CHECKED | BOTH:
                        UNCHECKED;
                    case UNCHECKED:
                        CHECKED;
                }
            }
            DesktopMain.mouseInput.cancel();
        }

        checkboxSprite.animation.curAnim.curFrame = (switch(checked) {
            case UNCHECKED: 0;
            case CHECKED: 1;
            case BOTH: 2;
        }) + (disabled ? 9 : (overlaps ? (pressed ? 6 : 3) : 0));
    }

    public override function draw() {
        checkboxSprite.copyProperties(this);
        rotOffset.y = (this.height - checkboxSprite.height) / 2;
        super.draw();
        checkboxSprite.draw();
    }
}

@:enum
abstract CheckState(Null<Bool>) from Null<Bool> to Null<Bool> from Bool to Bool {
    var CHECKED:CheckState = true;
    var UNCHECKED:CheckState = false;
    var BOTH:CheckState = null;
}