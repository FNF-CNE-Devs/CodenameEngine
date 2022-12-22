package funkin.desktop.sprites;

import funkin.desktop.theme.Theme;
import flixel.FlxObject;
import flixel.addons.ui.FlxUIText;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import funkin.desktop.windows.WindowGroup;

class Button extends FlxObject {
    public var callback:Void->Void;

    public var disabled:Bool = false;

    public var frame:Int = 0;

    public var normalSprite:SpliceSprite;
    public var hoverSprite:SpliceSprite;
    public var pressedSprite:SpliceSprite;
    public var disabledSprite:SpliceSprite;

    public var label:WindowText;

    private override function get_width() {
        return normalSprite.width;
    }

    private override function get_height() {
        return normalSprite.height;
    }
    
    public function new(x:Float, y:Float, text:String = "", callback:Void->Void) {
        super();
        this.x = x; 
        this.y = y;
        this.width = 75;
        this.height = 24;
        this.callback = callback;

        var normalButton = DesktopMain.theme.normalButton;
        var hoverButton = DesktopMain.theme.hoverButton;
        var pressedButton = DesktopMain.theme.pressedButton;
        var disabledButton = DesktopMain.theme.disabledButton;

        normalSprite = new SpliceSprite(Paths.image(normalButton.sprite), x, y, 75, 24, normalButton.left, normalButton.top, normalButton.bottom, normalButton.right);
        hoverSprite = new SpliceSprite(Paths.image(hoverButton.sprite), x, y, 75, 24, hoverButton.left, hoverButton.top, hoverButton.bottom, hoverButton.right);
        pressedSprite = new SpliceSprite(Paths.image(pressedButton.sprite), x, y, 75, 24, pressedButton.left, pressedButton.top, pressedButton.bottom, pressedButton.right);
        disabledSprite = new SpliceSprite(Paths.image(disabledButton.sprite), x, y, 75, 24, disabledButton.left, disabledButton.top, disabledButton.bottom, disabledButton.right);

        label = new WindowText(0, 0, 75, text);
        label.alignment = CENTER;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        var mouseInput = DesktopMain.mouseInput;
        if (mouseInput.overlaps(normalSprite, camera)) {
            if (mouseInput.justReleased) {
                callback();
                return;
            }

            if (mouseInput.justPressed || mouseInput.pressed)
                frame = 2;
            else
                frame = 1;
            mouseInput.cancel();
        } else
            frame = 0;

        if (disabled) frame = 3;

        for(e in [normalSprite, hoverSprite, pressedSprite, disabledSprite])
            e.update(elapsed);

        label.color = switch(frame) {
            case 1:     DesktopMain.theme.hoverButton.textColor;
            case 2:     DesktopMain.theme.pressedButton.textColor;
            case 3:     DesktopMain.theme.disabledButton.textColor;
            default:    DesktopMain.theme.normalButton.textColor;
        }
    }

    public override function destroy() {
        for(e in [normalSprite, hoverSprite, pressedSprite, disabledSprite])
            e.destroy();
        scrollFactor.put();
        super.destroy();
    }

    public function resize(width:Float, height:Float) {
        this.width = width;
        this.height = height;
        normalSprite.resize(width, height);
        label.fieldWidth = width;
    }
    public override function draw() {
        super.draw();
        var spr = switch(frame) {
            case 1:     hoverSprite;
            case 2:     pressedSprite;
            case 3:     disabledSprite;
            default:    normalSprite;
        };
        spr.resize(width, height);
        for(sprite in [spr, label])
            sprite.copyProperties(this);
        spr.draw();
        label.y += (height - label.height) / 2;
        label.draw();
    }
}