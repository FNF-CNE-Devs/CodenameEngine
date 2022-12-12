package openfl.display3D.utils;

import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxPool;
import lime.utils.UInt8Array;

class UInt8Buff implements IFlxPooled
{
	static var _pools:Map<Int, FlxPool<UInt8Buff>> = [];

	public static function getPool(length:Int) {
		if(!_pools.exists(length)) {
			_pools.set(length, new FlxPool<UInt8Buff>(UInt8Buff));
		}
		return _pools.get(length);
	}

	/**
	 * Recycle or create new FlxRect.
	 * Be sure to put() them back into the pool after you're done with them!
	 */
	public static inline function get(length:Int):UInt8Buff
	{
		var rect = getPool(length).get().set(length);
		rect._inPool = false;
		if(rect.buffer == null)
			rect.buffer = new UInt8Array(length);
		return rect;
	}

	/**
	 * Recycle or create a new FlxRect which will automatically be released
	 * to the pool when passed into a flixel function.
	 */
	public static inline function weak(length:Int):UInt8Buff
	{
		var rect = get(length);
		rect._weak = true;
		return rect;
	}

	var _weak:Bool = false;
	var _inPool:Bool = false;

	public var length(get, never):Int;

	inline function get_length() {
		return buffer.length;
	}

	public var buffer:UInt8Array;

	@:keep
	private function new(length:Int)
	{
		set(length);
	}

	/**
	 * Add this FlxRect to the recycling pool.
	 */
	public inline function put():Void
	{
		if (!_inPool)
		{
			_inPool = true;
			_weak = false;
			getPool(length).putUnsafe(this);
		}
	}

	/**
	 * Add this FlxPoint to the recycling pool if it's a weak reference (allocated via weak()).
	 */
	public inline function putWeak():Void
	{
		if (_weak)
		{
			put();
		}
	}

	/**
	 * Does nothing
	 */
	private inline function set(_length:Int):UInt8Buff
	{
		return this;
	}

	/**
	 * Necessary for IFlxDestroyable.
	 */
	public function destroy() {}
}
