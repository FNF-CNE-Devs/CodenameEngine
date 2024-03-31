package funkin.editors.ui;

import flixel.tweens.FlxTween;
import openfl.filters.BlurFilter;

class UIWarningSubstate extends MusicBeatSubstate {
	var camFilters:Array<FlxCamera> = [];
	var blurFilter:BlurFilter = new BlurFilter(5, 5, Options.intensiveBlur);

	var title:String;
	var message:String;
	var buttons:Array<WarningButton>;
	var isError:Bool = true;

	var titleSpr:UIText;
	var messageSpr:UIText;

	var warnCam:FlxCamera;

	public override function onSubstateOpen() {
		super.onSubstateOpen();
		parent.persistentUpdate = false;
		parent.persistentDraw = true;
	}

	public override function create() {
		if (Options.blurBG) for(c in FlxG.cameras.list) {
			// Prevents a shader being added if there's already an existing one
			@:privateAccess if(c._filters != null) {
                var shouldSkip = false;
                for(filter in c._filters) {
                    if(filter is BlurFilter) {
                        var filter:BlurFilter = cast filter;
                        shouldSkip = true;
                        break;
					}
                }
                if(shouldSkip)
                    continue;
            }

			camFilters.push(c);
			c.setFilters([blurFilter]);
		}

		camera = warnCam = new FlxCamera();
		warnCam.bgColor = 0;
		warnCam.alpha = 0;
		warnCam.zoom = 0.1;
		FlxG.cameras.add(warnCam, false);

		var spr = new UISliceSprite(0, 0, CoolUtil.maxInt(560, 30 + (170 * buttons.length)), 232, 'editors/ui/${isError ? "normal" : "grayscale"}-popup');
		spr.x = (FlxG.width - spr.bWidth) / 2;
		spr.y = (FlxG.height - spr.bHeight) / 2;
		spr.color = isError ? 0xFFFF0000 : 0xFFFFFF00;
		add(spr);

		add(titleSpr = new UIText(spr.x + 25, spr.y, spr.bWidth - 50, title, 15, -1));
		titleSpr.y = spr.y + ((30 - titleSpr.height) / 2);

		var sprIcon:FlxSprite = new FlxSprite(spr.x + 18, spr.y + 28 + 26).loadGraphic(Paths.image('editors/warnings/${isError ? "error" : "warning"}'));
		sprIcon.scale.set(1.4, 1.4);
		sprIcon.updateHitbox();
		sprIcon.antialiasing = true;
		add(sprIcon);

		add(messageSpr = new UIText(sprIcon.x + 70 + 16 + 20, sprIcon.y + 16, spr.bWidth - 100 - (26 * 2), message));

		var xPos = (FlxG.width - (30 + (170 * buttons.length))) / 2;
		for(k=>b in buttons) {
			var button = new UIButton(xPos + 20 + (170 * k), spr.y + spr.bHeight - (36 + 16), b.label, function() {
				b.onClick(this);
				close();
			}, 160, 30);
			if (b.color != null) {
				button.frames = Paths.getFrames("editors/ui/grayscale-button");
				button.color = b.color;
			}
			add(button);
		}

		FlxTween.tween(camera, {alpha: 1}, 0.25, {ease: FlxEase.cubeOut});
		FlxTween.tween(camera, {zoom: 1}, 0.66, {ease: FlxEase.elasticOut});

		CoolUtil.playMenuSFX(WARNING);
	}

	public override function destroy() {
		if (Options.blurBG) @:privateAccess {
			for(e in camFilters)
				if(e._filters != null) e._filters.remove(blurFilter);
		}
		FlxTween.cancelTweensOf(warnCam);
		FlxG.cameras.remove(warnCam);
	}

	public function new(title:String, message:String, buttons:Array<WarningButton>, ?isError:Bool = true) {
		super();
		this.title = title;
		this.message = message;
		this.buttons = buttons;
		this.isError = isError;
	}
}

typedef WarningButton = {
	var label:String;
	var ?color:Int;
	var onClick:UIWarningSubstate->Void;
}