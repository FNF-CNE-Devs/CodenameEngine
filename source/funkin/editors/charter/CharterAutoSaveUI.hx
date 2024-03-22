package funkin.editors.charter;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.math.FlxRect;

using flixel.util.FlxSpriteUtil;

class CharterAutoSaveUI extends UISliceSprite {
	public var icon:FlxSprite;
	public var autosavingText:UIText;
	public var progressBarBack:FlxSprite;
	public var progressBar:FlxSprite;

	public var showedAnimation:Bool = false;

	public function new(x:Float, y:Float) {
		super(x, y, 300, 46, "editors/ui/inputbox");

		icon = new FlxSprite(x+12, y+10).loadGraphic(Paths.image("editors/autosave-icons"), true, 10, 10);
		icon.animation.add("icon", [for(i in 0...2) i], 0, true);
		icon.animation.play("icon"); icon.animation.curAnim.curFrame = 0;
		members.push(icon);

		members.push(autosavingText = new UIText(x+12+10+4, y+8, 0, "Autosaving in 10 seconds...", 12));

		progressBarBack = new FlxSprite(x + 10, y + bHeight - 20).makeGraphic(Std.int(bWidth-20), 10, 0x00000000, true);
		progressBarBack.drawRoundRect(0, 0, progressBarBack.width, progressBarBack.height, 4, 6, 0xFF727272, null, {smoothing: false});
		progressBarBack.drawRoundRect(1, 1, progressBarBack.width-2, progressBarBack.height-2, 4, 6, 0xFF0D0D0D, null, {smoothing: false});
		members.push(progressBarBack);

		progressBar = new FlxSprite(x + 10, y + bHeight - 20).makeGraphic(Std.int(bWidth-20), 10, 0x00000000, true);
		progressBar.drawRoundRect(0, 0, progressBar.width, progressBar.height, 4, 6, 0xFF727272, null, {smoothing: false});
		progressBar.drawRoundRect(1, 1, progressBar.width-2, progressBar.height-2, 4, 6, 0xFFFFFFFF, null, {smoothing: false});
		progressBar.antialiasing = false; progressBar.clipRect = new FlxRect(0, 0, progressBar.width, progressBar.height);
		members.push(progressBar);

		alpha = 0;
	}

	public function startAutoSave(time:Float, sucessText:String) {
		appearAnimation();
		
		FlxTween.num(0, 1, time, null, (v:Float) -> {
			if ((progress = v) < .95) {
				autosavingText.text = 'Autosaving in ${Math.min(Math.round(time), 1+Math.floor(Math.abs(time-(progress*time))))} seconds';
				autosavingText.text += [for (i in 0...(Math.floor((progress*time*3)%4))) "."].join("");
			}
		});
		(new FlxTimer()).start(time, (_) -> {
			autosavingText.text = sucessText;

			icon.animation.curAnim.curFrame = 1;
			for (member in [this, progressBar, progressBarBack, autosavingText]) member.color = 0xFFA3EC95;

			(new FlxTimer()).start(1, (_) -> {disappearAnimation();});
		});
	}

	public var progress:Float = 0;
	public override function update(elapsed:Float) {
		super.update(elapsed);

		icon.follow(this, 12, 9);
		icon.alpha = alpha;

		autosavingText.follow(this, 12+10+4, 8);
		autosavingText.alpha = alpha;
		
		for (bar in [progressBar, progressBarBack]) {
			bar.follow(this, 10, bHeight-20);
			bar.alpha = alpha;
		}
		progressBar.clipRect = progressBar.clipRect.set(0, 0, progressBar.width*progress,progressBar.height);
	}

	public function appearAnimation() {
		autosavingText.text = "Autosaving in seconds..."; progress = 0; icon.animation.curAnim.curFrame = 0;
		for (member in [this, autosavingText, progressBar, progressBarBack]) member.color = 0xFFFFFFFF;

		x = -(320); alpha=0; FlxTween.cancelTweensOf(this);
		FlxTween.tween(this, {x: 20}, .4, {ease: FlxEase.circInOut});
		FlxTween.tween(this, {alpha: 1}, .3, {ease: FlxEase.sineOut, startDelay: .1});

		showedAnimation = true;
	}

	public function disappearAnimation() {
		x = 20; alpha = 1; FlxTween.cancelTweensOf(this);
		FlxTween.tween(this, {alpha: 0}, .4, {ease: FlxEase.sineOut});

		showedAnimation = false;
	}
}