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

	public function new(x:Float, y:Float, width:Int = 120, segments:Array<SliderSegement>) {
		this.segments = segments;
		this.barWidth = width;

		super(x, y);
		makeSolid(barWidth, 4, -1);

		members.push(barStartSpr = new FlxSprite(x-4,y+((4/2))).makeSolid(4, 12, -1));
		members.push(barEndSpr = new FlxSprite(x+barWidth,y+((4/2))).makeSolid(4, 12, -1));

		members.push(startText = new UIText(x, y, 0, Std.string(segments[0].start).replace("0.", ".")));
		members.push(endText = new UIText(x + barWidth + 8, y, 0, Std.string(segments[segments.length-1].end)));

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
			segmentSpr.members = [new UIText(x, y, 0, Std.string(segment/1000).replace("0.", "."), 10)];
			members.push(segmentSpr);

			barSegements.set({segment: segment/1000, size: size}, segmentSpr);
		}
	}
	
	public override function update(elapsed:Float) {
		barStartSpr.follow(this, -4, (4-12)/2);
		barEndSpr.follow(this, barWidth, (4-12)/2);

		startText.follow(this, -startText.width-10, (4/2) - (startText.height/2));
		endText.follow(this, barWidth + 10, (4/2) - (endText.height/2));

		for (segmentData => sprite in barSegements) {
			sprite.follow(this, (barWidth * segmentData.size) - (sprite.width/2), ((4-8)/2) -2);
			if (sprite.members[0] != null && sprite.members[0] is UIText) 
				cast(sprite.members[0], UIText).follow(sprite,0,sprite.height);
		}

		super.update(elapsed);
	}
}