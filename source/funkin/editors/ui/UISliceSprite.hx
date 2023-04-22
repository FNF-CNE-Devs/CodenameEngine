package funkin.editors.ui;

import flixel.graphics.frames.FlxFrame;

class UISliceSprite extends UISprite {
	public var bWidth:Int = 120;
	public var bHeight:Int = 20;
	public var framesOffset:Int = 0;

	public var incorporeal:Bool = false;

	public function new(x:Float, y:Float, w:Int, h:Int, path:String) {
		super(x, y);

		frames = Paths.getFrames(path);
		resize(w, h);
	}

	public override function updateButton() {
		if (incorporeal) return;
		__rect.x = x;
		__rect.y = y;
		__rect.width = bWidth;
		__rect.height = bHeight;
		UIState.state.updateRectButtonHandler(this, __rect, onHovered);
	}

	public function resize(w:Int, h:Int) {
		bWidth = w;
		bHeight = h;
	}

	public override function draw() {
		var x:Float = this.x;
		var y:Float = this.y;

		var topleft:FlxFrame = frames.frames[framesOffset];
		var top:FlxFrame = frames.frames[framesOffset + 1];
		var topright:FlxFrame = frames.frames[framesOffset + 2];
		var middleleft:FlxFrame = frames.frames[framesOffset + 3];
		var middle:FlxFrame = frames.frames[framesOffset + 4];
		var middleright:FlxFrame = frames.frames[framesOffset + 5];
		var bottomleft:FlxFrame = frames.frames[framesOffset + 6];
		var bottom:FlxFrame = frames.frames[framesOffset + 7];
		var bottomright:FlxFrame = frames.frames[framesOffset + 8];

		@:privateAccess if (visible) {
			// TOP LEFT
			frame = topleft;
			setPosition(x, y);
			__setSize(topleft.frame.width, topleft.frame.height);
			super.drawSuper();

			// TOP
			if (bWidth > topleft.frame.width + topright.frame.width) {
				frame = top;
				setPosition(x + topleft.frame.width, y);
				__setSize(bWidth - topleft.frame.width - topright.frame.width, top.frame.height);
				super.drawSuper();
			}

			// TOP RIGHT
			frame = topright;
			setPosition(x + bWidth - topright.frame.width, y);
			__setSize(topright.frame.width, topright.frame.height);
			super.drawSuper();

			// MIDDLE LEFT
			if (bHeight > top.frame.height + bottom.frame.height) {
				frame = middleleft;
				setPosition(x, y + top.frame.height);
				__setSize(middleleft.frame.width, bHeight - topleft.frame.height - bottomleft.frame.height);
				super.drawSuper();

				if (bWidth > middleleft.frame.width + middleright.frame.width) {
					// MIDDLE
					frame = middle;
					setPosition(x + topleft.frame.width, y + top.frame.height);
					__setSize(bWidth - middleleft.frame.width - middleright.frame.width, bHeight - topleft.frame.height - bottomleft.frame.height);
					super.drawSuper();
				}

				// MIDDLE RIGHT
				frame = middleright;
				setPosition(x + bWidth - topright.frame.width, y + top.frame.height);
				__setSize(middleright.frame.width, bHeight - topleft.frame.height - bottomleft.frame.height);
				super.drawSuper();
			}

			// BOTTOM LEFT
			frame = bottomleft;
			setPosition(x, y + bHeight - bottom.frame.height);
			__setSize(bottomleft.frame.width, bottomleft.frame.height);
			super.drawSuper();

			if (bWidth > bottomleft.frame.width + bottomright.frame.width) {
				// BOTTOM
				frame = bottom;
				setPosition(x + bottomleft.frame.width, y + bHeight - bottom.frame.height);
				__setSize(bWidth - bottomleft.frame.width - bottomright.frame.width, bottom.frame.height);
				super.drawSuper();
			}

			// BOTTOM RIGHT
			frame = bottomright;
			setPosition(x + bWidth - bottomright.frame.width, y + bHeight - bottom.frame.height);
			__setSize(bottomright.frame.width, bottomright.frame.height);
			super.drawSuper();
		}

		setPosition(x, y);

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