package funkin.backend.utils;

import funkin.backend.utils.native.*;

/**
 * Class for Windows-only functions, such as transparent windows, message boxes, and more.
 * Does not have any effect on other platforms.
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
	public static function setConsoleColors(foregroundColor:ConsoleColor = LIGHTGRAY, ?backgroundColor:ConsoleColor = BLACK) {
		#if windows
		var fg = cast(foregroundColor, Int);
		var bg = cast(backgroundColor, Int);
		Windows.setConsoleColors((bg * 16) + fg);
		#end
	}

	public static function consoleColorToOpenFL(color:ConsoleColor) {
		return switch(color) {
			case BLACK:		 0xFF000000;
			case DARKBLUE:	  0xFF000088;
			case DARKGREEN:	 0xFF008800;
			case DARKCYAN:	  0xFF008888;
			case DARKRED:	   0xFF880000;
			case DARKMAGENTA:   0xFF880000;
			case DARKYELLOW:	0xFF888800;
			case LIGHTGRAY:	 0xFFBBBBBB;
			case GRAY:		  0xFF888888;
			case BLUE:		  0xFF0000FF;
			case GREEN:		 0xFF00FF00;
			case CYAN:		  0xFF00FFFF;
			case RED:		   0xFFFF0000;
			case MAGENTA:	   0xFFFF00FF;
			case YELLOW:		0xFFFFFF00;
			case WHITE | _:	 0xFFFFFFFF;
		}
	}
}

@:enum abstract ConsoleColor(Int) {
	var BLACK:ConsoleColor = 0;
	var DARKBLUE:ConsoleColor = 1;
	var DARKGREEN:ConsoleColor = 2;
	var DARKCYAN:ConsoleColor = 3;
	var DARKRED:ConsoleColor = 4;
	var DARKMAGENTA:ConsoleColor = 5;
	var DARKYELLOW:ConsoleColor = 6;
	var LIGHTGRAY:ConsoleColor = 7;
	var GRAY:ConsoleColor = 8;
	var BLUE:ConsoleColor = 9;
	var GREEN:ConsoleColor = 10;
	var CYAN:ConsoleColor = 11;
	var RED:ConsoleColor = 12;
	var MAGENTA:ConsoleColor = 13;
	var YELLOW:ConsoleColor = 14;
	var WHITE:ConsoleColor = 15;
}

@:enum abstract MessageBoxIcon(Int) {
	var MSG_ERROR:MessageBoxIcon = 0x00000010;
	var MSG_QUESTION:MessageBoxIcon = 0x00000020;
	var MSG_WARNING:MessageBoxIcon = 0x00000030;
	var MSG_INFORMATION:MessageBoxIcon = 0x00000040;
}