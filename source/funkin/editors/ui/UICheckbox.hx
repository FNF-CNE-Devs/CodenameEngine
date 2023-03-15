package funkin.editors.ui;

import funkin.ui.FunkinText;

class UICheckbox extends UISprite {
    public var checked:Bool = false;
    public var onChecked:Bool->Void = null;

    public var field:FunkinText;
    public var check:FlxSprite;

    public function new(x:Float, y:Float, text:String, checked:Bool = false, w:Int = 0) {
        super(x, y);
        loadGraphic(Paths.image('editors/ui/checkbox'), true, 20, 20);
        for(frame=>name in ["normal", "hover", "pressed", "checkmark"])
            animation.add(name, [frame], 0, false);

        this.checked = checked;

        field = new FunkinText(x, y, w, text, 14, false);
        check = new FlxSprite().loadGraphicFromSprite(this);
        check.animation.play("checkmark");

        members.push(check);
        members.push(field);
    }

    public override function update(elapsed:Float) {
        // ANIMATION HANDLING
        animation.play(hovered ? (pressed ? "pressed" : "hover") : "normal");

        // CHECKMARK HANDLING
        check.alpha = checked ? 1 : 0;
        check.scale.x = CoolUtil.fpsLerp(check.scale.x, 1, 0.25);
        check.scale.y = CoolUtil.fpsLerp(check.scale.y, 1, 0.25);

        // POSITION HANDLING
        updatePositions();

        super.update(elapsed);
    }

    public inline function updatePositions() {
        check.cameras = field.cameras = cameras;

        field.setPosition(x + 25, y);
        check.setPosition(x, y);
    }

    public override function draw() {
        updatePositions();
        super.draw();
    }

    public override function onHovered() {
        super.onHovered();
        if (FlxG.mouse.justReleased) {
            // clicked
            checked = !checked;
            check.scale.set(1.25, 1.25);

            if (Options.editorSFX)
                CoolUtil.playMenuSFX(checked ? CHECKED : UNCHECKED, 0.5);
            if (onChecked != null)
                onChecked(checked);
        }
    }

    public override function updateButton() {
        __rect.x = x;
        __rect.y = y;
        __rect.width = field.width + 30;
        __rect.height = field.height > height ? field.height : height;
        UIState.state.updateRectButtonHandler(this, __rect, onHovered);
    }
}