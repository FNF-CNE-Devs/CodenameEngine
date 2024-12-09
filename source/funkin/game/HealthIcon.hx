package funkin.game;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;

class HealthIcon extends FlxSprite
{
    public var sprTracker:FlxSprite;
    public var curCharacter:String = null;
    public var isPlayer:Bool;
    public var healthSteps:Map<Int, Int> = null;
    public var previousFrame:Int = 0;
    public var targetFrame:Int = 0;
    public var crossfadeAlpha:Float = 0.9;

	/**
	 * Helper for HScript who can't make maps
	 * @param steps Something like this: `[[0, 1], [20, 0]]`
	 */
	public function setHealthSteps(steps:Array<Array<Int>>) { // helper for hscript that can't do maps
		if (steps == null) return;
		healthSteps = [];
		for(s in steps)
			if (s.length > 1)
				healthSteps[s[0]] = s[1];
		var am = 0;
		for(k=>e in healthSteps) am++;

		if (am <= 0) healthSteps = [
			0  => 1, // losing icon
			20 => 0, // normal icon
		];
	}

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		health = 0.5;
		this.isPlayer = isPlayer;
		setIcon(char);

		scrollFactor.set();
	}

	public function setIcon(char:String, width:Int = 150, height:Int = 150) {
		if(curCharacter != char || this.width != width || this.height != height) {
			curCharacter = char;
			var path = Paths.image('icons/$char');
			if (!Assets.exists(path)) path = Paths.image('icons/face');

			loadGraphic(path, true, width, height);

			animation.add(char, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
			antialiasing = true;
			animation.play(char);

			healthSteps = [
				0  => 1, // losing icon
				30 => 0, // normal icon
			];

			if (frames.frames.length >= 3)
				healthSteps[60] = 2; // winning icon

            crossfadeAlpha = 0.9;
            previousFrame = 0;
            targetFrame = 0;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (sprTracker != null)
            setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);

        if (animation.curAnim != null) {
            var i:Int = -1;
            var oldKey:Int = -1;
            var keys = healthSteps.keys();
            for (key in keys) {
                var icon = healthSteps[key];
                if (key > oldKey && key <= health * 100) {
                    oldKey = key;
                    i = icon;
                }
            }

            if (i >= 0 && i != targetFrame) {
                previousFrame = animation.curAnim.curFrame;
                targetFrame = i;
                crossfadeAlpha = 0.9;
            }

            if (crossfadeAlpha < 1) {
                crossfadeAlpha += elapsed / 0.25; // fade time in seconds
                if (crossfadeAlpha >= 1) {
                    crossfadeAlpha = 1;
                    animation.curAnim.curFrame = targetFrame;
                }
            }
        }
    }

	override function draw() {
		var framesCollection = animation.curAnim.frames;
	
		if (framesCollection != null && crossfadeAlpha < 1) {
			if (previousFrame >= 0 && previousFrame < framesCollection.length) {
				animation.curAnim.curFrame = previousFrame;
				alpha = 1 - crossfadeAlpha;
				super.draw();
			}
	
			if (targetFrame >= 0 && targetFrame < framesCollection.length) {
				animation.curAnim.curFrame = targetFrame;
				alpha = crossfadeAlpha;
				super.draw();
			}
	
			alpha = 1;
		} else {
			super.draw();
		}
	}
}