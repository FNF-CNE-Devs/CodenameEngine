package funkin.game;

import haxe.xml.Access;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.util.typeLimit.OneOfTwo;

class HealthIcon extends FunkinSprite
{
	/**
	 * Attaches the icon to a sprite, following it's position
	 */
	public var sprTracker:FlxSprite;
	/**
	 * Where to place the icon in relation to the sprite
	 * LEFT: Left of the sprite
	 * CENTER: Center of the sprite
	 * RIGHT: Right of the sprite
	 */
	public var sprTrackerAlignment:TrackerAlignment = RIGHT;
	/**
	 * Offset of the icon in relation to the sprite
	 * By default it is set to (10, -30) and is intended to be used with Alphabet
	 */
	public var sprTrackerOffset:FlxPoint = new FlxPoint(10, -30);

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
	 * Min Percentage => Frame Index / Animation Name
	 */
	public var healthSteps:Map<Int, OneOfTwo<String, Int>> = null;

	/**
	 * Current animation state
	 */
	public var curAnimState:OneOfTwo<String, Int> = -1;

	/**
	 * The Default Scale For The Icon
	 * This is what scale the icon should return to when its bump animation is finished
	 */
	public var defaultScale:Float = 1;

	/**
	 * Whenever or not the icon is animated or not
	 */
	public var animated:Bool = false;

	/**
	 * XML Animated Icon data
	 * Null if the icon is not animated or its invalid
	 */
	public var xmlData:Xml;

	/**
	 * Extra offsets to add when updating the hitbox
	 */
	public var extraOffsets:FlxPoint = FlxPoint.get();

	/**
	 * Helper for HScript who can't make maps
	 * THIS IS DEPRECATED AND WILL BE REMOVED IN THE FUTURE
	 * Please set the healthSteps directly in the script instead, hscript does support maps
	 *
	 * @param steps Something like this: `[[0, 1], [20, 0]]` or `[[0, "losing"], [20, "neutral"]]` for animated icons
	 */
	@:dox(hide) @:noCompletion
	public function setHealthSteps(steps:Array<Array<OneOfTwo<String, Int>>>):Void { // helper for hscript that can't do maps
		if (steps == null) return;
		healthSteps = [];
		for(s in steps)
			if (s.length > 1)
				healthSteps[s[0]] = s[1];
		var am = 0;
		for(k=>e in healthSteps) am++;

		if (am <= 0) healthSteps = [
			0 => this.animated ? "losing" : 1, // losing icon
			20 => this.animated ? "neutral" : 0, // normal icon
		];
	}

	public function new(?char:String, isPlayer:Bool = false)
	{
		super();
		health = 0.5;
		this.isPlayer = isPlayer;
		setIcon(char);

		scrollFactor.set();
	}

	/**
	 * Called every beat, and causes the icon to become bigger
	**/
	public dynamic function bump():Void {
		var iconScale = 1.2;
		scale.set(defaultScale * iconScale, defaultScale * iconScale);
		updateHitbox();
	}

	/**
	 * Called every frame and causes the icon to become smaller
	**/
	public dynamic function updateBump():Void {
		var iconLerp = 0.33;
		scale.set(CoolUtil.fpsLerp(scale.x, defaultScale, iconLerp), CoolUtil.fpsLerp(scale.y, defaultScale, iconLerp));
		updateHitbox();
	}

	/**
	 * Sets the icon to the specified character
	 * @param char Character to set the icon to
	 * @param allowAnimated Whenever the icon can be animated
	**/
	public function setIcon(char:String, allowAnimated:Bool = true):Void {
		if(curCharacter == char) return;

		var oldIconPath = 'icons/$char';
		var newIconPath = 'icons/$char/icon';

		if (!Assets.exists(Paths.image(oldIconPath)) && !Assets.exists(Paths.image(newIconPath))) {
			char = 'face';
			oldIconPath = 'icons/$char';
			newIconPath = 'icons/$char/icon';
		}
		curCharacter = char;

		var iconPath = Assets.exists(Paths.image(oldIconPath)) ? oldIconPath : newIconPath;
		var iconXmlPath = Paths.getPath('images/icons/$char/data.xml');
		var iconFoundData = Assets.exists(iconXmlPath);

		try {
			xmlData = iconFoundData ? Xml.parse(Assets.getText(iconXmlPath)) : null;
		} catch(e) {
			Logs.trace('Error while parsing icon data for $char: ${e.message}', ERROR);
			xmlData = null;
		}
		var xmlValid = xmlData != null && (xmlData = xmlData.firstElement()) != null;

		this.animated = allowAnimated && iconFoundData && xmlValid && Paths.framesExists(Paths.image(newIconPath), true, true);

		var iconAmt:Int = 0;
		var iconSize:Int = 0;
		var iconIsPlayer = xmlValid ? xmlData.get("facing").getDefault("right").toLowerCase() == "left" : false;

		animateAtlas = null; // reset
		if (this.animated)
			loadSprite(Paths.image(iconPath));
		else {
			var iconAsset:FlxGraphic = FlxG.bitmap.add(Paths.image(iconPath));
			var assetW:Float = iconAsset.width;
			var assetH:Float = iconAsset.height;

			iconAmt = Math.floor(assetW / assetH);
			iconSize = Math.floor(assetW / iconAmt);

			loadGraphic(iconAsset, true, Std.int(Math.min(iconSize, assetW)), Std.int(Math.min(iconSize, assetH)));

			setGraphicSize(150);
			updateHitbox();

			animation.add(char, [for(i in 0...iconAmt) i], 0, false, isPlayer != iconIsPlayer);
			animation.play(char);
		}

		if(!animation.onFinishEnd.has(animFinishCallback))
			animation.onFinishEnd.add(animFinishCallback);
		if(animateAtlas != null && !animateAtlas.anim.onFinishEnd.has(animFinishCallback))
			animateAtlas.anim.onFinishEnd.add(animFinishCallback);

		var parsedSteps:Map<Int, String> = [];

		antialiasing = true;
		if(xmlValid) {
			if(xmlData.exists("antialiasing"))
				antialiasing = xmlData.get("antialiasing").toLowerCase() == "true";
			if (xmlData.exists("offsetX"))
				extraOffsets.x = Std.parseFloat(xmlData.get("offsetX")).getDefault(0);
			if (xmlData.exists("offsetY"))
				extraOffsets.y = Std.parseFloat(xmlData.get("offsetY")).getDefault(0);

			for(node in xmlData.elements())
				switch(node.nodeName) {
					case "transition":
						if(this.animated == false) {
							Logs.trace('Icon ${char} data <transition> is not allowed when not animated', WARNING);
							continue;
						}
						if(!node.exists("anim")) {
							Logs.trace('Icon ${char} data <transition> is missing anim', WARNING);
							continue;
						}
						if(!node.exists("to")) {
							Logs.trace('Icon ${char} data <transition> is missing to', WARNING);
							continue;
						}
						if(!node.exists("from")) {
							Logs.trace('Icon ${char} data <transition> is missing from', WARNING);
							continue;
						}

						var animName = 'from-${node.get("from")}-to-${node.get("to")}';
						if (node.exists("offsetX") || node.exists("offsetY"))
							addOffset(animName, Std.parseFloat(node.get("offsetX")).getDefault(0), Std.parseFloat(node.get("offsetY")).getDefault(0));
						addAnim(animName, node.get("anim"), Std.parseInt(node.get("fps")).getDefault(24), false); // don't allow looping for transitions
						if(animateAtlas == null && animation.exists(animName))
							animation.getByName(animName).flipX = isPlayer != iconIsPlayer;
					case "anim":
						if(this.animated == false) {
							Logs.trace('Icon ${char} data <anim> is not allowed when not animated', WARNING);
							continue;
						}
						if(!node.exists("name")) {
							Logs.trace('Icon ${char} data <anim> is missing name', WARNING);
							continue;
						}
						if(!node.exists("anim")) {
							Logs.trace('Icon ${char} data <anim> is missing anim', WARNING);
							continue;
						}

						var animName = node.get("name");

						if (node.exists("offsetX") || node.exists("offsetY"))
							addOffset(animName, Std.parseFloat(node.get("offsetX")).getDefault(0), Std.parseFloat(node.get("offsetY")).getDefault(0));
						addAnim(animName, node.get("anim"), Std.parseInt(node.get("fps")).getDefault(24), node.get("looped").getDefault("true").toLowerCase() == "true");
						if(animateAtlas == null && animation.exists(animName))
							animation.getByName(animName).flipX = isPlayer != iconIsPlayer;
					case "step":
						if(!node.exists("percent")) {
							Logs.trace('Icon ${char} data <step> is missing percent', WARNING);
							continue;
						}
						if(!node.exists("name")) {
							Logs.trace('Icon ${char} data <step> is missing name', WARNING);
							continue;
						}

						parsedSteps.set(Std.parseInt(node.get("percent")).getDefault(0), node.get("name"));
				}
		}

		if(Lambda.count(parsedSteps) > 0) {
			healthSteps = parsedSteps;
		} else {
			var hasLosing = this.animated ? hasAnim("losing") : iconAmt >= 2;
			var hasWinning = this.animated ? hasAnim("winning") : iconAmt >= 3;

			if(hasLosing) {
				healthSteps = [
					0  => this.animated ? "losing" : 1, // losing icon
					20 => this.animated ? "neutral" : 0, // normal icon
				];
			} else {
				healthSteps = [
					0 => this.animated ? "neutral" : 0, // normal icon
				];
			}
			if (hasWinning)
				healthSteps.set(80, this.animated ? "winning" : 2); // winning icon
		}
		var data = getIconAnim(health);
		if (data.isValid) {
			if(this.animated)
				playAnim(data.animState);
			else
				animation.curAnim.curFrame = data.animState;
			curAnimState = data.animState;
		}

		if(animateAtlas != null) {
			@:bypassAccessor
			frameWidth = 150;
			@:bypassAccessor
			frameHeight = 150;
			extraOffsets.x -= frameWidth / 2;
			extraOffsets.y -= frameHeight / 2;
			updateHitbox();
		} else {
			setGraphicSize(150);
			updateHitbox();
		}

		if(!xmlValid || !xmlData.exists("scale"))
			defaultScale = scale.x;
		else
			defaultScale = Std.parseFloat(xmlData.get("scale")).getDefault(scale.x);
	}

	var normalizedNames = ["neutral", "losing", "winning"];
	private function normalizeAnim(anim:OneOfTwo<String, Int>):OneOfTwo<String, Int> {
		if(this.animated) {
			if(anim is Int) {
				var _:Int = cast anim;
				if(_ >= 0 && _ < normalizedNames.length)
					anim = normalizedNames[anim];
			}
		} else {
			if(anim is String) {
				var _ = normalizedNames.indexOf(cast anim);
				if(_ >= 0)
					anim = _;
			}
		}
		return anim;
	}

	/**
	 * Gets the animation data for a specific health percentage
	 * @param health Health percentage
	 * @return Animation data (-1 if invalid)
	 */
	public dynamic function getIconAnim(health:Float):IconAnimData {
		var i:OneOfTwo<String, Int> = -1;
		var oldKey:Int = -1;
		var isValid = false;
		for (k=>icon in healthSteps) if (k > oldKey && k <= health * 100) {
			oldKey = k;
			i = icon;
			isValid = true;
		}

		i = normalizeAnim(i);

		return new IconAnimData(i, isValid);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + (switch sprTrackerAlignment {
				case LEFT: -width;
				case CENTER: (sprTracker.width - width) / 2;
				case RIGHT: sprTracker.width;
			}) + sprTrackerOffset.x, sprTracker.y + sprTrackerOffset.y);
		}

		if (animation.curAnim != null || (this.animated && animateAtlas != null)) {
			var data = getIconAnim(health);
			var localAnimState = data.animState;

			if (data.isValid && curAnimState != localAnimState) {
				if (this.animated) {
					var transAnim = 'from-$curAnimState-to-$localAnimState';
					playAnim(hasAnim(transAnim) ? transAnim : localAnimState);
				} else {
					if(animation.curAnim != null)
						animation.curAnim.curFrame = localAnimState;
				}

				curAnimState = localAnimState;
			}
		}
	}

	function animFinishCallback(anim:String):Void {
		if (this.animated)
			if (anim.startsWith("from-"))
				playAnim(anim.substr(anim.lastIndexOf('-') + 1));
	}

	override function updateHitbox():Void {
		super.updateHitbox();
		offset += extraOffsets;
	}
}

@:dox(hide)
class IconAnimData {
	public var animState:OneOfTwo<String, Int>;
	public var isValid:Bool;

	public function new(animState:OneOfTwo<String, Int>, isValid:Bool) {
		this.animState = animState;
		this.isValid = isValid;
	}

	public function toString():String {
		return '$animState (Valid: $isValid)';
	}
}

/**
 * Used for `funkin.game.HealthIcon.sprTrackerAlignment`.
 * This determines the position of the icon in relation to the sprite tracker.
**/
enum abstract TrackerAlignment(Int) {
	/**
	 * Left of the sprite tracker
	 *
	 * Mathematically: `tracker.x - icon.width`
	 */
	var LEFT = 0;
	/**
	 * Center of the sprite tracker
	 *
	 * Mathematically: `tracker.x + (tracker.width - icon.width) / 2`
	 */
	var CENTER = 1;
	/**
	 * Right of the sprite tracker
	 *
	 * Mathematically: `tracker.x + tracker.width`
	 */
	var RIGHT = 2;
}