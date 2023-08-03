package funkin.editors.ui;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import funkin.game.Character;
import flixel.util.FlxSort;

class UIButtonList<T:UIButton> extends UIWindow {
	public var buttons:FlxTypedGroup<T> = new FlxTypedGroup<T>();
	public var addButton:UIButton;
	public var addIcon:FlxSprite;

	public var buttonCameras:FlxCamera;
	public var cameraSpacing = 30;

	public var buttonSpacing:Float = 16;
	public var buttonSize:FlxPoint = FlxPoint.get();
	public var buttonOffset:FlxPoint = FlxPoint.get();

	public var dragging:Bool = false;

	var curMoving:T = null;
	var curMovingInterval:Float = 0;

	public function new(x:Int, y:Int, width:Int, height:Int, windowName:String, buttonSize:FlxPoint, ?buttonOffset:FlxPoint, ?buttonSpacing:Float) {
		if (buttonSpacing != null) this.buttonSpacing = buttonSpacing;
		this.buttonSize = buttonSize;
		if (buttonOffset != null) this.buttonOffset = buttonOffset;
		super(x, y, width, height, windowName);

		buttonCameras = new FlxCamera(x, y+cameraSpacing, width-2, height-cameraSpacing);
		FlxG.cameras.add(buttonCameras, false);
		buttonCameras.bgColor = 0;

		addButton = new UIButton(25, 16, "", null, Std.int(buttonSize.x));
		addButton.color = 0xFF00FF00;
		addButton.cameras = [buttonCameras];

		addIcon = new FlxSprite(addButton.x + addButton.bHeight / 2, addButton.y + (32/2) - 8).loadGraphic(Paths.image('editors/charter/add-button'));
		addIcon.antialiasing = false;
		addButton.members.push(addIcon);
		members.push(addButton);

		members.push(buttons);
		scrollY = buttonCameras.scroll.y = -this.buttonSpacing;
	}

	public inline function add(button:T)
		buttons.add(button);

	public inline function insert(button:T, position:Int) {
		buttons.insert(position, button);
		scrollY += button.bHeight;
	}

	public inline function remove(button:T) {
		buttons.members.remove(button);
		button.destroy();
	}

	public inline function updateButtonsPos(elapsed:Float) {
		for (i => button in buttons.members) {
			if (button == null) continue;

			if (curMoving != button) {
				button.setPosition(
					(bWidth/2) - (buttonSize.x/2),
					CoolUtil.fpsLerp(button.y, (buttonSize.y+buttonSpacing) * i, 0.25));
			}
			if (button.hovered && FlxG.mouse.justPressed) curMoving = button;
		}

		if (addButton != null)
			addButton.setPosition(
				(bWidth/2) - (buttonSize.x/2),
				CoolUtil.fpsLerp(addButton.y, (buttonSize.y+buttonSpacing) * buttons.members.length, 0.25));

		if (curMoving != null) {
			curMovingInterval += FlxG.mouse.deltaY;
			if (Math.abs(curMovingInterval) > addButton.bHeight / 2) {
				curMovingInterval = 999;
				curMoving.y = CoolUtil.fpsLerp(curMoving.y, FlxG.mouse.getWorldPosition(buttonCameras).y - (curMoving.bHeight / 2), 0.3);
				buttons.sort(function(o, a:T, b:T) return FlxSort.byValues(o, a.y + (a.bHeight / 2), b.y + (a.bHeight / 2)), -1);
			}
			if (FlxG.mouse.justReleased) {
				curMoving = null;
				curMovingInterval = 0;
			}
		}
		addIcon.x = addButton.x + addButton.bWidth / 2 - addIcon.width / 2; addIcon.y = addButton.y + addButton.bHeight / 2 - addIcon.height / 2;
	}

	var scrollY:Float = 0;

	public override function update(elapsed:Float) {
		updateButtonsPos(elapsed);
		dragging = Math.abs(curMovingInterval) > addButton.bHeight / 2;

		super.update(elapsed);

		// Camera Stuff
		var nextscrollY = scrollY - (hovered ? FlxG.mouse.wheel : 0) * 12;

		if (curMoving != null && dragging) {
			nextscrollY -= Math.min((bHeight - 100) - FlxG.mouse.getWorldPosition(buttonCameras).y, 0) / 8;
			nextscrollY += Math.min(FlxG.mouse.getWorldPosition(buttonCameras).y - 100, 0) / 8;
		}

		if (nextscrollY >= (-buttonSpacing) && nextscrollY + buttonCameras.height <= (addButton.y + 32 + (buttonSpacing*1.5)))
			scrollY = nextscrollY;

		buttonCameras.scroll.y = FlxMath.lerp(buttonCameras.scroll.y, nextscrollY, 1/3);

		for (button in buttons) {
			if (button != null) button.selectable = (hovered && !dragging);
			button.cameras = [buttonCameras];
		}
		addButton.selectable = (hovered && !dragging);

		if (__lastDrawCameras[0] != null) {
			buttonCameras.height = bHeight - cameraSpacing;
			buttonCameras.x = x - __lastDrawCameras[0].scroll.x;
			buttonCameras.y = y + cameraSpacing - __lastDrawCameras[0].scroll.y;
			buttonCameras.zoom = __lastDrawCameras[0].zoom;
		}
	}
}