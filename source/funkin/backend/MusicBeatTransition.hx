package funkin.backend;

import flixel.tweens.FlxTween;
import flixel.FlxState;
import funkin.backend.utils.FunkinParentDisabler;

class MusicBeatTransition extends MusicBeatSubstate {
	var nextFrameSkip:Bool = false;

	public var transitionTween:FlxTween = null;
	public var transitionCamera:FlxCamera;
	public var newState:FlxState;

	public var blackSpr:FlxSprite;
	public var transitionSprite:FunkinSprite;
	public function new(?newState:FlxState) {
		super();
		this.newState = newState;
	}

	public override function create() {
		if (newState != null)
			add(new FunkinParentDisabler(true));

		transitionCamera = new FlxCamera();
		transitionCamera.bgColor = 0;
		FlxG.cameras.add(transitionCamera, false);

		cameras = [transitionCamera];
		var out = newState != null;

		blackSpr = new FlxSprite(0, out ? -transitionCamera.height : transitionCamera.height).makeGraphic(1, 1, -1);
		blackSpr.scale.set(transitionCamera.width, transitionCamera.height);
		blackSpr.color = 0xFF000000;
		blackSpr.updateHitbox();
		add(blackSpr);

		transitionSprite = new FunkinSprite();
		transitionSprite.loadSprite(Paths.image('menus/transitionSpr'));
		if (transitionSprite.animateAtlas == null) {
			transitionSprite.setGraphicSize(transitionCamera.width, transitionCamera.height);
			transitionSprite.updateHitbox();
		} else {
			transitionSprite.screenCenter();
		}
		transitionCamera.flipY = !out;
		add(transitionSprite);

		transitionCamera.scroll.y = transitionCamera.height;
		transitionTween = FlxTween.tween(transitionCamera.scroll, {y: -transitionCamera.height}, 2/3, {
			ease: FlxEase.sineOut,
			onComplete: function(_) {
				finish();
			}
		});
		
		super.create();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (nextFrameSkip) {
			finish();
			return;
		}

		if (!parent.persistentUpdate && FlxG.keys.pressed.SHIFT) {
			// skip
			if (newState != null) {
				nextFrameSkip = true;
				parent.persistentDraw = false;
			} else {
				finish();
			}
		}
	}

	public function finish() {
		if (newState != null)
			FlxG.switchState(newState);
		close();
	}

	public override function destroy() {
		if (transitionTween != null)
			transitionTween.cancel();
		transitionTween = FlxDestroyUtil.destroy(transitionTween);
		if (newState == null && FlxG.cameras.list.contains(transitionCamera))
			FlxG.cameras.remove(transitionCamera);
		else
			transitionCamera.bgColor = 0xFF000000;
		super.destroy();
	}
}