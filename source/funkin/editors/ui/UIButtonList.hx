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
	public var cameraSpacing = 36;
	public var dragging:Bool = false;

	var _buttonXOffset:Float = 16;
	var _buttonYOffset:Float = 16;

	public function new(x:Int, y:Int, width:Int, height:Int, windowName:String, addButtonCallback:Void->Void = null, buttonXOffset:Float = 16, buttonYOffset:Float = 16) {
		super(x, y, width, height, windowName);
		members.push(buttons);
		_buttonXOffset = buttonXOffset;
		_buttonYOffset = buttonYOffset;
		buttonCameras = new FlxCamera(x, y+cameraSpacing, width, height-cameraSpacing);
		FlxG.cameras.add(buttonCameras, false);
		buttonCameras.bgColor = 0;

		addButton = new UIButton(25, 16, "", addButtonCallback != null ? addButtonCallback : function() return false, Math.floor(bWidth - buttonXOffset * 2));
		addButton.color = 0xFF00FF00;

		addIcon = new FlxSprite(addButton.x + addButton.bHeight / 2, addButton.y + (32/2) - 8).loadGraphic(Paths.image('editors/charter/add-button'));
		addIcon.antialiasing = false;
		addButton.members.push(addIcon);
		add(addButton);
	}
	public function add(button:UIButton)
		insert(button, Math.floor(Math.max(buttons.members.indexOf(addButton), 0)));
	public function insert(button:UIButton, position:Int) {
		buttons.insert(position, button);
		button.cameras = [buttonCameras];
		button.x = _buttonXOffset;
		if (addButton.bHeight != button.bHeight) addButton.bHeight = button.bHeight;
		scrollY += button.bHeight;
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
				for (i in button.members) 
					if (i is UIButton) {
						var i:UIButton = cast(i, UIButton);
						i.selectable = true;
					}
				button.y = CoolUtil.fpsLerp(button.y, -scrollY + ((buttons.members[i-1] != null ? buttons.members[i-1].bHeight : 0) + _buttonYOffset) * i, 0.25);
				button.shouldPress = true;
			}
			if (button != addButton && button.hovered && FlxG.mouse.justPressed) _curMoving = button;
		}
		if (_curMoving != null) {
			_curMovingInterval += FlxG.mouse.deltaY;
			if (Math.abs(_curMovingInterval) > addButton.bHeight / 2) {
				_curMovingInterval = 999;
				_curMoving.shouldPress = false;
				_curMoving.y = CoolUtil.fpsLerp(_curMoving.y, FlxG.mouse.getScreenPosition(buttonCameras).y - (_curMoving.bHeight / 2), 0.3);
				buttons.sort(function(o,a,b) return flixel.util.FlxSort.byValues(o, a == addButton ? 999 : a.y + (a.bHeight / 2), b == addButton ? 999 : b.y + (a.bHeight / 2)), -1);
			}
			if (FlxG.mouse.justReleased) {
				_curMoving = null;
				_curMovingInterval = 0;
			}
		}
		addIcon.x = addButton.x + addButton.bWidth / 2 - addIcon.width / 2; addIcon.y = addButton.y + addButton.bHeight / 2 - addIcon.height / 2;
	}

	var scrollY:Float = 0;

	public override function update(elapsed:Float) {
		updateButtonsPos(elapsed);
		super.update(elapsed);
		__rect.x = x; __rect.y = y+23;
		__rect.width = bWidth; __rect.height = bHeight-23;
		var nextscrollY = scrollY - ((hovered = UIState.state.isOverlapping(this, __rect)) ? FlxG.mouse.wheel : 0) * 12;
		if (_curMoving != null) {
			for (i in _curMoving.members) 
				if (i is UIButton) {
					var i:UIButton = cast(i, UIButton);
					i.selectable = false;
				}
			nextscrollY -= Math.min((bHeight - 100) - FlxG.mouse.getScreenPosition(buttonCameras).y, 0) / 5;
			nextscrollY += Math.min(FlxG.mouse.getScreenPosition(buttonCameras).y - 100, 0) / 5;
		}
		scrollY = FlxMath.bound(nextscrollY, 0, -_buttonYOffset + Math.abs(Math.min(bHeight - ((addButton.bHeight + _buttonYOffset) * buttons.members.length + (cameraSpacing + _buttonYOffset)), 0)));
		for (button in buttons.members)
			if (button != null) button.selectable = (hovered && _curMoving == null);
		if (__lastDrawCameras[0] != null) {
			buttonCameras.height = bHeight - cameraSpacing;
			buttonCameras.x = x - __lastDrawCameras[0].scroll.x;
			buttonCameras.y = y + cameraSpacing - __lastDrawCameras[0].scroll.y;
			buttonCameras.zoom = __lastDrawCameras[0].zoom;
		}
		dragging = _curMoving != null;
	}
}