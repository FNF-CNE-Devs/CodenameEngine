package funkin.editors;

import funkin.editors.ui.*;

class UIDebugState extends UIState {
    public override function create() {
        var bg = new FlxSprite().makeGraphic(0xFF888888);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        add(bg);

        super.create();
        add(new UICheckbox(10, 10, "Test unchecked", false));
        add(new UICheckbox(10, 40, "Test checked", true));
    }
}