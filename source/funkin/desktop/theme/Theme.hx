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
     * CAPTION & WINDOW
     */
    public var window:ThemeData = new ThemeData();
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

    /**
     * CHECKBOX
     */
    public var checkbox:ThemeData = new ThemeData();

    /**
     * TABS
     */
    public var tabBackground:ThemeData = new ThemeData();
    public var tabButtonSelected:ThemeData = new ThemeData();
    public var tabButtonUnselected:ThemeData = new ThemeData();
    public var tabButtonHover:ThemeData = new ThemeData();
    public var tabButtonPressed:ThemeData = new ThemeData();

    /**
     * CONTEXT MENU
     */
    public var contextBackground:ThemeData = new ThemeData();
    public var contextOption:ThemeData = new ThemeData();

    /**
     * MENU BAR
     */
    public var menuBar:ThemeData = new ThemeData();

    /**
     * THEME
     */
    public var textbox:ThemeData = new ThemeData();
    public var textboxHover:ThemeData = new ThemeData();
    public var textboxPressed:ThemeData = new ThemeData();
    public var textboxFocused:ThemeData = new ThemeData();

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
                if (element.has.font) data.font = element.att.font;
                if (element.has.color) data.color = element.att.color.getColorFromDynamic();
                if (element.has.fontSize) data.fontSize = Std.parseFloat(element.att.fontSize).getDefault(0);
                if (element.has.left) data.left = Std.parseFloat(element.att.left).getDefault(0);
                if (element.has.right) data.right = Std.parseFloat(element.att.right).getDefault(0);
                if (element.has.top) data.top = Std.parseFloat(element.att.top).getDefault(0);
                if (element.has.bottom) data.bottom = Std.parseFloat(element.att.bottom).getDefault(0);
                if (element.has.width) data.width = Std.parseFloat(element.att.width).getDefault(data.width);
                if (element.has.height) data.height = Std.parseFloat(element.att.height).getDefault(data.height);
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
            Logs.trace('Failed to load Desktop Theme: $e', ERROR);
        }
    }
}

class ThemeData implements IFlxDestroyable {
    public var sprite:String = "";

    public var font:String = null;
    public var fontSize:Null<Float> = null;

    public var textColor:Null<FlxColor> = null;
    public var color:FlxColor = FlxColor.WHITE;

    public var left:Float = 4;
    public var bottom:Float = 4;
    public var top:Float = 4;
    public var right:Float = 4;

    public var width:Float = 4;
    public var height:Float = 4;

    public var margin:FlxPoint = FlxPoint.get(0, 0);
    public var size:FlxPoint = FlxPoint.get(20, 20);
    public var offset:FlxPoint = FlxPoint.get(5, 5);


    public function new() {}

    public function destroy() {
        if (margin != null)
            margin.put();
        if (size != null)
            size.put();
        if (offset != null)
            offset.put();
    }
}