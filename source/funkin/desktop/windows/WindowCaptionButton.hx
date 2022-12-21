package funkin.desktop.windows;

import flixel.FlxSprite;

class WindowCaptionButton extends FlxSprite {
    public var icon:FlxSprite;
    public var window:Window;

    public static var anims:Array<String> = ["close", "maximize", "minimize", "help", "restore"];

    public function new(window:Window, i:Int) {
        super(0, 0);
        this.window = window;
        ID = i;

        loadGraphic(Paths.image(DesktopMain.theme.captionButtons.sprite), true, Std.int(DesktopMain.theme.captionButtons.size.x), Std.int(DesktopMain.theme.captionButtons.size.y));

        for(k=>e in anims) {
            animation.add(e, [for(l in 0...8) k + (l * anims.length)], 0, true);
        }
        animation.play(anims[ID]);
    }

    public override function draw() {
        super.draw();
    }

    public override function update(elapsed:Float) {
        if (animation.curAnim == null) {
            super.update(elapsed);
            return;
        }
        var mouseInput = DesktopMain.mouseInput;

        visible = switch(ID) {
            case 1 | 2: window.resizeable || window.canMinimize;
            case 3: window.canHelp;
            default: true;
        };

        if(switch(ID) {
            case 0:     window.canClose;
            case 1:     window.resizeable;
            case 2:     window.canMinimize;
            case 3:     window.canHelp;
            default:    true;
        }) {
            if (DesktopMain.mouseInput.overlaps(this, camera)) {
                if (mouseInput.justReleased) {
                    switch(ID) {
                        case 0:
                            if (window.canClose) window.close();
                        case 1:
                            if (window.resizeable) (window.maximized ? window.restore : window.maximize)();
                        case 2:
                            if (window.canMinimize) window.minimize();
                    }
                    mouseInput.cancel();
                    return;
                }
                if (mouseInput.pressed || mouseInput.justPressed) {
                    animation.curAnim.curFrame = 2;
                } else {
                    animation.curAnim.curFrame = 1;
                }
                mouseInput.cancel(); // prevents controls behind this one from updating input
            } else
                animation.curAnim.curFrame = 0;
        } else {
            animation.curAnim.curFrame = 3;
        }
        if (!window.focused) animation.curAnim.curFrame += 4;

        super.update(elapsed);
    }
}