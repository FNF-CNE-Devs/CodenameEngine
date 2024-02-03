package funkin.editors.charter;

import funkin.backend.chart.EventsData;

class CharterEventTypeSelection extends UISubstateWindow {
	var callback:String->Void;

	var buttons:Array<UIButton> = [];

	var buttonsBG:UISliceSprite;
	var buttonCameras:FlxCamera;

	public function new(callback:String->Void) {
		super();
		this.callback = callback;
	}

	public override function create() {
		winTitle = "Choose an event type...";
		super.create();

		var w:Int = winWidth - 20;

		buttonCameras = new FlxCamera(Std.int(windowSpr.x+41), Std.int(windowSpr.y), w, (32 * 16));
		FlxG.cameras.add(buttonCameras, false);
		buttonCameras.bgColor = 0;

		buttonsBG = new UIWindow(10, 41, buttonCameras.width, buttonCameras.height, "");
		buttonsBG.frames = Paths.getFrames('editors/ui/inputbox');
		add(buttonsBG);

		for(k=>eventName in EventsData.eventsList) {
			var button = new UIButton(0, (32 * k), eventName, function() {
				close();
				callback(eventName);
			}, w);
			button.autoAlpha = false;
			button.cameras = [buttonCameras];
			buttons.push(cast add(button));

			var icon = CharterEvent.generateEventIcon({
				name: eventName,
				time: 0,
				params: []
			});
			// icon.setGraphicSize(20, 20); // Std.int(button.bHeight - 12)
			icon.updateHitbox();
			icon.cameras = [buttonCameras];
			icon.x = button.x + 8;
			icon.y = button.y + Math.abs(button.bHeight - icon.height) / 2;
			add(icon);
		}

		windowSpr.bHeight = 61 + (32 * (17));

		add(new UIButton(10, windowSpr.bHeight-42, "Cancel", function() {
			close();
		}, w));

	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		for (button in buttons)
			button.selectable = buttonsBG.hovered;

		buttonCameras.zoom = subCam.zoom;

		buttonCameras.x = -subCam.scroll.x + Std.int(windowSpr.x+10);
		buttonCameras.y = -subCam.scroll.y + Std.int(windowSpr.y+41);

		if (buttons.length > 16)
			buttonCameras.scroll.y = FlxMath.bound(buttonCameras.scroll.y - (buttonsBG.hovered ? FlxG.mouse.wheel : 0) * 12, 0,
				(buttons[buttons.length-1].y + buttons[buttons.length-1].bHeight) - buttonCameras.height);
	}

	override function destroy() {
		super.destroy();

		if(buttonCameras != null) {
			if (FlxG.cameras.list.contains(buttonCameras))
				FlxG.cameras.remove(buttonCameras);
			buttonCameras = null;
		}
	}
}