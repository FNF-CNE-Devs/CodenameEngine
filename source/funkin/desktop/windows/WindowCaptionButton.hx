package funkin.desktop.windows;

import flixel.FlxSprite;

class WindowCaptionButton extends FlxSprite {
    public var icon:FlxSprite;
    public var window:Window;

    public static var anims:Array<String> = ["minimize", "maximize", "close", "restore", "help"];

    public function new(window:Window, i:Int) {
        // super(0, 0, "", function() {
        //     switch(i) {
        //         case 0:
        //             window.close();
        //     }
        // });
        super(0, 0);
        this.window = window;
        ID = i;

        loadGraphic(Paths.image(DesktopMain.theme.captionButtons.sprite), true, Std.int(DesktopMain.theme.captionButtons.size.x), Std.int(DesktopMain.theme.captionButtons.size.y));

        for(k=>e in anims) {
            animation.add(e, [for(l in 0...6) k + (l * anims.length)], 0, true);
        }
        animation.play(anims[ID]);

        // resize(18, 18);
        // color = (i > 0) ? 0xFF8888FF : 0xFFFF0000;
    }

    public override function draw() {
        super.draw();
    }

    public override function update(elapsed:Float) {
        if (animation.curAnim == null) {
            super.update(elapsed);
            return;
        }
        var mouseInput = DesktopMain.instance.mouseInput;
        if (DesktopMain.instance.mouseInput.overlaps(this, camera)) {
            if (mouseInput.justReleased) {
                switch(ID) {
                    case 0:
                        window.close();
                    case 1:
                        
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
        if (!window.focused) animation.curAnim.curFrame += 3;

        super.update(elapsed);
    }
}