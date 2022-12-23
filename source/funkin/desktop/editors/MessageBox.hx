package funkin.desktop.editors;

import flixel.util.typeLimit.OneOfTwo;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;

class MessageBox extends WindowContent {
    public var caption:String;
    public var message:String;
    public var msgIcon:MessageBoxIcon;
    public var callback:Int->Void = null;
    private var __buttons:Array<OneOfTwo<String, Butt>> = null;

    public override function new(caption:String, message:String, icon:MessageBoxIcon, ?buttons:Array<OneOfTwo<String, Butt>>, ?callback:Int->Void) {
        super(caption, 100, 100, 500, 500);
        this.caption = caption;
        this.message = message;
        this.msgIcon = icon;
        this.callback = callback;
        this.__buttons = buttons;
    }

    public override function create() {
        super.create();
        parent.canMinimize = parent.resizeable = false;
        var text = new WindowText(10, 10, 0, message);
        if (text.width > 500)
            text.fieldWidth = 500;
        add(text);
        setSize(Std.int(Math.max(text.width + 20, 240)), Std.int(text.height + 20));


        if (__buttons == null || __buttons.length <= 0) __buttons = ["OK"];

        var firstButt:Button = null;
        for(k=>b in __buttons) {
            var label:String = null;
            var callback:Void->Void = null;
            if (b is String) {
                label = cast(b, String);
            } else if (b is Dynamic) {
                label = Reflect.field(b, "label");
                callback = Reflect.field(b, "callback");
            }
            var button = new Button(490, 490, label, function() {
                parent.close();
                if (callback != null) callback();
                if (this.callback != null) this.callback(k);
            });
            button.x -= button.width;
            button.y -= button.height;
            button.scrollFactor.set(1, 1);
            add(button);
            if (firstButt == null) firstButt = button;
        }
        setSize(Std.int(width), Std.int(height + firstButt.height + 10));
    }
}

@:enum
abstract MessageBoxIcon(Int) {
    var ERROR = 0;
    var ALERT = 1;
    var INFORMATION = 2;
    var QUESTION = 3;
}

// HAHA BUTT!! *minion laugh*
typedef Butt = {
    var label:String;
    @:optional var callback:Void->Void;
}