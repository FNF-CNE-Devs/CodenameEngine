package flx3d;

import away3d.core.managers.Stage3DManager;
import flixel.FlxG;

/**
 * @author lunarclient
 * @see https://twitter.com/lunarcleint
 * 
 * Help from Ne_Eo
 * @see https://twitter.com/Ne_Eo_Twitch
 */
class Flx3DUtil
{
	public static inline function getTotal3D():Int
	{
		return FlxG.stage.stage3Ds.length;
	}

	public static inline function is3DAvailable():Bool
	{
		@:privateAccess {
			if (Stage3DManager._stageProxies == null)
				return true;

			return Stage3DManager._numStageProxies < Stage3DManager._stageProxies.length;
		}
	}
}
