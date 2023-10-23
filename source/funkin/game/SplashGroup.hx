package funkin.game;

import haxe.xml.Access;

class SplashGroup extends FlxTypedGroup<FunkinSprite> {
	/**
	 * Whenever the splash group has successfully loaded or not.
	 */
	public var valid:Bool = true;

	/**
	 * XML data for the note splashes.
	 */
	public var xml:Access;

	/**
	 * Animation names sorted by strum IDs.
	 * Use `getSplashAnim` to get one.
	 */
	public var animationNames:Array<Array<String>> = [];

	/**
	 * Creates a new Splash group
	 * @param path Path to the splash data (xml)
	 */
	public function new(path) {
		super();

		try {
			xml = new Access(Xml.parse(Assets.getText(path)).firstElement());

			if (!xml.has.sprite) throw "The <splash> element requires a sprite attribute.";

			var splashSprite = new FunkinSprite();
			splashSprite.antialiasing = true;
			splashSprite.active = splashSprite.visible = false;
			splashSprite.loadSprite(Paths.image(xml.att.sprite));

			/**
			 * ANIMATIONS
			 */
			for(strum in xml.nodes.strum) {
				var id:Null<Int> = Std.parseInt(strum.att.id);
				if (id != null) {
					animationNames[id] = [];
					for(anim in strum.nodes.anim) {
						if (!anim.has.name) continue;
						XMLUtil.addXMLAnimation(splashSprite, anim, false);
						animationNames[id].push(anim.att.name);
					}
				}
			}
			if (animationNames.length <= 0)
				animationNames.push([]);
			for(anim in xml.nodes.anim) {
				if (!anim.has.name) continue;
				XMLUtil.addXMLAnimation(splashSprite, anim, false);
				for(a in animationNames) {
					if (a == null) continue;
					a.push(anim.att.name);
				}
			}
			/**
			 * END OF ANIMATIONS
			 */
			splashSprite.animation.finishCallback = function(name) {
				splashSprite.active = splashSprite.visible = false;
			};

			if (xml.has.scale) splashSprite.scale.scale(Std.parseFloat(xml.att.scale).getDefault(1));
			if (xml.has.alpha) splashSprite.alpha = Std.parseFloat(xml.att.alpha).getDefault(1);
			if (xml.has.antialiasing) splashSprite.antialiasing = xml.att.antialiasing == "true";

			add(splashSprite);

			for (i in 0...7) {
				// make 7 additional splashes
				var spr = FunkinSprite.copyFrom(splashSprite);
				spr.animation.finishCallback = function(name) {
					spr.active = spr.visible = false;
				};
				add(spr);
			}

			// immediatly draw once and put image in GPU to prevent freezes
			// TODO: change to graphics cache
			splashSprite.drawComplex(FlxG.camera);
		} catch(e) {
			Logs.trace('Couldn\'t parse splash data for "${path}": ${e.toString()}', ERROR);
			valid = false;
		}

		maxSize = 8;
	}

	public function getSplashAnim(id:Int):String {
		if (animationNames.length <= 0) return null;
		id %= animationNames.length;
		if (animationNames[id] == null) return null;
		if (animationNames[id].length <= 0) return null;
		return animationNames[id][FlxG.random.int(0, animationNames[id].length-1)];
	}

	var __splash:FunkinSprite;
	public function showOnStrum(strum:Strum) {
		if (!valid) return null;
		__splash = recycle();

		__splash.cameras = strum.lastDrawCameras;
		__splash.setPosition(strum.x + ((strum.width - __splash.width) / 2), strum.y + ((strum.height - __splash.height) / 2));
		__splash.active = __splash.visible = true;
		__splash.playAnim(getSplashAnim(strum.ID), true);
		__splash.scrollFactor.set(strum.scrollFactor.x, strum.scrollFactor.y);

		return __splash;
	}
}