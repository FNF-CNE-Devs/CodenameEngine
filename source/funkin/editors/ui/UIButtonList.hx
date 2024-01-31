package funkin.editors.ui;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import funkin.game.Character;
import flixel.util.FlxSort;
import flixel.math.FlxMath;

class UIButtonList<T:UIButton> extends UIWindow {
	public var buttons:FlxTypedGroup<T> = new FlxTypedGroup<T>();
	public var addButton:UIButton;
	public var addIcon:FlxSprite;

	public var cameraSpacing = 30;

	public var buttonSpacing:Float = 16;
	public var buttonSize:FlxPoint = FlxPoint.get();
	public var buttonOffset:FlxPoint = FlxPoint.get();

	public var dragging:Bool = false;
	public var dragCallback:(T,Int,Int)->Void;

	var curMoving:T = null;
	var curMovingInterval:Float = 0;

	public function new(x:Float, y:Float, width:Int, height:Int, windowName:String, buttonSize:FlxPoint, ?buttonOffset:FlxPoint, ?buttonSpacing:Float) {
		if (buttonSpacing != null) this.buttonSpacing = buttonSpacing;
		this.buttonSize = buttonSize;
		if (buttonOffset != null) this.buttonOffset = buttonOffset;
		super(x, y, width, height, windowName);

		addButton = new UIButton(25, 16, "", null, Std.int(this.buttonSize.x));
		addButton.autoAlpha = false;
		addButton.color = 0xFF00FF00;

		addIcon = new FlxSprite(addButton.x + addButton.bHeight / 2, addButton.y + (32/2) - 8).loadGraphic(Paths.image('editors/charter/add-button'));
		addIcon.antialiasing = false;
		addButton.members.push(addIcon);
		members.push(addButton);

		members.push(buttons);
		nextscrollY = -this.buttonSpacing;
	}

	public inline function add(button:T) {
		button.ID = buttons.members.length-1;
		buttons.add(button);
		curMovingInterval = 0;
		nextscrollY += button.bHeight;
	}

	public inline function insert(button:T, position:Int) {
		button.ID = position;
		buttons.insert(position, button);
		nextscrollY += button.bHeight;
	}

	public inline function remove(button:T) {
		nextscrollY -= button.bHeight;
		buttons.members.remove(button);
		button.destroy();
	}

	public inline function updateButtonsPos(elapsed:Float) {
		for (i => button in buttons.members) {
			if (button == null) continue;

			if (curMoving != button) {
				button.setPosition(
					x + (bWidth/2) - (buttonSize.x/2) + buttonOffset.x,
					CoolUtil.fpsLerp(button.y, y + nextscrollY + cameraSpacing + ((buttonSize.y+buttonSpacing) * i) + buttonOffset.y, 0.25));
			}
			if (button.hovered && FlxG.mouse.justPressed) curMoving = button;
		}

		if (addButton != null)
			addButton.setPosition(
				x + (bWidth/2) - (buttonSize.x/2) + buttonOffset.x,
				CoolUtil.fpsLerp(addButton.y, y + nextscrollY + cameraSpacing + ((buttonSize.y+buttonSpacing) * buttons.members.length) + buttonOffset.y, 0.25));

		if (curMoving != null) {
			curMovingInterval += FlxG.mouse.deltaY;
			if (Math.abs(curMovingInterval) > addButton.bHeight / 2) {
				curMovingInterval = 999;
				curMoving.y = CoolUtil.fpsLerp(curMoving.y, FlxG.mouse.screenY - (curMoving.bHeight / 2), 0.3);
				buttons.sort(function(o, a:T, b:T) return FlxSort.byValues(o, a.y + (a.bHeight / 2), b.y + (a.bHeight / 2)), -1);
			}
			if (FlxG.mouse.justReleased) {
				curMoving = null;
				curMovingInterval = 0;
			}
		}
		addIcon.x = addButton.x + addButton.bWidth / 2 - addIcon.width / 2; addIcon.y = addButton.y + addButton.bHeight / 2 - addIcon.height / 2;
	}
	var nextscrollY:Float = 0;
	public override function update(elapsed:Float) {
		updateButtonsPos(elapsed);
		dragging = Math.abs(curMovingInterval) > addButton.bHeight / 2;

		super.update(elapsed);

		nextscrollY = FlxMath.bound(nextscrollY - (hovered ? -FlxG.mouse.wheel : 0) * 12, -Math.max((addButton.y + 32 + (buttonSpacing*1.5)) - bHeight, -buttonSpacing), buttonSpacing);

		if (curMoving != null && dragging) {
			nextscrollY -= Math.min((bHeight - 100) - FlxG.mouse.screenY, 0) / 8;
			nextscrollY += Math.min(FlxG.mouse.screenY - 100, 0) / 8;
		}

		for (i => button in buttons.members) {
			if (button == null) continue;
			button.selectable = button.shouldPress = (hovered && !dragging);
			if (button.ID != i) {
				if (dragCallback != null) dragCallback(cast button, button.ID, i);
				button.ID = i; // Ok back to normal :D
			}
				
		}
		addButton.selectable = (hovered && !dragging);
	}
}