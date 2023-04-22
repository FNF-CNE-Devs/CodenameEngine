package funkin.editors.ui;

import flixel.input.keyboard.FlxKey;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;

class UIUtil {
	public static function follow(spr:FlxSprite, target:FlxSprite, x:Float = 0, y:Float = 0) {
		spr.cameras = target is UISprite ? cast(target, UISprite).__lastDrawCameras : target.cameras;
		spr.setPosition(target.x + x, target.y + y);
		spr.scrollFactor.set(target.scrollFactor.x, target.scrollFactor.y);
	}

	public static function contextMenuOpened(contextMenu:UIContextMenu) {
		return contextMenu != null && UIState.state.curContextMenu == contextMenu;
	}

	/**
	 * Process all options with shortcuts present in a `Array<UIContextMenuOption>`. Also checks childrens.
	 * @param topMenuOptions
	 */
	public static function processShortcuts(topMenuOptions:Array<UIContextMenuOption>) {
		var maxKeyLength = 0;
		var curTopMenuOption = null;

		for(o in topMenuOptions) {
			if (o == null) continue;

			if (o.keybinds == null) {
				if (o.keybind != null) {
					o.keybinds = [o.keybind];
				}
			}

			if (o.keybinds != null) {
				for (keybind in o.keybinds) {
					var pressed = true;
					var justPressed = false;
					var needsShift = keybind.contains(SHIFT);

					for (key in keybind) {
						var shouldPress = Std.int(key) > 0;
						if(!shouldPress) key = -key;

						var k = switch(key) {
							#if mac
							case CONTROL:
								WINDOWS;
							#end
							default:
								key;
						}
						if (FlxG.keys.checkStatus(k, shouldPress ? JUST_PRESSED : JUST_RELEASED)) {
							justPressed = true;
						} else if (!FlxG.keys.checkStatus(k, shouldPress ? PRESSED : RELEASED)) {
							pressed = false;
							break;
						}
					}
					if (!needsShift && FlxG.keys.pressed.SHIFT) continue;
					if (!pressed || !justPressed) continue;

					if (maxKeyLength < o.keybinds.length) {
						maxKeyLength = o.keybinds.length;
						curTopMenuOption = o;
					}
				}
			}

			if (o.childs != null && processShortcuts(o.childs))
				return true;
		}

		if (curTopMenuOption != null) {
			if (curTopMenuOption.onSelect != null)
				curTopMenuOption.onSelect(curTopMenuOption);
			return true;
		}
		return false;
	}

	public static function toUIString(key:FlxKey):String {
		return switch(key) {
			case CONTROL: 		#if mac "Cmd" #else "Ctrl" #end; // ⌘
			case ALT:			#if mac "Option" #else "Alt" #end;
			case HOME:			"Home";
			case ENTER:			"Enter";
			case DELETE:		"Del";
			case SHIFT:			"Shift";
			case SPACE:			"Space";
			case NUMPADZERO:	"[0]";
			case NUMPADONE:		"[1]";
			case NUMPADTWO:		"[2]";
			case NUMPADTHREE:	"[3]";
			case NUMPADFOUR:	"[4]";
			case NUMPADFIVE:	"[5]";
			case NUMPADSIX:		"[6]";
			case NUMPADSEVEN:	"[7]";
			case NUMPADEIGHT:	"[8]";
			case NUMPADNINE:	"[9]";
			case NUMPADPLUS:	"[+]";
			case NUMPADMINUS:	"[-]";
			case ZERO:			"0";
			case ONE:			"1";
			case TWO:			"2";
			case THREE:			"3";
			case FOUR:			"4";
			case FIVE:			"5";
			case SIX:			"6";
			case SEVEN:			"7";
			case EIGHT:			"8";
			case NINE:			"9";
			default: prettify(key.toString());
		}
	}

	public static inline function prettify(str:String) {
		return [for(s in str.split(" ")) [for(k=>l in s.split("")) k == 0 ? l.toUpperCase() : l.toLowerCase()].join("")].join(" ");
	}
}