package funkin.desktop.sprites;

import funkin.desktop.theme.Theme.ThemeData;
import flixel.math.FlxPoint;

class DropDown extends Button {
    public var selectedIndex:Int = -1;
    public var onChange:Int->Void;
    public var options:Array<String>;

    public function new(x:Float, y:Float, options:Array<String>, onChange:Int->Void, curId:Int = 0, ?normalButton:ThemeData, ?hoverButton:ThemeData, ?pressedButton:ThemeData, ?disabledButton:ThemeData) {
        super(x, y, "", onClick, normalButton, hoverButton, pressedButton, disabledButton);
        this.options = options;
        onSelectionChange(curId);
    }

    public function onClick() {
        var pos:FlxPoint = getScreenPosition();
        pos.y += height;
        
        var camPos = camera != null ? FlxPoint.get(camera.x - (camera.scroll.x * scrollFactor.x), camera.y - (camera.scroll.y * scrollFactor.y)) : FlxPoint.get();

        ContextMenu.open(pos.x + camPos.x, pos.y + camPos.y, [for(o in options) {
            {
                name: o
            }
        }], onSelectionChange);

        camPos.put();
    }

    public function onSelectionChange(id:Int) {
        selectedIndex = id;
        label.text = options[id];
        if (onChange != null)
            onChange(id);
    }
}