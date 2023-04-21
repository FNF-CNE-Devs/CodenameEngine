package funkin.editors.ui;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import funkin.backend.shaders.CustomShader;

class UIWarningSubstate extends MusicBeatSubstate {
	var camShaders:Array<FlxCamera> = [];
	var blurShader:CustomShader = new CustomShader("engine/editorBlur");

	var title:String;
	var message:String;
	var buttons:Array<WarningButton>;

	var titleSpr:UIText;
	var messageSpr:UIText;

	var warnCam:FlxCamera;

	public override function onSubstateOpen() {
		super.onSubstateOpen();
		parent.persistentUpdate = false;
		parent.persistentDraw = true;
	}

	public override function create() {
		for(c in FlxG.cameras.list) {
			camShaders.push(c);
			c.addShader(blurShader);
		}

		camera = warnCam = new FlxCamera();
		warnCam.bgColor = 0;
		warnCam.alpha = 0;
		warnCam.zoom = 0.1;
		FlxG.cameras.add(warnCam, false);

		var spr = new UISliceSprite(0, 0, CoolUtil.maxInt(560, 30 + (170 * buttons.length)), 280, "editors/ui/warning-popup");
		spr.x = (FlxG.width - spr.bWidth) / 2;
		spr.y = (FlxG.height - spr.bHeight) / 2;
		add(spr);

		add(titleSpr = new UIText(spr.x + 25, spr.y, spr.bWidth - 50, title, 15, -1));
		titleSpr.y = spr.y + ((30 - titleSpr.height) / 2);

		add(messageSpr = new UIText(spr.x + 10, spr.y + 40, spr.bWidth - 20, message, 15, -1));

		var xPos = (FlxG.width - (30 + (170 * buttons.length))) / 2;
		for(k=>b in buttons) {
			var button = new UIButton(xPos + 20 + (170 * k), spr.y + spr.bHeight - 40, b.label, function() {
				b.onClick(this);
				close();
			}, 160, 30);
			add(button);
		}

		FlxTween.tween(camera, {alpha: 1}, 0.25, {ease: FlxEase.cubeOut});
		FlxTween.tween(camera, {zoom: 1}, 0.66, {ease: FlxEase.elasticOut});

		CoolUtil.playMenuSFX(WARNING);
	}

	public override function destroy() {
		super.destroy();
		for(e in camShaders)
			e.removeShader(blurShader);

		FlxTween.cancelTweensOf(warnCam);
		FlxG.cameras.remove(warnCam);
	}

	public function new(title:String, message:String, buttons:Array<WarningButton>) {
		super();
		this.title = title;
		this.message = message;
		this.buttons = buttons;
	}
}
typedef WarningCamShader = {
	var cam:FlxCamera;
}
typedef WarningButton = {
	var label:String;
	var onClick:UIWarningSubstate->Void;
}