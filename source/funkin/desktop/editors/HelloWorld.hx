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

        var tabs = new TabView(330, 10, 300, 500, ["Tab 1", "Tab 2", "Tab 3"]);
        tabs.updateAnchor(1, 0);
        add(tabs);


        var checkbox = new Checkbox(10, 40, 0, "Test Checkbox", CHECKED);
        var text = new WindowText(10, 10, 180, "Stuff in page 1");
        tabs.tabs[0].add(text);
        tabs.tabs[0].add(checkbox);

        var text2 = new WindowText(10, 10, 180, "Stuff in page 2");
        tabs.tabs[1].add(text2);

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