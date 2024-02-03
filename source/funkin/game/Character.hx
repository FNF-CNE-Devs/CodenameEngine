package funkin.game;

import haxe.xml.Printer;
import flixel.util.FlxColor;
import funkin.backend.FunkinSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import funkin.backend.system.interfaces.IBeatReceiver;
import funkin.backend.system.interfaces.IOffsetCompatible;
import funkin.backend.utils.XMLUtil;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import haxe.xml.Access;
import haxe.Exception;
import haxe.io.Path;
import funkin.backend.system.Conductor;
import openfl.geom.ColorTransform;
import funkin.backend.scripting.DummyScript;
import funkin.backend.scripting.Script;
import funkin.backend.scripting.events.*;
import funkin.backend.scripting.events.PlayAnimEvent.PlayAnimContext;

using StringTools;

@:allow(funkin.desktop.editors.CharacterEditor)
@:allow(funkin.game.StrumLine)
@:allow(funkin.game.PlayState)
class Character extends FunkinSprite implements IBeatReceiver implements IOffsetCompatible
{
	public var extra:Map<String, String> = [];

	private var __stunnedTime:Float = 0;
	private var __lockAnimThisFrame:Bool = false;

	public var stunned(default, set):Bool = false;

	private function set_stunned(b:Bool)
	{
		__stunnedTime = 0;
		return stunned = b;
	}

	public var isPlayer:Bool = false;
	public var isGF:Bool = false;
	public var curCharacter:String = 'bf';
	public var sprite:String = 'bf';

	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var holdTime:Float = 4;

	public var playerOffsets:Bool = false;

	public var icon:String = null;
	public var iconColor:Null<FlxColor> = null;
	public var gameOverCharacter:String = "bf-dead";

	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);
	public var globalOffset:FlxPoint = new FlxPoint(0, 0);

	public var script:Script;
	public var xml:Access;

	public var shadowFrame:CharacterShadowFrame;
	public var idleSuffix:String = "";

	public inline function getCameraPosition()
	{
		var midpoint = getMidpoint();
		var event = EventManager.get(PointEvent).recycle(
			midpoint.x + (isPlayer ? -100 : 150) + globalOffset.x + cameraOffset.x,
			midpoint.y - 100 + globalOffset.y + cameraOffset.y);
		script.call("onGetCamPos", [event]);
		midpoint.put();
		// this event cannot be cancelled
		return new FlxPoint(event.x, event.y);
	}

	public function playSingAnim(direction:Int, suffix:String = "", Context:PlayAnimContext = SING, Force:Bool = true, Reversed:Bool = false, Frame:Int = 0)
	{
		var anims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

		var event = EventManager.get(DirectionAnimEvent).recycle('${anims[direction]}$suffix', direction, suffix, Context, Reversed, Frame, Force);
		script.call("onPlaySingAnim", [event]);
		if (!event.cancelled)
			playAnim(event.animName, event.force, Context, event.reversed, event.frame);
	}

	public function new(x:Float, y:Float, ?character:String = "bf", isPlayer:Bool = false, switchAnims:Bool = true)
	{
		super(x, y);

		animOffsets = new Map<String, FlxPoint>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		while (true)
		{
			switch (curCharacter)
			{
				// case 'your-char': // To hardcode characters
				default:
					// load xml
					var xmlPath = Paths.xml('characters/$curCharacter');
					if (!Assets.exists(xmlPath))
					{
						curCharacter = "bf";
						continue;
					}

					var plainXML = Assets.getText(xmlPath);
					try
					{
						var charXML = Xml.parse(plainXML).firstElement();
						if (charXML == null) throw new Exception("Missing \"character\" node in XML.");
						xml = new Access(charXML);
					} catch (e) {
						Logs.trace('Error while loading character ${curCharacter}: ${e}', ERROR);
						curCharacter = "bf";
						continue;
					}
					// Loads the script
					script = Script.create(Paths.script(Path.withoutExtension(xmlPath), null, true));
					script.setParent(this);
					script.load();
					applyXML(xml);
					script.call("create");
			}
			break;
		}
		if (script == null)
			script = new DummyScript(curCharacter);

		/**
			NON CONVERTED CHARACTERS - DO NOT REMOVE
		**/
		// 	case 'bf-pixel-dead':
		// 		frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD');
		// 		animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
		// 		animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
		// 		animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
		// 		animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
		// 		animation.play('firstDeath');

		// 		addOffset('firstDeath');
		// 		addOffset('deathLoop', -37);
		// 		addOffset('deathConfirm', -37);
		// 		playAnim('firstDeath');
		// 		// pixel bullshit
		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();
		// 		antialiasing = false;
		// 		flipX = true;

		script.call("postCreate");
	}

	public function fixChar(switchAnims:Bool = false)
	{
		isDanceLeftDanceRight = (hasAnimation("danceLeft") && hasAnimation("danceRight"));

		// alternative to xor operator
		// for people who dont believe it, heres the truth table
		// [   a   ][   b   ][ a!= b ]
		// [ true  ][ true  ][ false ]
		// [ true  ][ false ][ true  ]
		// [ false ][ true  ][ true  ]
		// [ true  ][ true  ][ false ]
		// bros provided evedince :skull:
		if (isPlayer != playerOffsets && switchAnims)
		{
			// character is flipped
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHT'), animation.getByName('singLEFT'));
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHTmiss'), animation.getByName('singLEFTmiss'));

			switchOffset('singLEFT', 'singRIGHT');
			switchOffset('singLEFTmiss', 'singRIGHTmiss');
		}
		frameOffset.set(getAnimOffset(getAnimName()).x, getAnimOffset(getAnimName()).y);
		if (isPlayer)
			flipX = !flipX;
		__baseFlipped = flipX;
	}

	var __baseFlipped:Bool = false;
	var isDanceLeftDanceRight:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		script.call("update", [elapsed]);
		if (stunned)
		{
			__stunnedTime += elapsed;
			if (__stunnedTime > 5 / 60)
				stunned = false;
		}
		__lockAnimThisFrame = false;
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			var event = EventManager.get(DanceEvent).recycle(danced);
			script.call("onDance", [event]);
			if (event.cancelled)
				return;

			switch (curCharacter)
			{
				// hardcode custom dance animations here
				default:
					if (isDanceLeftDanceRight)
					{
						playAnim(((danced = !danced) ? 'danceLeft' : 'danceRight') + idleSuffix, DANCE);
					}
					else
						playAnim('idle' + idleSuffix, DANCE);
			}
		}
	}

	public function tryDance()
	{
		switch (lastAnimContext) {
			case SING | MISS:
				if (lastHit + (Conductor.stepCrochet * holdTime) < Conductor.songPosition)
					dance();
			case DANCE:
				dance();
			case LOCK:
				if (getAnimName() == null)
					dance();
			default:
				if (getAnimName() == null || isAnimFinished())
					dance();
		}
	}

	/**
	 * Whenever the character should dance on beat or not. Set to false for `gf`, since the dance animation is automatically handled by PlayState.
	 */
	public var danceOnBeat:Bool = true;

	/**
	 * Interval at which the character will dance (higher number = slower dance)
	 */
	public var danceInterval:Int = 1;

	public override function beatHit(curBeat:Int) {
		script.call("beatHit", [curBeat]);
		if (danceInterval < 1)
			danceInterval = 1;

		if (danceOnBeat && curBeat % danceInterval == 0 && !__lockAnimThisFrame)
		{
			tryDance();
		}
	}

	public override function stepHit(curStep:Int) {
		script.call("stepHit", [curStep]);
		// nothing
	}

	var __reverseDrawProcedure:Bool = false;

	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__reverseDrawProcedure)
		{
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}

	public function isFlippedOffsets() {
		return (isPlayer != playerOffsets) != (flipX != __baseFlipped);
	}

	var __drawingShadowFrame = false;
	var __oldColorTransform = new ColorTransform();

	public override function draw() {
		if (!__drawingShadowFrame && shadowFrame != null) {
			__drawingShadowFrame = true;

			var oldFrame = _frame;
			var oldPos = FlxPoint.get(frameOffset.x, frameOffset.y);

			__oldColorTransform.copyColorTransform(colorTransform);

			colorTransform.alphaMultiplier = 1;
			colorTransform.alphaOffset = 0;
			colorTransform.blueMultiplier = 0;
			colorTransform.blueOffset = 25;
			colorTransform.greenMultiplier = 0;
			colorTransform.greenOffset = 25;
			colorTransform.redMultiplier = 0;
			colorTransform.redOffset = 25;

			_frame = shadowFrame.frame;
			var o = getAnimOffset(shadowFrame.anim);
			frameOffset.set(o.x, o.y);
			super.draw();

			_frame = oldFrame;
			frameOffset.set(oldPos.x, oldPos.y);

			colorTransform.copyColorTransform(__oldColorTransform);

			oldPos.put();

			__drawingShadowFrame = false;
		}

		if (isFlippedOffsets())
		{
			__reverseDrawProcedure = true;

			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;

			__reverseDrawProcedure = false;
		}
		else
			super.draw();
	}

	public override function playAnim(AnimName:String, Force:Bool = false, Context:PlayAnimContext = NONE, Reversed:Bool = false, Frame:Int = 0):Void
	{
		var event = EventManager.get(PlayAnimEvent).recycle(AnimName, Force, Reversed, Frame, Context);
		script.call("onPlayAnim", [event]);
		if (event.cancelled)
			return;

		super.playAnim(event.animName, event.force, event.context, event.reverse, event.startingFrame);

		offset.set(globalOffset.x * (isPlayer != playerOffsets ? 1 : -1), -globalOffset.y);
		if (event.context == SING || event.context == MISS)
			lastHit = Conductor.songPosition;
	}

	public override function destroy()
	{
		super.destroy();

		cameraOffset.put();
		globalOffset.put();
	}

	// FlxTrail Stuff for fixing position

	var __reverseTrailProcedure:Bool = false;

	/**
	 * When using trails on characters you should do `trail.beforeCache = char.beforeTrailCache;`
	 **/
	dynamic function beforeTrailCache() {
		if (isFlippedOffsets())
		{
			flipX = !flipX;
			scale.x *= -1;
			__reverseTrailProcedure = true;
		}
	}

	/**
	 * When using trails on characters you should do `trail.afterCache = char.afterTrailCache;`
	 **/
	dynamic function afterTrailCache() {
		if (__reverseTrailProcedure)
		{
			flipX = !flipX;
			scale.x *= -1;
			__reverseTrailProcedure = false;
		}
	}

	// Character editor and loading

	public function applyXML(xml:Access) {
		this.xml = xml; // modders wassup
		sprite = curCharacter;

		if (xml.x.exists("isPlayer")) playerOffsets = (xml.x.get("isPlayer") == "true");
		if (xml.x.exists("isGF")) isGF = (xml.x.get("isGF") == "true");
		if (xml.x.exists("x")) globalOffset.x = Std.parseFloat(xml.x.get("x"));
		if (xml.x.exists("y")) globalOffset.y = Std.parseFloat(xml.x.get("y"));
		if (xml.x.exists("gameOverChar")) gameOverCharacter = xml.x.get("gameOverChar");
		if (xml.x.exists("camx")) cameraOffset.x = Std.parseFloat(xml.x.get("camx"));
		if (xml.x.exists("camy")) cameraOffset.y = Std.parseFloat(xml.x.get("camy"));
		if (xml.x.exists("holdTime")) holdTime = CoolUtil.getDefault(Std.parseFloat(xml.x.get("holdTime")), 4);
		if (xml.x.exists("flipX")) flipX = (xml.x.get("flipX") == "true");
		if (xml.x.exists("icon")) icon = xml.x.get("icon");
		if (xml.x.exists("color")) iconColor = FlxColor.fromString(xml.x.get("color"));
		if (xml.x.exists("scale")) {
			var scale = Std.parseFloat(xml.x.get("scale")).getDefault(1);
			this.scale.set(scale, scale);
			updateHitbox();
		}
		if (xml.x.exists("antialiasing")) antialiasing = (xml.x.get("antialiasing") == "true");
		if (xml.x.exists("sprite")) sprite = xml.x.get("sprite");

		var tempList = ["isPlayer", "isGF", "x", "y", "gameOverChar", "camx", "camy", "holdTime", "flipX", "icon", "color", "scale", "antialiasing", "sprite"];
		var atts = [for (i in xml.x.attributes()) i];
		for (i in atts)
			if (!tempList.contains(i)) {
				extra[i] = xml.x.get(i);
			}

		loadSprite(Paths.image('characters/$sprite'));

		animation.destroyAnimations();
		animDatas.clear();
		for (anim in xml.nodes.anim)
		{
			XMLUtil.addXMLAnimation(this, anim);
		}

		fixChar(true);
		dance();
	}

	public function buildXML(?animsOrder:Array<String>):Xml {
		var xml = Xml.createElement("character");
		xml.set("isPlayer", playerOffsets == true ? "true" : "false");
		xml.set("isGF", isGF == true ? "true" : "false");
		xml.set("x", Std.string(globalOffset.x));
		xml.set("y", Std.string(globalOffset.y));
		xml.set("gameOverChar", gameOverCharacter);
		xml.set("camx", Std.string(cameraOffset.x));
		xml.set("camy", Std.string(cameraOffset.y));
		xml.set("holdTime", Std.string(holdTime));
		xml.set("flipX", Std.string(flipX));
		xml.set("icon", getIcon());
		if (iconColor != null)
			xml.set("color", iconColor.toHexString(false).replace("0x", "#"));
		xml.set("scale", Std.string(scale.x));
		xml.set("antialiasing", antialiasing == true ? "true" : "false");
		xml.set("sprite", sprite);

		for (prop=>val in extra) {
			xml.set(prop, Std.string(val));
		}

		var anims:Array<AnimData> = [];
		if (animsOrder != null) {
			for (name in animsOrder)
				if (animDatas.exists(name)) anims.push(animDatas.get(name));
		} else
			anims = [for (anim in animDatas) anim];

		for (anim in anims)
		{
			var animXml:Xml = Xml.createElement('anim');
			animXml.set("name", anim.name);
			animXml.set("anim", anim.anim);
			animXml.set("loop", Std.string(anim.loop));
			animXml.set("fps", Std.string(anim.fps));
			var offset:FlxPoint = getAnimOffset(anim.name);
			animXml.set("x", Std.string(offset.x));
			animXml.set("y", Std.string(offset.y));
			if (anim.indices.length > 0)
				animXml.set("indices", anim.indices.join(","));
			xml.addChild(animXml);
		}

		this.xml = new Access(xml);
		return xml;
	}

	public inline function getIcon()
		return (icon != null) ? icon : curCharacter;

	public function getAnimOrder() {
		return [for(a in xml.nodes.anim) if(a.has.name) a.att.name];
	}

	// Statics

	public static function getIconFromCharName(?curCharacter:String) {
		if(curCharacter == null) return "face";
		var icon = curCharacter;
		while(true) {
			switch (curCharacter) {
				// case 'your-char': // To hardcode characters icons
				default:
					// load xml
					var xmlPath = Paths.xml('characters/$curCharacter');
					if (!Assets.exists(xmlPath)) {
						curCharacter = "bf";
						continue;
					}

					var xml = null;
					var plainXML = Assets.getText(xmlPath);
					try {
						var charXML = Xml.parse(plainXML).firstElement();
						if (charXML == null) throw new Exception("Missing \"character\" node in XML.");
						xml = new Access(charXML);
					} catch(e) {
						Logs.trace('Error while loading character ${curCharacter}: ${e}', ERROR);
						curCharacter = "bf";
						continue;
					}

					if (xml.x.exists("icon")) icon = xml.x.get("icon");
				}
			break;
		}
		return icon;
	}

	public static function getList(?mods:Bool = false):Array<String> {
		return [
			for (path in Paths.getFolderContent('data/characters/', true, mods ? MODS : BOTH))
				if (Path.extension(path) == "xml") Path.withoutDirectory(Path.withoutExtension(path))
		];
	}
}

typedef CharacterShadowFrame =
{
	var anim:String;
	var frame:FlxFrame;
}
