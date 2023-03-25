package funkin.editors.ui;

import flixel.math.FlxPoint;

class UIBackdrop extends UISprite {
	public override function draw() {
		var __oldPos = FlxPoint.get(x, y);
		var __oldScroll = FlxPoint.get(scrollFactor.x, scrollFactor.y);

		x -= camera.scroll.x * scrollFactor.x;
		y -= camera.scroll.y * scrollFactor.y;

		while(x > -width)
			x -= width;
		while(y > -height)
			y -= height;

		var defX = x;

		while(y < FlxG.height) {
			while(x < FlxG.width) {
				super.drawSuper();
				x += width;
			}
			y += height;
			x = defX;
		}


		setPosition(__oldPos.x, __oldPos.y);
		scrollFactor.set(__oldScroll.x, __oldScroll.y);
		__oldPos.put();
		__oldScroll.put();
		drawMembers();
	}

	public override function destroy() {
		super.destroy();
	}
}