package funkin.backend.utils;

import funkin.backend.utils.native.*;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfThree;

/**
 * Class for functions that talk to a lower level than haxe, such as message boxes, and more.
 * Some functions might not have effect on some platforms.
 */
class NativeAPI {
	@:dox(hide) public static function registerAudio() {
		#if windows
		Windows.registerAudio();
		#end
	}

	@:dox(hide) public static function registerAsDPICompatible() {
		#if windows
		Windows.registerAsDPICompatible();
		#end
	}

	/**
	 * Allocates a new console. The console will automatically be opened
	 */
	public static function allocConsole() {
		#if windows
		Windows.allocConsole();
		Windows.clearScreen();
		#end
	}

	/**
	 * Gets the specified file's (or folder) attributes.
	 */
	public static function getFileAttributesRaw(path:String, useAbsol:Bool = true):Int {
		#if windows
		if(useAbsol) path = sys.FileSystem.absolutePath(path);
		return Windows.getFileAttributes(path);
		#else
		return -1;
		#end
	}

	/**
	 * Gets the specified file's (or folder) attributes and passes it to `FileAttributeWrapper`.
	 */
	public static function getFileAttributes(path:String, useAbsol:Bool = true):FileAttributeWrapper {
		return new FileAttributeWrapper(getFileAttributesRaw(path, useAbsol));
	}

	/**
	 * Sets the specified file's (or folder) attributes. If it fails, the return value is `0`.
	 */
	public static function setFileAttributes(path:String, attrib:OneOfThree<NativeAPI.FileAttribute, FileAttributeWrapper, Int>, useAbsol:Bool = true):Int {
		#if windows
		if(useAbsol) path = sys.FileSystem.absolutePath(path);
		return Windows.setFileAttributes(path, attrib is FileAttributeWrapper ? cast(attrib, FileAttributeWrapper).getValue() : cast(attrib, Int));
		#else
		return 0;
		#end
	}

	/**
	 * Removes from the specified file's (or folder) one (or more) specific attribute.
	 */
	public static function addFileAttributes(path:String, attrib:OneOfTwo<NativeAPI.FileAttribute, Int>, useAbsol:Bool = true):Int {
		#if windows
		return setFileAttributes(path, getFileAttributesRaw(path, useAbsol) | cast(attrib, Int), useAbsol);
		#else
		return 0;
		#end
	}

	/**
	 * Removes from the specified file's (or folder) one (or more) specific attribute.
	 */
	public static function removeFileAttributes(path:String, attrib:OneOfTwo<NativeAPI.FileAttribute, Int>, useAbsol:Bool = true):Int {
		#if windows
		return setFileAttributes(path, getFileAttributesRaw(path, useAbsol) & ~cast(attrib, Int), useAbsol);
		#else
		return 0;
		#end
	}

	public static function setDarkMode(title:String, enable:Bool) {
		#if windows
		Windows.setDarkMode(title, enable);
		#end
	}

	/**
	 * Shows a message box
	 */
	public static function showMessageBox(caption:String, message:String, icon:MessageBoxIcon = MSG_WARNING) {
		#if windows
		Windows.showMessageBox(caption, message, icon);
		#else
		lime.app.Application.current.window.alert(message, caption);
		#end
	}

	/**
	 * Sets the console colors
	 */
	public static function setConsoleColors(foregroundColor:ConsoleColor = NONE, ?backgroundColor:ConsoleColor = NONE) {
		if(Main.noTerminalColor) return;

		#if (windows && !hl)
		if(foregroundColor == NONE)
			foregroundColor = LIGHTGRAY;
		if(backgroundColor == NONE)
			backgroundColor = BLACK;

		var fg = cast(foregroundColor, Int);
		var bg = cast(backgroundColor, Int);
		Windows.setConsoleColors((bg * 16) + fg);
		#elseif sys
		Sys.print("\x1b[0m");
		if(foregroundColor != NONE)
			Sys.print("\x1b[" + Std.int(consoleColorToANSI(foregroundColor)) + "m");
		if(backgroundColor != NONE)
			Sys.print("\x1b[" + Std.int(consoleColorToANSI(backgroundColor) + 10) + "m");
		#end
	}

	public static function consoleColorToANSI(color:ConsoleColor) {
		return switch(color) {
			case BLACK:			30;
			case DARKBLUE:		34;
			case DARKGREEN:		32;
			case DARKCYAN:		36;
			case DARKRED:		31;
			case DARKMAGENTA:	35;
			case DARKYELLOW:	33;
			case LIGHTGRAY:		37;
			case GRAY:			90;
			case BLUE:			94;
			case GREEN:			92;
			case CYAN:			96;
			case RED:			91;
			case MAGENTA:		95;
			case YELLOW:		93;
			case WHITE | _:		97;
		}
	}

	public static function consoleColorToOpenFL(color:ConsoleColor) {
		return switch(color) {
			case BLACK:			0xFF000000;
			case DARKBLUE:		0xFF000088;
			case DARKGREEN:		0xFF008800;
			case DARKCYAN:		0xFF008888;
			case DARKRED:		0xFF880000;
			case DARKMAGENTA:	0xFF880000;
			case DARKYELLOW:	0xFF888800;
			case LIGHTGRAY:		0xFFBBBBBB;
			case GRAY:			0xFF888888;
			case BLUE:			0xFF0000FF;
			case GREEN:			0xFF00FF00;
			case CYAN:			0xFF00FFFF;
			case RED:			0xFFFF0000;
			case MAGENTA:		0xFFFF00FF;
			case YELLOW:		0xFFFFFF00;
			case WHITE | _:		0xFFFFFFFF;
		}
	}
}

enum abstract FileAttribute(Int) from Int to Int {
	// Settables
	var ARCHIVE = 0x20;
	var HIDDEN = 0x2;
	var NORMAL = 0x80;
	var NOT_CONTENT_INDEXED = 0x2000;
	var OFFLINE = 0x1000;
	var READONLY = 0x1;
	var SYSTEM = 0x4;
	var TEMPORARY = 0x100;

	// Non Settables
	var COMPRESSED = 0x800;
	var DEVICE = 0x40;
	var DIRECTORY = 0x10;
	var ENCRYPTED = 0x4000;
	var REPARSE_POINT = 0x400;
	var SPARSE_FILE = 0x200;
}

enum abstract ConsoleColor(Int) {
	var BLACK = 0;
	var DARKBLUE = 1;
	var DARKGREEN = 2;
	var DARKCYAN = 3;
	var DARKRED = 4;
	var DARKMAGENTA = 5;
	var DARKYELLOW = 6;
	var LIGHTGRAY = 7;
	var GRAY = 8;
	var BLUE = 9;
	var GREEN = 10;
	var CYAN = 11;
	var RED = 12;
	var MAGENTA = 13;
	var YELLOW = 14;
	var WHITE = 15;

	var NONE = -1;
}

enum abstract MessageBoxIcon(Int) {
	var MSG_ERROR = 0x00000010;
	var MSG_QUESTION = 0x00000020;
	var MSG_WARNING = 0x00000030;
	var MSG_INFORMATION = 0x00000040;
}