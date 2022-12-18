package funkin.game;

import flixel.math.FlxPoint;
import funkin.interfaces.IBeatReceiver;
import funkin.interfaces.IOffsetCompatible;
import funkin.system.XMLUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import openfl.utils.Assets;
import haxe.xml.Access;
import haxe.Exception;
import haxe.io.Path;
import funkin.system.Conductor;
import funkin.scripting.DummyScript;
import funkin.scripting.Script;
import funkin.scripting.events.*;
import funkin.scripting.events.PlayAnimEvent.PlayAnimContext;

using StringTools;

class Character extends FlxSprite implements IBeatReceiver implements IOffsetCompatible
{
	private var __stunnedTime:Float = 0;

	public var stunned(default, set):Bool = false;

	private function set_stunned(b:Bool)
	{
		__stunnedTime = 0;
		return stunned = b;
	}

	public var animOffsets:Map<String, FlxPoint>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var isGF:Bool = false;
	public var curCharacter:String = 'bf';

	public var lastHit:Float = -5000;
	public var holdTime:Float = 4;

	public var playerOffsets:Bool = false;

	public var icon:String = null;
	public var gameOverCharacter:String = "bf-dead";

	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);
	public var globalOffset:FlxPoint = new FlxPoint(0, 0);

	public var script:Script;
	public var xml:Access;

	public inline function getCameraPosition()
	{
		var midpoint = getMidpoint();
		var event = new PointEvent(midpoint.x
			+ (isPlayer ? -100 : 150)
			+ globalOffset.x
			+ cameraOffset.x, midpoint.y
			- 100
			+ globalOffset.y
			+ cameraOffset.y);
		script.call("onGetCamPos", [event]);
		// this event cannot be cancelled
		return new FlxPoint(event.x, event.y);
	}

	public function playSingAnim(direction:Int, suffix:String = "", Reversed:Bool = false, Frame:Int = 0)
	{
		var anims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

		var event = new DirectionAnimEvent('${anims[direction]}$suffix', direction, suffix, Reversed, Frame);
		script.call("onPlaySingAnim", [event]);
		if (!event.cancelled)
			playAnim(event.animName, event.force, SING, event.reversed, event.frame);
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
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
						if (charXML == null)
							throw new Exception("Missing \"character\" node in XML.");
						xml = new Access(charXML);
					}
					catch (e)
					{
						trace(e);
						curCharacter = "bf";
						continue;
					}
					var sprite:String = curCharacter;

					if (xml.has.isPlayer)
						playerOffsets = (xml.att.isPlayer == "true");
					if (xml.has.isGF)
						isGF = (xml.att.isGF == "true");
					if (xml.has.x)
						globalOffset.x = Std.parseFloat(xml.att.x);
					if (xml.has.y)
						globalOffset.y = Std.parseFloat(xml.att.y);
					if (xml.has.gameOverChar)
						gameOverCharacter = xml.att.gameOverChar;
					if (xml.has.camx)
						cameraOffset.x = Std.parseFloat(xml.att.camx);
					if (xml.has.camy)
						cameraOffset.y = Std.parseFloat(xml.att.camy);
					if (xml.has.holdTime)
						holdTime = CoolUtil.getDefault(Std.parseFloat(xml.att.holdTime), 4);
					if (xml.has.flipX)
						flipX = (xml.att.flipX == "true");
					if (xml.has.icon)
						icon = xml.att.icon;
					if (xml.has.scale)
					{
						var scale = Std.parseFloat(xml.att.scale).getDefault(1);
						this.scale.set(scale, scale);
						updateHitbox();
					}
					if (xml.has.antialiasing)
						antialiasing = (xml.att.antialiasing == "true");
					if (xml.has.sprite)
						sprite = xml.att.sprite;

					frames = Paths.getFrames('characters/$sprite', null);
					for (anim in xml.nodes.anim)
					{
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

		isDanceLeftDanceRight = (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null);

		if (isDanceLeftDanceRight)
			danceSpeed = 1;

		// alternative to xor operator
		// for people who dont believe it, heres the truth table
		// [   a   ][   b   ][ a!= b ]
		// [ true  ][ true  ][ false ]
		// [ true  ][ false ][ true  ]
		// [ false ][ true  ][ true  ]
		// [ true  ][ true  ][ false ]
		if (isPlayer != playerOffsets)
		{
			// character is flipped
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHT'), animation.getByName('singLEFT'));
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHTmiss'), animation.getByName('singLEFTmiss'));

			switchOffset('singLEFT', 'singRIGHT');
			switchOffset('singLEFTmiss', 'singRIGHTmiss');
		}
		if (isPlayer)
			flipX = !flipX;
		__baseFlipped = flipX;
		dance();
		animation.finish();
		script.call("postCreate");
	}

	var __baseFlipped:Bool = false;
	var isDanceLeftDanceRight:Bool = false;

	public function switchOffset(anim1:String, anim2:String)
	{
		var old = animOffsets[anim1];
		animOffsets[anim1] = animOffsets[anim2];
		animOffsets[anim2] = old;
	}

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
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			var event = new DanceEvent(danced);
			script.call("onDance", [event]);
			if (event.cancelled)
				return;

			switch (curCharacter)
			{
				// hardcode custom dance animations here
				default:
					if (isDanceLeftDanceRight)
						playAnim((danced = !danced) ? 'danceLeft' : 'danceRight', DANCE);
					else
						playAnim('idle', DANCE);
			}
		}
	}

	/**
	 * Whenever the character should dance on beat or not.
	 */
	public var danceOnBeat:Bool = true;

	/**
	 * The dance speed of the character (works like `gfSpeed`).
	 */
	public var danceSpeed:Int = 2;

	public function beatHit(curBeat:Int)
	{
		script.call("beatHit", [curBeat]);
		if (danceOnBeat)
		{
			switch (lastAnimContext)
			{
				case SING | MISS:
					if (lastHit + (Conductor.stepCrochet * holdTime) < Conductor.songPosition)
					{
						dance();
						if (lastAnimContext != SING && curBeat % danceSpeed != 0)
							animation.finish();
					}
				default:
					if (curBeat % danceSpeed == 0)
						dance();
			}
		}
	}

	public function stepHit(curStep:Int)
	{
		script.call("stepHit", [curStep]);
		// nothing
	}

	var __reverseDrawProcedure:Bool = false;

	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		if (__reverseDrawProcedure)
		{
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}

	public override function draw()
	{
		if ((isPlayer != playerOffsets) != (flipX != __baseFlipped))
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

	public var lastAnimContext:PlayAnimContext = DANCE;

	public function playAnim(AnimName:String, Force:Bool = false, Context:PlayAnimContext = NONE, Reversed:Bool = false, Frame:Int = 0):Void
	{
		var event = new PlayAnimEvent(AnimName, Force, Reversed, Frame, Context);

		script.call("onPlayAnim", [event]);

		if (event.cancelled || event.animName == null || !animation.exists(event.animName))
			return;

		animation.play(event.animName, event.force, event.reverse, event.startingFrame);

		var daOffset = animOffsets.get(event.animName);
		if (daOffset != null)
			rotOffset.set(daOffset.x, daOffset.y);
		else
			rotOffset.set(0, 0);

		offset.set(globalOffset.x * (isPlayer != playerOffsets ? 1 : -1), -globalOffset.y);

		if (event.context == SING || event.context == MISS)
			lastHit = Conductor.songPosition;

		lastAnimContext = event.context;
	}

	public override function destroy()
	{
		super.destroy();
	}

	public inline function getIcon()
	{
		return (icon != null) ? icon : curCharacter;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = new FlxPoint(x, y);
	}
}
