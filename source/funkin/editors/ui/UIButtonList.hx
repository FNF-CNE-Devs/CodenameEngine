package funkin.editors.ui;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import funkin.game.Character;

class UIButtonList extends UIWindow {
	public var character:Character;

	public var buttons:FlxTypedGroup<UIButton> = new FlxTypedGroup<UIButton>();
	public var addButton:UIButton;
	public var addIcon:FlxSprite;
	public var buttonCameras:FlxCamera;

	var _buttonYOffset:Float = 16;

	public function new(x:Int, y:Int, width:Int, height:Int, windowName:String, addButtonCallback:Void->Void = null, buttonYOffset = 16) {
		super(x, y, width, height, windowName);
		members.push(buttons);
		_buttonYOffset = buttonYOffset;
		buttonCameras = new FlxCamera(x, y+36, width, height-38);
		FlxG.cameras.add(buttonCameras, false);
		buttonCameras.bgColor = 0;

		addButton = new UIButton(25, 16, "", addButtonCallback != null ? addButtonCallback : function() return false, 426);
		addButton.color = 0xFF00FF00;

		addIcon = new FlxSprite(addButton.x + (440/2) - 8, addButton.y + (32/2) - 8).loadGraphic(Paths.image('editors/charter/add-button'));
		addIcon.antialiasing = false;
		addButton.members.push(addIcon);
		add(addButton);
	}
	public function add(button:UIButton)
		insert(button, buttons.members.length);
	public function insert(button:UIButton, position:Int) {
		buttons.insert(position, button);
		button.cameras = [buttonCameras];
		for (i => button in buttons.members)
			button.setPosition(16, -scrollY + (button.bHeight + _buttonYOffset) * i);
	}
	public function remove(button:UIButton) {
		buttons.remove(button, true);
		button.destroy();
	}
	var _curMoving:UIButton = null;
	var _curMovingInterval:Float = 0;
	public function updateButtonsPos(elapsed:Float) {
		for (i => button in buttons.members) {
			if (_curMoving != button) {
				button.y = CoolUtil.fpsLerp(button.y, -scrollY + (button.bHeight + _buttonYOffset) * i, 0.1);
				button.shouldPress = true;
			}
			if (button != addButton && button.hovered && FlxG.mouse.justPressed) _curMoving = button;
		}
		if (_curMoving != null) {
			_curMovingInterval += FlxG.mouse.deltaY;
			if (Math.abs(_curMovingInterval) > addButton.bHeight / 2) {
				_curMovingInterval += 100;
				_curMoving.shouldPress = false;
				_curMoving.y = CoolUtil.fpsLerp(_curMoving.y, FlxG.mouse.getScreenPosition(buttonCameras).y - (_curMoving.bHeight / 2), 0.2);
				buttons.sort(function(o,a,b) return flixel.util.FlxSort.byValues(o, a == addButton ? 999 : a.y + 40, b == addButton ? 999 : b.y + 40), -1);
			}
			if (FlxG.mouse.justReleased) {
				_curMoving = null;
				_curMovingInterval = 0;
			}
		}
		addIcon.x = addButton.x + (220) - 8; addIcon.y = addButton.y + (16) - 8;
	}

	var scrollY:Float = 0;

	public override function update(elapsed:Float) {
		updateButtonsPos(elapsed);
		super.update(elapsed);
		__rect.x = x; __rect.y = y+23;
		__rect.width = bWidth; __rect.height = bHeight-23;
		var nextscrollY = scrollY - ((hovered = UIState.state.isOverlapping(this, __rect)) ? FlxG.mouse.wheel : 0) * 12;
		if (_curMoving != null) {
			nextscrollY -= Math.min((bHeight - 100) - FlxG.mouse.getScreenPosition(buttonCameras).y, 0) / 5;
			nextscrollY += Math.min(FlxG.mouse.getScreenPosition(buttonCameras).y - 100, 0) / 5;
		}
		scrollY = FlxMath.bound(nextscrollY, 0, -16 + Math.abs(Math.min(bHeight - (addButton.bHeight + _buttonYOffset) * (buttons.members.length+1), 0)));
		for (button in buttons.members)
			if (button != null) button.selectable = (hovered && button.callback != null);
		addButton.selectable = hovered;
	}
}