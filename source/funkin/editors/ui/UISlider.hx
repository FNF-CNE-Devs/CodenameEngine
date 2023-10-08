package funkin.editors.ui;

import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;
using StringTools;

typedef SliderSegement = {
	var start:Float;
	var end:Float;
	var size:Float;
}

class UISlider extends UISprite {
	public var segments:Array<SliderSegement> = [];
	public var barWidth:Int = 120;

	public var progressbar:UISprite;
	public var progressCentered:Bool;

	public var startText:UIText;
	public var endText:UIText;

	public var selectableBar:UISprite;
	public var selectableHitbox:UISprite;

	public var value(default, set):Float = 0;
	public function set_value(newVal:Float):Float {
		__barProgress = calcProgress(newVal); onChange(newVal);
		return value = newVal;
	}

	public var valueStepper:UINumericStepper;
	public var onChange:Float->Void;

	public function new(x:Float, y:Float, width:Int = 120, segments:Array<SliderSegement>, centered:Bool, defaultStart:Float = 0) {
		this.segments = segments;
		this.barWidth = width;
		this.progressCentered = centered;

		super(x, y);

		makeGraphic(barWidth, 12, 0x00000000, true);
		this.drawRoundRect(0, 0, barWidth, 12, 8, 6, 0xFFC0C0C0);
        this.drawRoundRect(1, 1, barWidth-2, 12-2, 8, 5, 0xFF140013);
		cursor = BUTTON;

        progressbar = new UISprite(centered ? barWidth/2 : 0);
		progressbar.makeGraphic(barWidth, 8, 0x00000000, true);
		progressbar.drawRoundRect(2, 0, barWidth-4, 8, 8, 2, 0xFFFFFFFF);
        progressbar.origin.x = 0; progressbar.colorTransform.color = 0xFF67009B;
    	members.push(progressbar);

		__barProgress = defaultStart;

		members.push(startText = new UIText(x, y, 0, Std.string(segments[0].start).replace("0.", ".")));
		members.push(endText = new UIText(x + (barWidth) + 8, y, 0, Std.string(segments[segments.length-1].end).replace("0.", ".")));
		
		selectableBar = new UISprite(x,y);
		selectableBar.loadGraphic(Paths.image("editors/ui/slider"));
		selectableBar.antialiasing = true;
		selectableBar.cursor = BUTTON;
		members.push(selectableBar);

		selectableHitbox = new UISprite(x,y);
		selectableHitbox.makeSolid(barWidth, 18, -1);
		selectableHitbox.cursor = BUTTON;
		selectableHitbox.alpha = 0;
		members.push(selectableHitbox);

		valueStepper = new UINumericStepper(x - 64 - 64, y, 1, 0.01, 2, segments[0].start, segments[segments.length-1].end, 0, 18);
		valueStepper.antialiasing = true;
		valueStepper.onChange = function (text:String) {
			@:privateAccess valueStepper.__onChange(text);
			value = valueStepper.value;
		}
		members.push(valueStepper);
	}

	var __barProgress:Float = 0;

	public override function update(elapsed:Float) {
		selectableHitbox.follow(this, 0, (height-selectableHitbox.height)/2);

		valueStepper.bWidth = valueStepper.label.text.length <= 0 ? 25 : Std.int(valueStepper.label.textField.width) + 12;
		valueStepper.follow(this, -startText.width-10 - valueStepper.bWidth - 4, (height-valueStepper.bHeight)/2);
		
		var lastBarProgress:Float = __barProgress;

		if (selectableHitbox.hovered && FlxG.mouse.pressed) {
			var mousePos = FlxG.mouse.getScreenPosition(__lastDrawCameras[0], FlxPoint.get());
			__barProgress = FlxMath.bound(mousePos.x-x, 0, barWidth)/barWidth;
			mousePos.put();
		}

		if (__barProgress != lastBarProgress) {
			onChange(@:bypassAccessor value = calcValue(__barProgress));
			valueStepper.value = value;
		}
			
		progressbar.follow(this, progressCentered ? barWidth/2 : 0, (height-progressbar.height)/2);
		progressbar.scale.x = FlxMath.bound(__barProgress-(progressCentered?0.5:0),-1,1);
		progressbar.colorTransform.color = FlxColor.interpolate(progressbar.colorTransform.color, selectableHitbox.hovered ? 0xFFB235F0 : 0xFF67009B, 1/14);

		selectableBar.follow(this, (__barProgress * barWidth) - (selectableBar.width/2), (height-selectableBar.height)/2);
		//selectableBar.colorTransform.color = FlxColor.interpolate(selectableBar.colorTransform.color, selectableHitbox.hovered ? 0x6DFFFFFF : 0x00000000, 1/14);

		startText.follow(this, -startText.width-10, (height/2) - (startText.height/2));
		endText.follow(this, barWidth + 10, (height/2) - (endText.height/2));

		super.update(elapsed);
	}

	private function calcValue(progress:Float):Float {
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

	private function calcProgress(value:Float):Float {
		if (value >= segments[segments.length-1].end) return 1;
		if (value <= segments[0].start) return 0;

        var totalProgress:Float = 0;
        for (segment in segments) {
            if (value >= segment.start && value <= segment.end) {
                var relativeProgress = FlxMath.remapToRange(value, segment.start, segment.end, 0, 1);
                return totalProgress + relativeProgress * segment.size;
            }
            totalProgress += segment.size;
        }
		return -1;
	}
}

typedef UISliderPreset = {
	var value:Float;
	var barProgress:Float;
	var ?color:Int;
}

class UISliderExtras extends UISliceSprite {
	public var buttonText:UIText;
	public var buttons:Map<UISliderPreset, UIButton> = [];

	public function new(x:Float, y:Float, presets:Array<UISliderPreset>, presetValueName:String = "Presets:") {
		super(x - 12, y, (presets.length * (40 + 2)) + 22, 40+10, 'editors/ui/inputbox');
		alpha = 0.6;

		members.push(buttonText = new UIText(x-4,y+5, 0, presetValueName, 12));
		buttonText.borderStyle = OUTLINE; buttonText.borderColor = 0x88000000; buttonText.borderSize = 1;

		for (i => preset in presets) {
			var button = new UIButton(x + (i*(40 + 2)), y + buttonText.height + 5 + 2, Std.string(preset.value).replace("0.", "."), null, 40, 20);
			button.field.size = 14;
			if (preset.color != null) button.color = preset.color;
			members.push(button);

			buttons.set(preset, button);
		}
	}
}