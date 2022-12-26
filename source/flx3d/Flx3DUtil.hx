package flx3D;

import away3d.core.managers.Stage3DManager;
import away3d.library.assets.IAsset;
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
	/**
	 * Returns the total amount of 3D stages (not exculding the ones in use)
	 * @return Int
	 */
	public static inline function getTotal3D():Int
	{
		return FlxG.stage.stage3Ds.length;
	}

	/**
	 * Returns if a Stage3D is available
	 * @return Bool
	 */
	public static inline function is3DAvailable():Bool
	{
		@:privateAccess {
			if (Stage3DManager._stageProxies == null)
				return true;

			return Stage3DManager._numStageProxies < Stage3DManager._stageProxies.length;
		}
	}

	/**
	 * Calls dispose() (destroy) on a Away3D asset
	 * @param obj 
	 * @return null
	 */
	public static inline function dispose<T:IAsset>(obj:Null<T>):T
	{
		if (obj != null)
			obj.dispose();

		return null;
	}
}
