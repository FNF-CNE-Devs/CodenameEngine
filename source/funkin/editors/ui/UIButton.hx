package funkin.editors.ui;

import flixel.graphics.frames.FlxFrame;

class UIButton extends UISprite {
    public var bWidth:Int = 120;
    public var bHeight:Int = 20;
    public var callback:Void->Void = null;

    public var field:UIText;

    public function resize(w:Int, h:Int) {
        bWidth = w;
        bHeight = h;
        field.fieldWidth = w;
    }

    public override function new(x:Float, y:Float, text:String, callback:Void->Void, w:Float = 120, h:Float = 32) {
        super(x, y);
        frames = CoolUtil.loadFrames(Paths.image('editors/ui/button'));
        this.callback = callback;
        members.push(field = new UIText(x, y, w, text));
        field.borderStyle = OUTLINE;
        field.borderColor = 0x88000000;
        field.borderSize = 1;
        field.alignment = CENTER;
    }

    public override function updateButton() {
        __rect.x = x;
        __rect.y = y;
        __rect.width = bWidth;
        __rect.height = bHeight;
        UIState.state.updateRectButtonHandler(this, __rect, onHovered);
    }

    public override function onHovered() {
        super.onHovered();
        if (FlxG.mouse.justReleased && callback != null)
            callback();
    }

    public override function draw() {
        var x:Float = this.x;
        var y:Float = this.y;
        var offset:Int = hovered ? (pressed ? 18 : 9) : 0;

        var topleft:FlxFrame = frames.frames[offset];
        var top:FlxFrame = frames.frames[offset + 1];
        var topright:FlxFrame = frames.frames[offset + 2];
        var middleleft:FlxFrame = frames.frames[offset + 3];
        var middle:FlxFrame = frames.frames[offset + 4];
        var middleright:FlxFrame = frames.frames[offset + 5];
        var bottomleft:FlxFrame = frames.frames[offset + 6];
        var bottom:FlxFrame = frames.frames[offset + 7];
        var bottomright:FlxFrame = frames.frames[offset + 8];

        @:privateAccess {
            // TOP LEFT
            frame = topleft;
            setPosition(x, y);
            __setSize(topleft.frame.width, topleft.frame.height);
            super.drawSuper();
    
            // TOP
            frame = top;
            setPosition(x + topleft.frame.width, y);
            __setSize(bWidth - topleft.frame.width - topright.frame.width, top.frame.height);
            super.drawSuper();

            // TOP RIGHT
            frame = topright;
            setPosition(x + bWidth - topright.frame.width, y);
            __setSize(topright.frame.width, topright.frame.height);
            super.drawSuper();

            // MIDDLE LEFT
            frame = middleleft;
            setPosition(x, y + top.frame.height);
            __setSize(middleleft.frame.width, bHeight - topleft.frame.height - bottomleft.frame.height);
            super.drawSuper();
    
            // MIDDLE
            frame = middle;
            setPosition(x + topleft.frame.width, y + top.frame.height);
            __setSize(bWidth - middleleft.frame.width - middleright.frame.width, bHeight - topleft.frame.height - bottomleft.frame.height);
            super.drawSuper();

            // MIDDLE RIGHT
            frame = middleright;
            setPosition(x + bWidth - topright.frame.width, y + top.frame.height);
            __setSize(middleright.frame.width, bHeight - topleft.frame.height - bottomleft.frame.height);
            super.drawSuper();

            // BOTTOM LEFT
            frame = bottomleft;
            setPosition(x, y + bHeight - bottom.frame.height);
            __setSize(bottomleft.frame.width, bottomleft.frame.height);
            super.drawSuper();
    
            // BOTTOM
            frame = bottom;
            setPosition(x + bottomleft.frame.width, y + bHeight - bottom.frame.height);
            __setSize(bWidth - bottomleft.frame.width - bottomright.frame.width, bottom.frame.height);
            super.drawSuper();

            // BOTTOM RIGHT
            frame = bottomright;
            setPosition(x + bWidth - bottomright.frame.width, y + bHeight - bottom.frame.height);
            __setSize(bottomright.frame.width, bottomright.frame.height);
            super.drawSuper();
        }

        setPosition(x, y);

        field.follow(this, 0, ((bHeight - field.height) / 2));

        super.drawMembers();
    }

    private function __setSize(Width:Float, Height:Float) {
        var newScaleX:Float = Width / frameWidth;
		var newScaleY:Float = Height / frameHeight;
		scale.set(newScaleX, newScaleY);

		if (Width <= 0)
			scale.x = newScaleY;
		else if (Height <= 0)
			scale.y = newScaleX;

        updateHitbox();
    }
}