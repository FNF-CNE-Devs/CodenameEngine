package funkin.editors.ui;

class UIScrollBar extends UISprite {
	public var length:Float;
	public var start:Float;
	public var size:Float;

	public var thumb:UISliceSprite;

	public var value:Float;

	public var onChange:Float->Void;

	public function new(x:Float, y:Float, length:Float, start:Float, size:Float, w:Int = 20, ?h:Int) {
		super(x, y, Paths.image("editors/ui/scrollbar-bg"));
		scale.y = h.getDefault(Std.int(FlxG.height - y));
		updateHitbox();
		this.start = start;
		this.size = size;
		this.length = length;

		thumb = new UISliceSprite(0, 0, w, h, 'editors/ui/scrollbar');
		members.push(thumb);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		thumb.follow(this, 0, FlxMath.remapToRange(start, -(size/2), length + size, 0, height));
		thumb.bHeight = Std.int(FlxMath.remapToRange(size, -(size/2), length + size, 0, height));

		if (hovered) {
			if (FlxG.mouse.justReleased) {
				var mousePos = FlxG.mouse.getScreenPosition(camera);
				var yPos = FlxMath.remapToRange(mousePos.y, y, y+height, -(size/2), length + size);
				if (yPos >= 0 && yPos < length) {
					onChange(value = yPos);
				}
			}
		} else if (thumb.hovered) {
			// todo: scrolling
		}
	}
}