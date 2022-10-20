package funkin.desktop.editors;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.addons.ui.FlxUIText;

class HelloWorld extends WindowContent {
    public override function new() {
        super("Test Window", 0, 0, 640, 480);
    }

    public override function create() {
        super.create();

        var helloWorldText = new FlxUIText(0, 0, 0, "Hello, World!");
        helloWorldText.color = 0xFF000000;
        helloWorldText.scrollFactor.set(0.5, 0.5);
        helloWorldText.cameraCenter(camera);
        add(helloWorldText);
    }
}