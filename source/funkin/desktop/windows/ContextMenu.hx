package funkin.desktop.windows;

import flixel.FlxSprite;
import funkin.desktop.sprites.*;
import flixel.FlxObject;
import flixel.FlxG;

class ContextMenu extends WindowGroup<FlxObject> {
    public var bg:SpliceSprite;
    public var texts:Array<WindowText> = [];
    public var selectionBGs:Array<FlxSprite> = [];

    public override function new(x:Float, y:Float, options:Array<ContextOption>, callback:Int->Void) {
        super();
        
        var bgTheme = DesktopMain.theme.contextBackground;
        var optionTheme = DesktopMain.theme.contextOption;

        bg = new SpliceSprite(Paths.image(bgTheme.sprite), 0, 0, 75, 24, bgTheme.left, bgTheme.top, bgTheme.bottom, bgTheme.right);
        add(bg);

        var lastOption:FlxSprite = null;
        var w:Float = 80;
        for(k=>o in options) {
            var selectSpr = new FlxSprite(bgTheme.left, bgTheme.top + (k * optionTheme.height));
            selectSpr.loadGraphic(Paths.image(bgTheme.sprite));
            selectSpr.setGraphicSize(10, Std.int(optionTheme.height));
            selectionBGs.push(selectSpr);
            add(selectSpr);

            var text = new WindowText(4, 4, 0, o.name);
            text.y = selectSpr.y + ((selectSpr.height - text.height) / 2);
            texts.push(text);
            add(text);
            if (w < text.width)
                w = text.width;
        }
    }

    public override function destroy() {
        super.destroy();
        FlxG.cameras.remove(camera, true);
    }
}

typedef ContextOption = {
    var name:String;
    @:optional var callback:Void->Void;
    @:optional var iconPath:String;
    @:optional var iconId:Int;
}