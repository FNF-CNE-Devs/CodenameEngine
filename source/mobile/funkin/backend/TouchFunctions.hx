package mobile.funkin.backend;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.input.touch.FlxTouch;

class TouchFunctions
{
	public static var touchPressed(get, never):Bool;
	public static var touchJustPressed(get, never):Bool;
	public static var touchJustReleased(get, never):Bool;
	public static var touch(get, never):FlxTouch;

	public static function touchOverlapObject(object:FlxBasic, camera:FlxCamera):Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.overlaps(object, camera))
				return true;
		return false;
	}

	public static function touchOverlapObjectComplex(object:FlxObject):Bool
	{
		var overlap = false;
		for (camera in object.cameras)
		{
			for (touch in FlxG.touches.list)
			{
				@:privateAccess
				if (object.overlapsPoint(touch.getWorldPosition(camera, object._point), true, camera))
					overlap = true;
			}
		}
		return overlap;
	}

	@:noCompletion
	private static function get_touchPressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.pressed)
				return true;
		return false;
	}

	@:noCompletion
	private static function get_touchJustPressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				return true;
		return false;
	}

	@:noCompletion
	private static function get_touchJustReleased():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				return true;
		return false;
	}

	@:noCompletion
	private static function get_touch():FlxTouch
	{
		for (touch in FlxG.touches.list)
			return touch;
		return FlxG.touches.list[0];
	}
}
