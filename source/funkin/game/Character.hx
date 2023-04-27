package funkin.game;

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
	private var __stunnedTime:Float = 0;
	private var __lockAnimThisFrame:Bool = false;
	public var stunned(default, set):Bool = false;

	private function set_stunned(b:Bool) {
		__stunnedTime = 0;
		return stunned = b;
	}

	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var isGF:Bool = false;
	public var curCharacter:String = 'bf';

	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var holdTime:Float = 4;

	public var playerOffsets:Bool = false;

	public var icon:String = null;
	public var gameOverCharacter:String = "bf-dead";

	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);
	public var globalOffset:FlxPoint = new FlxPoint(0, 0);

	public var script:Script;
	public var xml:Access;

	public var shadowFrame:CharacterShadowFrame;


	public inline function getCameraPosition() {
		var midpoint = getMidpoint();
		var event = EventManager.get(PointEvent).recycle(
			midpoint.x + (isPlayer ? -100 : 150) + globalOffset.x + cameraOffset.x,
			midpoint.y - 100 + globalOffset.y + cameraOffset.y);
		script.call("onGetCamPos", [event]);
		midpoint.put();
		// this event cannot be cancelled
		return new FlxPoint(event.x, event.y);
	}

	public function playSingAnim(direction:Int, suffix:String = "", Context:PlayAnimContext = SING, Force:Bool = true, Reversed:Bool = false, Frame:Int = 0) {
		var anims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

		var event = EventManager.get(DirectionAnimEvent).recycle('${anims[direction]}$suffix', direction, suffix, Context, Reversed, Frame, Force);
		script.call("onPlaySingAnim", [event]);
		if (!event.cancelled) playAnim(event.animName, event.force, Context, event.reversed, event.frame);
	}

	public function new(x:Float, y:Float, ?character:String = "bf", isPlayer:Bool = false, switchAnims:Bool = true)
	{
		super(x, y);

		animOffsets = new Map<String, FlxPoint>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;

		while(true) {
			switch (curCharacter)
			{
				// case 'your-char': // To hardcode characters
				default:
					// load xml
					var xmlPath = Paths.xml('characters/$curCharacter');
					if (!Assets.exists(xmlPath)) {
						curCharacter = "bf";
						continue;
					}

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
					var sprite:String = curCharacter;

					if (xml.has.isPlayer) playerOffsets = (xml.att.isPlayer == "true");
					if (xml.has.isGF) isGF = (xml.att.isGF == "true");
					if (xml.has.x) globalOffset.x = Std.parseFloat(xml.att.x);
					if (xml.has.y) globalOffset.y = Std.parseFloat(xml.att.y);
					if (xml.has.gameOverChar) gameOverCharacter = xml.att.gameOverChar;
					if (xml.has.camx) cameraOffset.x = Std.parseFloat(xml.att.camx);
					if (xml.has.camy) cameraOffset.y = Std.parseFloat(xml.att.camy);
					if (xml.has.holdTime) holdTime = CoolUtil.getDefault(Std.parseFloat(xml.att.holdTime), 4);
					if (xml.has.flipX) flipX = (xml.att.flipX == "true");
					if (xml.has.icon) icon = xml.att.icon;
					if (xml.has.scale) {
						var scale = Std.parseFloat(xml.att.scale).getDefault(1);
						this.scale.set(scale, scale);
						updateHitbox();
					}
					if (xml.has.antialiasing) antialiasing = (xml.att.antialiasing == "true");
					if (xml.has.sprite) sprite = xml.att.sprite;

					loadSprite(Paths.image('characters/$sprite'));
					for(anim in xml.nodes.anim) {
						XMLUtil.addXMLAnimation(this, anim);
					}

					// Loads the script and calls it's "create" function
					script = Script.create(Paths.script(Path.withoutExtension(xmlPath), null, true));
					script.setParent(this);
					script.load();
					script.call("create");
			}
			break;
		}
		if (script == null) script = new DummyScript(curCharacter);

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


		isDanceLeftDanceRight = (hasAnimation("danceLeft") && hasAnimation("danceRight"));
		
		// alternative to xor operator
		// for people who dont believe it, heres the truth table
		// [   a   ][   b   ][ a!= b ]
		// [ true  ][ true  ][ false ]
		// [ true  ][ false ][ true  ]
		// [ false ][ true  ][ true  ]
		// [ true  ][ true  ][ false ]
		if (isPlayer != playerOffsets && switchAnims)
		{
			// character is flipped
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHT'), animation.getByName('singLEFT'));
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHTmiss'), animation.getByName('singLEFTmiss'));
			
			switchOffset('singLEFT', 'singRIGHT');
			switchOffset('singLEFTmiss', 'singRIGHTmiss');
		}
		if (isPlayer) flipX = !flipX;
		__baseFlipped = flipX;
		dance();
		script.call("postCreate");
	}

	var __baseFlipped:Bool = false;
	var isDanceLeftDanceRight:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		script.call("update", [elapsed]);
		if (stunned) {
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
			if (event.cancelled) return;

			switch (curCharacter)
			{
				// hardcode custom dance animations here
				default:
					if (isDanceLeftDanceRight) {
						playAnim((danced = !danced) ? 'danceLeft' : 'danceRight', DANCE);
					} else
						playAnim('idle', DANCE);
			}
		}
	}

	public function tryDance() {
		switch(lastAnimContext) {
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

		if (danceOnBeat && curBeat % danceInterval == 0 && !__lockAnimThisFrame) {
			tryDance();
		}
	}
	
	public override function stepHit(curStep:Int) {
		script.call("stepHit", [curStep]);
		// nothing
	}

	var __reverseDrawProcedure:Bool = false;
	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__reverseDrawProcedure) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
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

		if ((isPlayer != playerOffsets) != (flipX != __baseFlipped)) {
			__reverseDrawProcedure = true;

			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;

			__reverseDrawProcedure = false;
		} else
			super.draw();
	}

	public override function playAnim(AnimName:String, Force:Bool = false, Context:PlayAnimContext = NONE, Reversed:Bool = false, Frame:Int = 0):Void
	{
		var event = EventManager.get(PlayAnimEvent).recycle(AnimName, Force, Reversed, Frame, Context);
		script.call("onPlayAnim", [event]);
		if (event.cancelled) return;

		super.playAnim(event.animName, event.force, event.context, event.reverse, event.startingFrame);
		
		offset.set(globalOffset.x * (isPlayer != playerOffsets ? 1 : -1), -globalOffset.y);
		if (event.context == SING || event.context == MISS)
			lastHit = Conductor.songPosition;
	}

	

	public override function destroy() {
		super.destroy();
		
		cameraOffset.put();
		globalOffset.put();
	}

	public inline function getIcon() {
		return (icon != null) ? icon : curCharacter;
	}
}

typedef CharacterShadowFrame = {
	var anim:String;
	var frame:FlxFrame;
}