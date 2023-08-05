package funkin.editors.ui;

import flixel.math.FlxPoint;
import funkin.backend.shaders.CustomShader;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class UIColorwheel extends UISliceSprite {
	var colorPicker:FlxSprite;
	var colorPickerShader:CustomShader;
	var colorPickerSelector:UIColorWheelSelector;

	var colorSlider:FlxSprite;
	var colorSliderSelector:UIColorWheelSelector;

	var colorHexTextBox:UITextBox;
	var rgbNumSteppers:Array<UINumericStepper> = []; // r,g,b

	public var curColor:Null<FlxColor>;
	public var curColorString:String = "#FFFFFF";

	public var saturation:Float;
	public var brightness:Float;
	public var hue:Float;

	public function new (x:Float, y:Float, ?color:Int) {
		super(x, y, 299, 125, 'editors/ui/inputbox');

		curColor = cast color;
		hue = curColor.hue; saturation = curColor.saturation; brightness = curColor.brightness;

		colorPickerShader = new CustomShader("engine/colorPicker");
		colorPickerShader.hset("hue", hue);

		colorPicker = new FlxSprite(x + 12.5, (y + 125/2) - (100/2)).makeGraphic(100, 100, FlxColor.TRANSPARENT);
		colorPicker.drawRoundRect(0, 0, 100, 100, 10, 10, FlxColor.WHITE);
		colorPicker.shader = colorPickerShader;

		colorPickerSelector = new UIColorWheelSelector(colorPicker.x + 100 - 16, colorPicker.y);

		colorSlider = new FlxSprite(colorPicker.x + 100 + 12.5, colorPicker.y).makeGraphic(16, 100, FlxColor.TRANSPARENT);
		colorSlider.drawRoundRect(0, 0, 16, 100, 10, 10, FlxColor.WHITE);

		// Im too lazy to use a shader for this if its not even gonna change
		colorSlider.pixels.lock();
		for (pixely in 0...Std.int(colorSlider.height)) {
			var color:Int = FlxColor.fromHSB(pixely / (colorSlider.height-1) * 360, 1, 1);
			for (pixelx in 0...Std.int(colorSlider.width))
				if (colorSlider.pixels.getPixel32(pixelx, pixely) != FlxColor.TRANSPARENT) colorSlider.pixels.setPixel32(pixelx, pixely, color);
		}
		colorSlider.pixels.unlock();

		colorSliderSelector = new UIColorWheelSelector(colorSlider.x, colorSlider.y);

		colorHexTextBox = new UITextBox(colorSlider.x + 16 + 12.5, colorSlider.y + 16, "", 100, 28);
		colorHexTextBox.onChange = (colorString:String) -> {
			curColor = FlxColor.fromString(colorString);
			if (curColor == null) curColor = FlxColor.WHITE;

			hue = curColor.hue; saturation = curColor.saturation; brightness = curColor.brightness;
			updateWheel();
		}

		var hexLabel:UIText = new UIText(colorHexTextBox.x - 2, colorHexTextBox.y - 18, 0, "Hex (#FFFFFF)", 13);

		for (i in 0...3) {
			var numStepper:UINumericStepper = new UINumericStepper(colorSlider.x + 18 + 12.5 + (i * 44), colorHexTextBox.y + 28 + 6 + 13 + 6 + .5, 0, 1, 0, 0, 255, 40 + 28, 28);
			numStepper.antialiasing = true; numStepper.ID = i;
			numStepper.onChange = (text:String) -> {
				@:privateAccess numStepper.__onChange(text);
				switch (numStepper.ID) {
					default: curColor.red = Std.int(numStepper.value);
					case 1: curColor.green = Std.int(numStepper.value);
					case 2: curColor.blue = Std.int(numStepper.value);
				}
				hue = curColor.hue; saturation = curColor.saturation; brightness = curColor.brightness;
				updateWheel();
			};
			members.push(numStepper); rgbNumSteppers.push(numStepper);
		}

		var rgbLabel:UIText = new UIText(rgbNumSteppers[0].x - 2, rgbNumSteppers[0].y - 18, 0, "RGB (255,255,255)", 13);

		colorPicker.antialiasing = colorSlider.antialiasing = colorHexTextBox.antialiasing = true;

		for (item in [colorPicker, colorPickerSelector, colorSlider, colorSliderSelector, colorHexTextBox, hexLabel, rgbLabel])
			members.push(item);

		updateWheel();
	}

	inline function updateColorPickerSelector()
        colorPickerSelector.selector.setPosition(colorPicker.x + (colorPicker.width *saturation) - 8, colorPicker.y + (colorPicker.height + (colorPicker.height * -brightness))- 8);

	inline function updateColorPickerMouse(mousePos:FlxPoint) {
		saturation = mousePos.x/colorPicker.width; brightness = 1 + -(mousePos.y/colorPicker.height);
	}

	inline function updateColorSliderPickerSelector()
		colorSliderSelector.selector.setPosition(colorSlider.x, colorSlider.y + (hue / 360 * (colorSlider.height-1)) - 8);

	inline function updateColorSliderMouse(mousePos:FlxPoint)
		hue = (mousePos.y / colorSlider.height) * 360;

	public function updateWheel() {
		colorPickerShader.hset("hue", hue / 360);
		colorPickerSelector.curColor = color = curColor = FlxColor.fromHSB(hue, saturation, brightness); colorSliderSelector.curColor = FlxColor.fromHSB(hue, 1, 1);

		updateColorPickerSelector(); updateColorSliderPickerSelector();
		colorHexTextBox.label.text = curColorString = curColor.toHexString(false).replace("0x", "#");
		for (numStepper in rgbNumSteppers) {
			numStepper.label.text = Std.string(switch (numStepper.ID) {
				default: curColor.red;
				case 1: curColor.green;
				case 2: curColor.blue;
			});
		}
	}

	// For Character Editor
	public var colorChanged:Bool = false;

	// Make the colorwhell feel better
	static inline var hitBoxExtenstion:Float = 8;

	public override function update(elapsed:Float) {
		if (hovered && FlxG.mouse.pressed) {
			var mousePos = FlxG.mouse.getScreenPosition(__lastDrawCameras[0], FlxPoint.get());

			for (sprite in [colorPicker, colorSlider]) {
				var spritePos:FlxPoint = sprite.getScreenPosition(FlxPoint.get(), __lastDrawCameras[0]);

				if (((mousePos.x > (spritePos.x - (hitBoxExtenstion/2))) && (mousePos.x < spritePos.x - (hitBoxExtenstion/2) + (sprite.width + hitBoxExtenstion))) && ((mousePos.y > (spritePos.y - (hitBoxExtenstion/2))) && (mousePos.y < spritePos.y - (hitBoxExtenstion/2) + (sprite.height + hitBoxExtenstion)))) {
					mousePos -= FlxPoint.weak(spritePos.x, spritePos.y);
					mousePos.set(FlxMath.bound(mousePos.x, 0, sprite.width), FlxMath.bound(mousePos.y, 0, sprite.height));

					if (sprite == colorSlider) updateColorSliderMouse(mousePos);
					if (sprite == colorPicker) updateColorPickerMouse(mousePos);
					updateWheel();
					colorChanged = true;

					spritePos.put();
					break;
				}
			}
			mousePos.put();
		}

		super.update(elapsed);
	}
}

class UIColorWheelSelector extends FlxTypedGroup<FlxSprite> {
	public var curColor:FlxColor = FlxColor.WHITE;

	public var selector:FlxSprite;
	public var colorCircle:FlxSprite;

	public function new(x:Float, y:Float, ?color:Null<Int>) {
		super();
		if (color != null) curColor = cast color;

		add(selector = new FlxSprite(x, y).loadGraphic(Paths.image("editors/ui/slider")));
		add(colorCircle = new FlxSprite(x + 2, y + 2).makeGraphic(12,12, FlxColor.TRANSPARENT).drawCircle());

		selector.antialiasing = colorCircle.antialiasing = true;
		colorCircle.colorTransform.color = curColor;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		colorCircle.setPosition(selector.x + 2, selector.y + 2);
		colorCircle.colorTransform.color = curColor;
	}
}