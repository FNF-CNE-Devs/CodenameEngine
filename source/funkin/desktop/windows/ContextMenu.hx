package funkin.desktop.windows;

import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.FlxSprite;
import funkin.desktop.sprites.*;
import flixel.FlxObject;
import flixel.FlxG;

class ContextMenu extends WindowGroup<FlxObject> {
    public var bg:SpliceSprite;
    public var texts:Array<WindowText> = [];
    public var selectionBGs:Array<FlxSprite> = [];
    public var callback:Int->Void;
    public var contextOptions:Array<ContextOption> = [];
    public var contextCamera:FlxCamera;

    public override function new(x:Float, y:Float, options:Array<ContextOption>, callback:Int->Void) {
        super();
        this.callback = callback;
        this.contextOptions = options;
        
        var bgTheme = DesktopMain.theme.contextBackground;
        var optionTheme = DesktopMain.theme.contextOption;

        bg = new SpliceSprite(Paths.image(bgTheme.sprite), 0, 0, 75, 24, bgTheme.left, bgTheme.top, bgTheme.bottom, bgTheme.right);
        add(bg);

        var lastOption:FlxSprite = null;
        var w:Float = 80;
        for(k=>o in options) {
            var selectSpr = new FlxSprite(bgTheme.left, bgTheme.top + (k * optionTheme.height));
            selectSpr.loadGraphic(Paths.image(optionTheme.sprite));
            selectSpr.setGraphicSize(10, Std.int(optionTheme.height));
            selectSpr.visible = false;
            selectionBGs.push(selectSpr);
            add(selectSpr);

            var text = new WindowText(4, 4, 0, o.name);
            text.y = selectSpr.y + ((selectSpr.height - text.height) / 2);
            text.applyFontSettings(bgTheme);
            texts.push(text);
            add(text);
            if (w < text.width)
                w = text.width;

            lastOption = selectSpr;
        }
        var ow = Std.int(w) + 20;
        for(o in selectionBGs) {
            o.setGraphicSize(ow, Std.int(optionTheme.height));
            o.updateHitbox();
        }
        bg.resize(bgTheme.left + ow + bgTheme.right, lastOption.y + lastOption.height + bgTheme.bottom);
        contextCamera = camera = new FlxCamera(Std.int(x), Std.int(y), Std.int(bg.width), Std.int(bg.height));
        contextCamera.pixelPerfectRender = true;
        contextCamera.bgColor = 0;
        FlxG.cameras.add(contextCamera, false);
    }

    public static function open(x:Float, y:Float, options:Array<ContextOption>, callback:Int->Void) {
        DesktopMain.contextMenu = new ContextMenu(x, y, options, callback);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (DesktopMain.mouseInput.overlaps(bg, contextCamera)) {
            for(i=>o in selectionBGs) {
                var wasVisible = o.visible;
                if (o.visible = DesktopMain.mouseInput.overlaps(o, contextCamera)) {
                    if (DesktopMain.mouseInput.justReleased) {
                        // select option
                        if (contextOptions[i].callback != null)
                            contextOptions[i].callback();
                        if (callback != null)
                            callback(i);
                        destroy();
                        return;
                    }
                }
                if (o.visible != wasVisible) {
                    texts[i].applyFontSettings(o.visible ? DesktopMain.theme.contextOption : DesktopMain.theme.contextBackground);
                }
            }
            DesktopMain.mouseInput.cancel();
        } else {
            if (DesktopMain.mouseInput.justPressed) {
                destroy();
                return;
            }
        }
    }

    public override function destroy() {
        FlxG.cameras.remove(contextCamera, true);
        DesktopMain.contextMenu = null;
        super.destroy();
    }
}

typedef ContextOption = {
    var name:String;
    @:optional var callback:Void->Void;
    @:optional var iconPath:String;
    @:optional var iconId:Int;
}