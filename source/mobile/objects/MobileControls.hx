package mobile.objects;

import flixel.FlxG;
import flixel.math.FlxPoint;
import mobile.flixel.FlxButton;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import mobile.flixel.FlxVirtualPad;
import flixel.util.FlxDestroyUtil;
import funkin.options.Options;

class MobileControls extends FlxTypedSpriteGroup<FlxButtonGroup>
{
	public var virtualPad:FlxVirtualPad = new FlxVirtualPad(NONE, NONE);
	public var hitbox:Hitbox = new Hitbox();
	// YOU CAN'T CHANGE PROPERTIES USING THIS EXCEPT WHEN IN RUNTIME!! (except for the variables it already has like buttonUp, buttonLeft...)
	public var current:CurrentManager;

	public static var mode(get, set):Int;
	public static var forcedControl:Null<Int>;
	public static var mobileC(get, never):Bool;

	public function new(?forceType:Int)
	{
		super();
		forcedControl = mode;
		if (forceType != null)
			forcedControl = forceType;
		switch (forcedControl)
		{
			case 0: // RIGHT_FULL
				initControler(0);
			case 1: // LEFT_FULL
				initControler(1);
			case 2: // CUSTOM
				initControler(2);
			case 3: // BOTH
				initControler(3);
			case 4: // HITBOX
				initControler(4);
			case 5: // KEYBOARD
		}
		current = new CurrentManager(this);
		//updateButtonsColors();
	}

	private function initControler(virtualPadMode:Int = 0)
	{
		switch (virtualPadMode)
		{
			case 0:
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(virtualPad);
			case 1:
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				add(virtualPad);
			case 2:
				virtualPad = getCustomMode(new FlxVirtualPad(RIGHT_FULL, NONE));
				add(virtualPad);
			case 3:
				virtualPad = new FlxVirtualPad(BOTH, NONE);
				add(virtualPad);
			case 4:
				hitbox = new Hitbox();
				add(hitbox);
		}
	}

	public static function setCustomMode(virtualPad:FlxVirtualPad):Void
	{
		if (FlxG.save.data.buttons == null)
		{
			FlxG.save.data.buttons = new Array();
			for (buttons in virtualPad)
				FlxG.save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
		}
		else
		{
			var tempCount:Int = 0;
			for (buttons in virtualPad)
			{
				FlxG.save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		FlxG.save.flush();
	}

	public static function getCustomMode(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		var tempCount:Int = 0;

		if (FlxG.save.data.buttons == null)
			return virtualPad;

		for (buttons in virtualPad)
		{
			if(FlxG.save.data.buttons[tempCount] != null){
				buttons.x = FlxG.save.data.buttons[tempCount].x;
				buttons.y = FlxG.save.data.buttons[tempCount].y;
			}
			tempCount++;
		}

		return virtualPad;
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (hitbox != null)
		{
			hitbox = FlxDestroyUtil.destroy(hitbox);
			hitbox = null;
		}
	}

	static function set_mode(mode:Int = 0)
	{
		FlxG.save.data.mobileControlsMode = mode;
		FlxG.save.flush();
		return mode;
	}

	static function get_mode():Int
	{
		if (forcedControl != null)
			return forcedControl;

		if (FlxG.save.data.mobileControlsMode == null)
		{
			FlxG.save.data.mobileControlsMode = 0;
			FlxG.save.flush();
		}

		return FlxG.save.data.mobileControlsMode;
	}

	@:noCompletion
	private static function get_mobileC():Bool return Options.controlsAlpha >= 0.1;
	/*
	public function updateButtonsColors() {
		// Dynamic Controls Color
		var buttonsColors:Array<FlxColor> = [];
		var data:Dynamic;
		if (ClientPrefs.data.dynamicColors)
			data = ClientPrefs.data;
		else
			data = ClientPrefs.defaultData;

		buttonsColors.push(data.arrowRGB[0][0]);
		buttonsColors.push(data.arrowRGB[1][0]);
		buttonsColors.push(data.arrowRGB[2][0]);
		buttonsColors.push(data.arrowRGB[3][0]);
		if (mode == 3)
		{
			virtualPad.buttonLeft2.color = buttonsColors[0];
			virtualPad.buttonDown2.color = buttonsColors[1];
			virtualPad.buttonUp2.color = buttonsColors[2];
			virtualPad.buttonRight2.color = buttonsColors[3];
		}
		current.buttonLeft.color = buttonsColors[0];
		current.buttonDown.color = buttonsColors[1];
		current.buttonUp.color = buttonsColors[2];
		current.buttonRight.color = buttonsColors[3];
	}
	*/
}

class CurrentManager {
	public var buttonLeft:FlxButton;
	public var buttonDown:FlxButton;
	public var buttonUp:FlxButton;
	public var buttonRight:FlxButton;
	//public var buttonExtra:FlxButton;
	//public var buttonExtra2:FlxButton;
	public var target:FlxButtonGroup;

	public function new(control:MobileControls){
		if(MobileControls.mode == 4) {
			target = control.hitbox;
			buttonLeft = control.hitbox.buttonLeft;
			buttonDown = control.hitbox.buttonDown;
			buttonUp = control.hitbox.buttonUp;
			buttonRight = control.hitbox.buttonRight;
			//buttonExtra = control.hitbox.buttonExtra;
			//buttonExtra2 = control.hitbox.buttonExtra2;
		} else {
			target = control.virtualPad;
			buttonLeft = control.virtualPad.buttonLeft;
			buttonDown = control.virtualPad.buttonDown;
			buttonUp = control.virtualPad.buttonUp;
			buttonRight = control.virtualPad.buttonRight;
			//buttonExtra = control.virtualPad.buttonExtra;
			//buttonExtra2 = control.virtualPad.buttonExtra2;
		}
	}
}