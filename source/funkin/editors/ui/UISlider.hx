package funkin.editors.ui;

using StringTools;

typedef SliderSegement = {
	var start:Float;
	var end:Float;
	var size:Float;
}

class UISlider extends UISprite {
	public var segments:Array<SliderSegement> = [];
	public var barWidth:Int = 120;

	public var barStartSpr:FlxSprite;
	public var startText:UIText;
	public var barEndSpr:FlxSprite;
	public var endText:UIText;

	public var barSegements:Map<{segment:Float, size:Float}, UISprite> = [];
	public var selectableBar:UISprite;
	public var selectableHitbox:UISprite;

	public var value:Float = 0;
	public var onChange:Float->Void;

	public function new(x:Float, y:Float, width:Int = 120, segments:Array<SliderSegement>, defaultStart:Float = 0) {
		this.segments = segments;
		this.barWidth = width;

		x -= 6;
		super(x, y);
		makeSolid((barWidth+6), 4, -1);
		cursor = BUTTON;

		__barProgress = defaultStart;

		members.push(barStartSpr = new FlxSprite(x-4,y+((4/2))).makeSolid(4, 12, -1));
		members.push(barEndSpr = new FlxSprite(x+barWidth+6,y+((4/2))).makeSolid(4, 12, -1));

		members.push(startText = new UIText(x, y, 0, Std.string(segments[0].start).replace("0.", ".")));
		members.push(endText = new UIText(x + (barWidth+6) + 8, y, 0, Std.string(segments[segments.length-1].end)));

		var midSegments:Map<Int, Float> = [];
		for (segment in segments) {
			var isFront:Bool = segment.start == segments[0].start;
			var isEnd:Bool = segment.end == segments[segments.length-1].end;

			if (isFront && !midSegments.exists(Std.int(segment.end*1000))) midSegments.set(Std.int(segment.end*1000), segment.size);
			if (isEnd && !midSegments.exists(Std.int(segment.start*1000))) midSegments.set(Std.int(segment.start*1000), segment.size);
		}
		
		for (segment => size in midSegments) {
			var segmentSpr:UISprite = new UISprite(x,y);
			segmentSpr.makeSolid(4, 8, -1);
			members.push(segmentSpr);

			barSegements.set({segment: segment/1000, size: size}, segmentSpr);
		}

		selectableBar = new UISprite(x,y);
		selectableBar.makeSolid(6, 12, 0xFFA0A0A0);
		selectableBar.cursor = BUTTON;
		members.push(selectableBar);

		selectableHitbox = new UISprite(x,y);
		selectableHitbox.makeSolid(barWidth+6, 16, -1);
		selectableHitbox.cursor = BUTTON;
		selectableHitbox.alpha = 0;
		members.push(selectableHitbox);
	}

	var __barProgress:Float = 0;

	public override function update(elapsed:Float) {
		barStartSpr.follow(this, -4, (height-barStartSpr.height)/2);
		barEndSpr.follow(this, barWidth+6, (height-barEndSpr.height)/2);

		selectableHitbox.follow(this, 0, (height-selectableHitbox.height)/2);
		var lastBarProgress:Float = __barProgress;

		if (selectableHitbox.hovered && FlxG.mouse.pressed) {
			var mousePos = FlxG.mouse.getScreenPosition(__lastDrawCameras[0], FlxPoint.get());
			__barProgress = FlxMath.bound(mousePos.x-x, 0, barWidth)/barWidth;
			mousePos.put();
		}

		if (__barProgress != lastBarProgress)
			onChange(value = calcValue(__barProgress));

		selectableBar.follow(this, __barProgress * barWidth, (4-12)/2);

		startText.follow(this, -startText.width-10, (4/2) - (startText.height/2));
		endText.follow(this, barWidth+6 + 10, (4/2) - (endText.height/2));

		for (segmentData => sprite in barSegements)
			sprite.follow(this, (barWidth * segmentData.size) + ((selectableBar.width-sprite.width)/2), ((4-8)/2));

		super.update(elapsed);
	}

	function calcValue(progress:Float):Float {
		var totalProgress:Float = 0;
        for (segment in segments) {
            if (progress < totalProgress + segment.size) {
                var relativeProgress = (progress - totalProgress) / segment.size;
                return FlxMath.remapToRange(relativeProgress, 0, 1, segment.start, segment.end);
            }
            totalProgress += segment.size;
        }
		return segments[segments.length-1].end;
	}
}