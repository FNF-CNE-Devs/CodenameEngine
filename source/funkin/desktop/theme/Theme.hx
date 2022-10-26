package funkin.desktop.theme;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import haxe.xml.Access;
import openfl.Assets;

class Theme {
    public static function loadFromAssets(path:String) {
        return load(Assets.getText(path));
    }

    public static function loadFromPath(path:String) {
        #if sys
        return load(sys.io.File.getContent(path));
        #else
        return null;
        #end
    }

    public static function load(content:String):Theme {
        return new Theme(content);
    }

    /**
     * CAPTION
     */
    public var captionActive:ThemeData = new ThemeData();
    public var captionInactive:ThemeData = new ThemeData();
    public var captionButtons:ThemeData = new ThemeData();

    /**
     * BUTTON
     */
    public var normalButton:ThemeData = new ThemeData();
    public var hoverButton:ThemeData = new ThemeData();
    public var pressedButton:ThemeData = new ThemeData();
    public var disabledButton:ThemeData = new ThemeData();

    public function new(content:String) {
        try {
            var access = new Access(Xml.parse(content).firstElement());
            var prefix = '';
            if (access.has.folder) prefix = access.att.folder.trim();
            for(element in access.elements) {
                var name:String = element.name.trim();
                if (!Type.getInstanceFields(Theme).contains(name)) continue;
                var field = Reflect.field(this, name);
                if (!(field is ThemeData)) continue;
                var data = cast(field, ThemeData);

                if (element.has.path) data.sprite = '$prefix${element.att.path.trim()}';
                if (element.has.textColor) data.textColor = element.att.textColor.getColorFromDynamic();
                if (element.has.left) data.left = Std.parseFloat(element.att.left).getDefault(0);
                if (element.has.right) data.right = Std.parseFloat(element.att.right).getDefault(0);
                if (element.has.top) data.top = Std.parseFloat(element.att.top).getDefault(0);
                if (element.has.bottom) data.bottom = Std.parseFloat(element.att.bottom).getDefault(0);
                if (element.has.size) {
                    var split = element.att.size.split(",");
                    data.size.set(
                        Std.parseFloat(split[0]).getDefault(data.size.x),
                        Std.parseFloat(split[1]).getDefault(data.size.y));
                }
                if (element.has.margin) {
                    var split = element.att.margin.split(",");
                    data.margin.set(
                        Std.parseFloat(split[0]).getDefault(data.margin.x),
                        Std.parseFloat(split[1]).getDefault(data.margin.y));
                }
                if (element.has.offset) {
                    var split = element.att.offset.split(",");
                    data.offset.set(
                        Std.parseFloat(split[0]).getDefault(data.offset.x),
                        Std.parseFloat(split[1]).getDefault(data.offset.y));
                }

            }
        } catch(e) {
            // TODO: logs system
            trace(e.details());
        }
    }
}

class ThemeData implements IFlxDestroyable {
    public var sprite:String = "";

    public var textColor:FlxColor = FlxColor.WHITE;

    public var left:Float = 4;
    public var bottom:Float = 4;
    public var top:Float = 4;
    public var right:Float = 4;

    public var margin:FlxPoint = FlxPoint.get(0, 0);
    public var size:FlxPoint = FlxPoint.get(20, 20);
    public var offset:FlxPoint = FlxPoint.get(5, 5);


    public function new() {}

    public function destroy() {
        if (margin != null) {
            margin.put();
            margin = null;
        }
        if (size != null) {
            size.put();
            size = null;
        }
        if (offset != null) {
            offset.put();
            offset = null;
        }
    }
}