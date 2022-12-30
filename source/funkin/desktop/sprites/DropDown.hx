package funkin.desktop.sprites;

import funkin.desktop.theme.Theme.ThemeData;
import flixel.math.FlxPoint;

class DropDown extends Button {
    public var selectedIndex:Int = -1;
    public var onChange:Int->Void;
    public var options:Array<String>;

    public function new(x:Float, y:Float, w:Float, options:Array<String>, onChange:Int->Void, curId:Int = 0, ?normalButton:ThemeData, ?hoverButton:ThemeData, ?pressedButton:ThemeData, ?disabledButton:ThemeData) {
        super(x, y, "", onClick, normalButton, hoverButton, pressedButton, disabledButton);
        this.options = options;
        onSelectionChange(curId);
        this.onChange = onChange;
    }

    public function onClick() {
        var pos:FlxPoint = getScreenPosition(null, camera);
        pos.y += height;
        
        var camPos = camera != null ? FlxPoint.get(camera.x, camera.y) : FlxPoint.get();

        ContextMenu.open(pos.x + camPos.x, pos.y + camPos.y, [for(o in options) {
            {
                name: o
            }
        }], onSelectionChange);

        pos.put();
        camPos.put();
    }

    public function onSelectionChange(id:Int) {
        selectedIndex = id;
        label.text = options[id];
        if (onChange != null)
            onChange(id);
    }
}