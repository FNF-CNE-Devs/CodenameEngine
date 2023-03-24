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
		for(o in topMenuOptions) {
			if (o == null) continue;

			if (o.keybind != null) {
				var pressed = true;
				var justPressed = false;
				for(keybind in o.keybind) {
					if (FlxG.keys.checkStatus(keybind, JUST_PRESSED)) {
						justPressed = true;
					} else if (!FlxG.keys.checkStatus(keybind, PRESSED)) {
						pressed = false;
						break;
					}
				}
				if (!pressed || !justPressed) continue;

				if (o.onSelect != null)
					o.onSelect(o);

				return true;
			}

			if (o.childs != null && processShortcuts(o.childs))
				return true;
		}
		return false;
	}

	public static function toUIString(key:FlxKey):String {
		return switch(key) {
			case CONTROL: 		#if mac "Cmd" #else "Ctrl" #end;
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
			default: prettify(key.toString());
		}
	}

	public static function prettify(str:String) {
		return [for(s in str.split(" ")) [for(k=>l in s.split("")) k == 0 ? l.toUpperCase() : l.toLowerCase()].join("")].join(" ");
	}
}