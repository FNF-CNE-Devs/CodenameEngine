package funkin.backend.utils;

import flixel.util.FlxStringUtil;
import funkin.backend.utils.NativeAPI.FileAttribute;

/**
 * Currently only for Windows, but planned to work on other platforms later.
 */
class FileAttributeWrapper
{
	private var flags:Int;
	inline public function getValue():Int
	{
		return flags;
	}

	public function new(flags:Int)
	{
		this.flags = flags == -1 ? 0 : flags;
	}

	/**
	 * Returns a string representation of the attributes.
	 */
	inline public function toString():String
	{
		return FlxStringUtil.getDebugString([
			for (field in Reflect.fields(this))
			{
				LabelValuePair.weak(field, Reflect.getProperty(this, field));
			}
		]);
	}

	// Settables
	public var isArchived(get, set):Bool;
	private function get_isArchived():Bool
	{
		#if windows
		return (flags & FileAttribute.ARCHIVE) != 0;
		#else
		return false;
		#end
	}
	private function set_isArchived(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.ARCHIVE;
		else
			flags &= ~FileAttribute.ARCHIVE;
		return value;
		#else
		return false;
		#end
	}

	public var isHidden(get, set):Bool;
	private function get_isHidden():Bool
	{
		#if windows
		return (flags & FileAttribute.HIDDEN) != 0;
		#else
		return false;
		#end
	}
	private function set_isHidden(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.HIDDEN;
		else
			flags &= ~FileAttribute.HIDDEN;
		return value;
		#else
		return false;
		#end
	}

	public var isNormal(get, set):Bool;
	private function get_isNormal():Bool
	{
		#if windows
		return (flags & FileAttribute.NORMAL) != 0;
		#else
		return false;
		#end
	}
	private function set_isNormal(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.NORMAL;
		else
			flags &= ~FileAttribute.NORMAL;
		return value;
		#else
		return false;
		#end
	}

	public var isNotContentIndexed(get, set):Bool;
	private function get_isNotContentIndexed():Bool
	{
		#if windows
		return (flags & FileAttribute.NOT_CONTENT_INDEXED) != 0;
		#else
		return false;
		#end
	}
	private function set_isNotContentIndexed(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.NOT_CONTENT_INDEXED;
		else
			flags &= ~FileAttribute.NOT_CONTENT_INDEXED;
		return value;
		#else
		return false;
		#end
	}

	public var isOffline(get, set):Bool;
	private function get_isOffline():Bool
	{
		#if windows
		return (flags & FileAttribute.OFFLINE) != 0;
		#else
		return false;
		#end
	}
	private function set_isOffline(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.OFFLINE;
		else
			flags &= ~FileAttribute.OFFLINE;
		return value;
		#else
		return false;
		#end
	}

	public var isReadOnly(get, set):Bool;
	private function get_isReadOnly():Bool
	{
		#if windows
		return (flags & FileAttribute.READONLY) != 0;
		#else
		return false;
		#end
	}
	private function set_isReadOnly(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.READONLY;
		else
			flags &= ~FileAttribute.READONLY;
		return value;
		#else
		return false;
		#end
	}

	public var isSystem(get, set):Bool;
	private function get_isSystem():Bool
	{
		#if windows
		return (flags & FileAttribute.SYSTEM) != 0;
		#else
		return false;
		#end
	}
	private function set_isSystem(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.SYSTEM;
		else
			flags &= ~FileAttribute.SYSTEM;
		return value;
		#else
		return false;
		#end
	}

	public var isTemporary(get, set):Bool;
	private function get_isTemporary():Bool
	{
		#if windows
		return (flags & FileAttribute.TEMPORARY) != 0;
		#else
		return false;
		#end
	}
	private function set_isTemporary(value:Bool):Bool
	{
		#if windows
		if (value)
			flags |= FileAttribute.TEMPORARY;
		else
			flags &= ~FileAttribute.TEMPORARY;
		return value;
		#else
		return false;
		#end
	}

	// Non Settables
	public var isCompressed(get, never):Bool;
	private function get_isCompressed():Bool
	{
		#if windows
		return (flags & FileAttribute.COMPRESSED) != 0;
		#else
		return false;
		#end
	}

	public var isDevice(get, never):Bool;
	private function get_isDevice():Bool
	{
		#if windows
		return (flags & FileAttribute.DEVICE) != 0;
		#else
		return false;
		#end
	}

	public var isDirectory(get, never):Bool;
	private function get_isDirectory():Bool
	{
		#if windows
		return (flags & FileAttribute.DIRECTORY) != 0;
		#else
		return false;
		#end
	}

	public var isEncrypted(get, never):Bool;
	private function get_isEncrypted():Bool
	{
		#if windows
		return (flags & FileAttribute.ENCRYPTED) != 0;
		#else
		return false;
		#end
	}

	public var isReparsePoint(get, never):Bool;
	private function get_isReparsePoint():Bool
	{
		#if windows
		return (flags & FileAttribute.REPARSE_POINT) != 0;
		#else
		return false;
		#end
	}

	public var isSparseFile(get, never):Bool;
	private function get_isSparseFile():Bool
	{
		#if windows
		return (flags & FileAttribute.SPARSE_FILE) != 0;
		#else
		return false;
		#end
	}

	// For checking
	public var isNothing(get, never):Bool;
	private function get_isNothing():Bool
	{
		#if windows
		return flags == 0;
		#else
		return true;
		#end
	}
}
