package funkin.options;

import funkin.options.type.OptionType;

class OptionsScreen extends FlxTypedSpriteGroup<OptionType> {
    public static var optionHeight:Float = 120;

    public var parent:OptionsTree;

    public var curSelected:Int = 0;
    public var id:Int = 0;

    private var __firstFrame:Bool = true;

    public function new() {
        super();
        // EXTEND then add options
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        var controls = PlayerSettings.solo.controls;

        changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel);
        x = id * FlxG.width;
        for(k=>option in members) {
            var y:Float = ((FlxG.height - optionHeight) / 2) + ((k - curSelected) * optionHeight);
            
            option.selected = false;
            option.y = __firstFrame ? y : CoolUtil.fpsLerp(option.y, y, 0.25);
            option.x = x + (-50 + (Math.abs(Math.cos((option.y + (optionHeight / 2) - (FlxG.camera.scroll.y + (FlxG.height / 2))) / (FlxG.height * 1.25) * Math.PI)) * 150));
        }

        __firstFrame = false;

        if (members.length > 0) {
            members[curSelected].selected = true;
            if (controls.ACCEPT || FlxG.mouse.justReleased)
                members[curSelected].onSelect();
        }
        if (controls.BACK || FlxG.mouse.justReleasedRight)
            close();
    }

    public function close() {
        onClose(this);
    }

    public function changeSelection(sel:Int) {
        if (members.length <= 0 || sel == 0) return;

        CoolUtil.playMenuSFX(SCROLL);

        curSelected = FlxMath.wrap(curSelected + sel, 0, members.length-1);

        for(o in members)
        members[curSelected].selected = true;
    }

    public dynamic function onClose(o:OptionsScreen) {}
}