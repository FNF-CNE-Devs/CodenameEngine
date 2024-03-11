package funkin.editors.ui;

import lime.ui.KeyModifier;
import lime.ui.KeyCode;
import funkin.backend.system.framerate.Framerate;
import funkin.editors.ui.UIContextMenu.UIContextMenuCallback;
import openfl.ui.Mouse;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import flixel.math.FlxPoint;
import openfl.ui.MouseCursor;
import flixel.math.FlxRect;

class UIState extends MusicBeatState {
	public var curContextMenu:UIContextMenu = null;

	public static var state(get, null):UIState;

	public var buttonHandler:Void->Void = null;
	public var hoveredSprite:UISprite = null;
	public var currentFocus:IUIFocusable = null;

	public var currentCursor:MouseCursor = ARROW;

	private var __rect:FlxRect;
	private var __mousePos:FlxPoint;

	private inline static function get_state()
		return FlxG.state is UIState ? cast FlxG.state : null;

	public override function create() {
		__rect = new FlxRect();
		__mousePos = FlxPoint.get();
		super.create();
		Framerate.offset.y = 30;
		FlxG.mouse.visible = true;

		FlxG.stage.window.onKeyDown.add(onKeyDown);
		FlxG.stage.window.onKeyUp.add(onKeyUp);
		FlxG.stage.window.onTextInput.add(onTextInput);
		FlxG.stage.window.onTextEdit.add(onTextEdit);
	}

	private function onKeyDown(e:KeyCode, modifier:KeyModifier) {
		if (currentFocus != null)
			currentFocus.onKeyDown(e, modifier);
	}

	private function onKeyUp(e:KeyCode, modifier:KeyModifier) {
		if (currentFocus != null)
			currentFocus.onKeyUp(e, modifier);
	}

	private function onTextInput(str:String) {
		if (currentFocus != null)
			currentFocus.onTextInput(str);
	}
	private function onTextEdit(str:String, start:Int, end:Int) {
		if (currentFocus != null)
			currentFocus.onTextEdit(str, start, end);
	}

	public inline function updateSpriteRect(spr:UISprite) {
		spr.__rect.x = spr.x;
		spr.__rect.y = spr.y;
		spr.__rect.width = spr.width;
		spr.__rect.height = spr.height;
	}

	public function updateButtonHandler(spr:UISprite, buttonHandler:Void->Void) {
		spr.__rect.x = spr.x;
		spr.__rect.y = spr.y;
		spr.__rect.width = spr.width;
		spr.__rect.height = spr.height;
		updateRectButtonHandler(spr, spr.__rect, buttonHandler);
	}

	public function isOverlapping(spr:UISprite, rect:FlxRect) {
		for(camera in spr.__lastDrawCameras) {
			var pos = FlxG.mouse.getScreenPosition(camera, FlxPoint.get());
			__rect.x = rect.x;
			__rect.y = rect.y;
			__rect.width = rect.width;
			__rect.height = rect.height;

			__rect.x -= camera.scroll.x * spr.scrollFactor.x;
			__rect.y -= camera.scroll.y * spr.scrollFactor.y;

			if (((pos.x > __rect.x) && (pos.x < __rect.x + __rect.width)) && ((pos.y > __rect.y) && (pos.y < __rect.y + __rect.height))) {
				pos.put();
				return true;
			}
			pos.put();
		}
		return false;
	}

	public function updateRectButtonHandler(spr:UISprite, rect:FlxRect, buttonHandler:Void->Void) {
		if(isOverlapping(spr, rect)) {
			spr.hoveredByChild = true;
			this.hoveredSprite = spr;
			this.buttonHandler = buttonHandler;
		}
	}

	public override function tryUpdate(elapsed:Float) {
		FlxG.mouse.getScreenPosition(FlxG.camera, __mousePos);

		super.tryUpdate(elapsed);

		if (buttonHandler != null) {
			buttonHandler();
			buttonHandler = null;
		}

		if (FlxG.mouse.justReleased)
			currentFocus = (hoveredSprite is IUIFocusable) ? (cast hoveredSprite) : null;

		FlxG.sound.keysAllowed = currentFocus != null ? !(currentFocus is UITextBox) : true;

		if (hoveredSprite != null) {
			Mouse.cursor = hoveredSprite.cursor;
			hoveredSprite = null;
		} else {
			Mouse.cursor = currentCursor;
		}
	}

	public override function destroy() {
		super.destroy();
		__mousePos.put();

		WindowUtils.resetTitle();
		SaveWarning.reset();

		FlxG.stage.window.onKeyDown.remove(onKeyDown);
		FlxG.stage.window.onKeyUp.remove(onKeyUp);
		FlxG.stage.window.onTextInput.remove(onTextInput);
		FlxG.stage.window.onTextEdit.remove(onTextEdit);
	}

	public function closeCurrentContextMenu() {
		if(curContextMenu != null) {
			curContextMenu.close();
			curContextMenu = null;
		}
	}

	public function openContextMenu(options:Array<UIContextMenuOption>, ?callback:UIContextMenuCallback, ?x:Float, ?y:Float) {
		var state = FlxG.state;
		while(state.subState != null && !(state._requestSubStateReset && state._requestedSubState == null))
			state = state.subState;

		state.persistentDraw = true;
		state.persistentUpdate = true;

		state.openSubState(curContextMenu = new UIContextMenu(options, callback, x.getDefault(__mousePos.x), y.getDefault(__mousePos.y)));
		return curContextMenu;
	}
}