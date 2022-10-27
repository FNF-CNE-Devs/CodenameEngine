package funkin.desktop.editors;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;

class HelloWorld extends WindowContent {
    public override function new() {
        super("Test Window", 100, 100, 640, 480);
    }

    public override function create() {
        super.create();

        var helloWorldText = new WindowText(0, 0, 0, "Hello, World!");
        helloWorldText.scrollFactor.set(0.5, 0.5);
        helloWorldText.cameraCenter(camera);
        add(helloWorldText);

        var t = new WindowText(0, 0, 0, "Bottom right text!");
        t.setPosition(630 - t.width, 470 - t.height);
        t.scrollFactor.set(1, 1);
        add(t);

        var t = new WindowText(0, 0, 0, "Top right text!");
        t.setPosition(630 - t.width, 10);
        t.scrollFactor.set(1, 0);
        add(t);

        var butt = new Button(10, 10, "Test", function() {
            parent.showMessage("Test", "Test", ERROR);
        });
        butt.scrollFactor.set();
        add(butt);
    }

    public var time:Float = 0;
    public var coolAssMode:Bool = false;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        time += elapsed;

        if (FlxG.keys.justPressed.M) coolAssMode = !coolAssMode;

        if (coolAssMode) {
            width = 500 + Std.int(Math.cos(time * Math.PI) * 250);
            height = 500 + Std.int(Math.sin(time * Math.PI) * 250);
        }
        parent.updateWindowFrame();
    }
}