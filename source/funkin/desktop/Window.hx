package funkin.desktop;

import flixel.group.FlxSpriteGroup;
import openfl.geom.Rectangle;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class Window extends FlxTypedSpriteGroup<FlxSprite> {
    public var windowFrame:FlxUI9SliceSprite;
    public var captionButtons:FlxTypedSpriteGroup<WindowCaptionButton>;

    public var windowWidth:Int = 0;
    public var windowHeight:Int = 0;

    public var windowCamera:FlxCamera;
    public var windowContentSprite:WindowContentSprite;

    public function new(caption:String, width:Int = 640, height:Int = 480, x:Int = 20, y:Int = 20) {
        super();
        windowFrame = new FlxUI9SliceSprite(0, 0, Paths.image('desktop/windowFrame'), new Rectangle(10, 10), [3, 3, 6, 6]);
        add(windowFrame);

        captionButtons = new FlxTypedSpriteGroup<WindowCaptionButton>();
        for(i in 0...3) {
            var btn = new WindowCaptionButton(this, i);
            btn.x = (i+1) * -18;
            captionButtons.add(btn);
        }
        add(captionButtons);

        windowWidth = width;
        windowHeight = height;

        scrollFactor.set(0.5, 0.5);
        updateWindowFrame();

        windowContentSprite = new WindowContentSprite(4, 23, FlxG.camera);
        add(windowContentSprite);
    }

    public function resize(width:Int, height:Int) {
        windowFrame.resize(width + 4 + 4, height + 23 + 4);

    }

    public function close() {
        DesktopMain.instance.windows.remove(this, true);
    }

    public function updateWindowFrame() {
        captionButtons.setPosition(windowWidth - 4, 4);
        windowFrame.resize(windowWidth, windowHeight);
    }
}