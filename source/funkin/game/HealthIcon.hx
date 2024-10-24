package funkin.game;


class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	/**
	 * The currently showing icon
	 */
	public var curCharacter:String = null;

	/**
	 * If the character is for the player
	 */
	public var isPlayer:Bool;

	/**
	 * Health steps in this format:
	 * Min Percentage => Frame Index
	 */
	public var healthSteps:Map<Int, Int> = null;

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
				20 => 0, // normal icon
			];

			if (frames.frames.length >= 3)
				healthSteps[80] = 2; // winning icon
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);

		if (animation.curAnim != null) {
			var i:Int = -1;
			var oldKey:Int = -1;
			for (k=>icon in healthSteps) if (k > oldKey && k <= health * 100) {
				oldKey = k;
				i = icon;
			}

			if (i >= 0) animation.curAnim.curFrame = i;
		}
	}
}
