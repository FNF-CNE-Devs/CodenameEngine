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

	public var drawTop:Bool = true;
	public var drawMiddle:Bool = true;
	public var drawBottom:Bool = true;

	public override function draw() @:privateAccess {
		var x:Float = this.x;
		var y:Float = this.y;

		if (visible && !(bWidth == 0 || bHeight == 0)) {
			var topleft:FlxFrame = frames.frames[framesOffset];
			var top:FlxFrame = frames.frames[framesOffset + 1];
			var topright:FlxFrame = frames.frames[framesOffset + 2];
			var middleleft:FlxFrame = frames.frames[framesOffset + 3];
			var middle:FlxFrame = frames.frames[framesOffset + 4];
			var middleright:FlxFrame = frames.frames[framesOffset + 5];
			var bottomleft:FlxFrame = frames.frames[framesOffset + 6];
			var bottom:FlxFrame = frames.frames[framesOffset + 7];
			var bottomright:FlxFrame = frames.frames[framesOffset + 8];

			// TOP
			if (drawTop) {
				// TOP LEFT
				frame = topleft;
				setPosition(x, y);
				__setSize(
					topleft.frame.width * Math.min(bWidth/(topleft.frame.width*2), 1), 
					topleft.frame.height * Math.min(bHeight/(topleft.frame.height*2), 1)
				);
				super.drawSuper();

				// TOP
				if (bWidth > topleft.frame.width + topright.frame.width) {
					frame = top;
					setPosition(x + topleft.frame.width, y);
					__setSize(bWidth - topleft.frame.width - topright.frame.width, top.frame.height * Math.min(bHeight/(top.frame.height*2), 1));
					super.drawSuper();
				}

				// TOP RIGHT
				setPosition(x + bWidth - (topright.frame.width * Math.min(bWidth/(topright.frame.width*2), 1)), y);
				frame = topright;
				__setSize(
					topright.frame.width * Math.min(bWidth/(topright.frame.width*2), 1), 
					topright.frame.height * Math.min(bHeight/(topright.frame.height*2), 1)
				);
				super.drawSuper();
			}

			// MIDDLE
			if (drawMiddle && bHeight > top.frame.height + bottom.frame.height) {
				var middleHeight:Float = bHeight - (topleft.frame.height * Math.min(bHeight/(topleft.frame.height*2), 1)) -
				bottomleft.frame.height * Math.min(bHeight/(bottomleft.frame.height*2), 1);

				// MIDDLE LEFT
				frame = middleleft;
				setPosition(x, y + top.frame.height);
				__setSize(middleleft.frame.width * Math.min(bWidth/(middleleft.frame.width*2), 1), middleHeight);
				super.drawSuper();

				if (bWidth > (middleleft.frame.width * Math.min(bWidth/(middleleft.frame.width*2), 1)) + middleright.frame.width) {
					// MIDDLE
					frame = middle;
					setPosition(x + topleft.frame.width, y + top.frame.height);
					__setSize(bWidth - middleleft.frame.width - middleright.frame.width, middleHeight);
					super.drawSuper();
				}

				// MIDDLE RIGHT
				frame = middleright;
				setPosition(x + bWidth - (topright.frame.width * Math.min(bWidth/(topright.frame.width*2), 1)), y + top.frame.height);
				__setSize(middleright.frame.width * Math.min(bWidth/(middleright.frame.width*2), 1), middleHeight);
				super.drawSuper();
			}

			// BOTTOM
			if (drawBottom) {
				// BOTTOM LEFT
				frame = bottomleft;
				setPosition(x, y + bHeight - (bottomleft.frame.height * Math.min(bHeight/(bottomleft.frame.height*2), 1)));
				__setSize(
					bottomleft.frame.width * Math.min(bWidth/(bottomleft.frame.width*2), 1), 
					bottomleft.frame.height * Math.min(bHeight/(bottomleft.frame.height*2), 1)
				);
				super.drawSuper();

				if (bWidth > bottomleft.frame.width + bottomright.frame.width) {
					// BOTTOM
					frame = bottom;
					setPosition(x + bottomleft.frame.width, y + bHeight - (bottom.frame.height * Math.min(bHeight/(bottom.frame.height*2), 1)));
					__setSize(bWidth - bottomleft.frame.width - bottomright.frame.width, bottom.frame.height * Math.min(bHeight/(bottom.frame.height*2), 1));
					super.drawSuper();
				}

				// BOTTOM RIGHT
				frame = bottomright;
				setPosition(
					x + bWidth - (bottomright.frame.width * Math.min(bWidth/(bottomright.frame.width*2), 1)), 
					y + bHeight - (bottomright.frame.height * Math.min(bHeight/(bottomright.frame.height*2), 1))
				);
				__setSize(
					bottomright.frame.width * Math.min(bWidth/(bottomright.frame.width*2), 1), 
					bottomright.frame.height * Math.min(bHeight/(bottomright.frame.height*2), 1)
				);
				super.drawSuper();
			}
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