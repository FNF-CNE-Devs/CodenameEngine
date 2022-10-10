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
import funkin.system.Conductor;

import funkin.scripting.events.PlayAnimEvent;
import funkin.scripting.events.PlayAnimEvent.PlayAnimContext;
using StringTools;

class Character extends FlxSprite implements IBeatReceiver implements IOffsetCompatible
{
	private var __stunnedTime:Float = 0;
	public var stunned(default, set):Bool = false;

	private function set_stunned(b:Bool) {
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

	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);
	public var globalOffset:FlxPoint = new FlxPoint(0, 0);

	public inline function getCameraPosition() {
		var midpoint = getMidpoint();
		return FlxPoint.get(
			midpoint.x + (isPlayer ? -100 : 150) + globalOffset.x + cameraOffset.x,
			midpoint.y - 100 + globalOffset.y + cameraOffset.y);
	}

	public function playSingAnim(direction:Int, suffix:String = "") {
		// TODO: Script Events
		var anims = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
		playAnim('${anims[direction]}$suffix', true);
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, FlxPoint>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		while(true) {
			switch (curCharacter)
			{
				// case 'your-char': // To hardcode characters
				default:
					// load xml
					if (!Assets.exists(Paths.xml('characters/$curCharacter'))) {
						curCharacter = "bf";
						continue;
					}

					var plainXML = Assets.getText(Paths.xml('characters/$curCharacter'));
					var character:Access;
					try {
						var charXML = Xml.parse(plainXML).firstElement();
						if (charXML == null) throw new Exception("Missing \"character\" node in XML.");
						character = new Access(charXML);
					} catch(e) {
						trace(e);
						curCharacter = "bf";
						continue;
					}

					if (character.has.isPlayer) playerOffsets = (character.att.isPlayer == "true");
					if (character.has.isGF) isGF = (character.att.isGF == "true");
					if (character.has.x) globalOffset.x = Std.parseFloat(character.att.x);
					if (character.has.y) globalOffset.y = Std.parseFloat(character.att.y);
					if (character.has.camx) cameraOffset.x = Std.parseFloat(character.att.camx);
					if (character.has.camy) cameraOffset.y = Std.parseFloat(character.att.camy);
					if (character.has.holdTime) holdTime = CoolUtil.getDefault(Std.parseFloat(character.att.holdTime), 4);
					if (character.has.flipX) flipX = (character.att.flipX == "true");
					if (character.has.icon) icon = character.att.icon;

					frames = Paths.getSparrowAtlas('characters/$curCharacter');
					for(anim in character.nodes.anim) {
						XMLUtil.addXMLAnimation(this, anim);
					}
			}
			break;
		}

		/**
			NON CONVERTED CHARACTERS - DO NOT REMOVE
		**/
		// 	case 'gf-pixel':
		// 		tex = Paths.getSparrowAtlas('weeb/gfPixel');
		// 		frames = tex;
		// 		animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
		// 		animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		// 		animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

		// 		addOffset('danceLeft', 0);
		// 		addOffset('danceRight', 0);

		// 		playAnim('danceRight');

		// 		setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		// 		updateHitbox();
		// 		antialiasing = false;
		// 		flipX = true;

		// 	case 'bf-pixel':
		// 		frames = Paths.getSparrowAtlas('weeb/bfPixel');
		// 		animation.addByPrefix('idle', 'BF IDLE', 24, false);
		// 		animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
		// 		animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
		// 		animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
		// 		animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
		// 		animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
		// 		animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
		// 		animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP");
		// 		addOffset("singRIGHT");
		// 		addOffset("singLEFT");
		// 		addOffset("singDOWN");
		// 		addOffset("singUPmiss");
		// 		addOffset("singRIGHTmiss");
		// 		addOffset("singLEFTmiss");
		// 		addOffset("singDOWNmiss");

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		playAnim('idle');

		// 		width -= 100;
		// 		height -= 100;

		// 		antialiasing = false;

		// 		flipX = true;
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

		// 	case 'senpai':
		// 		frames = Paths.getSparrowAtlas('weeb/senpai');
		// 		animation.addByPrefix('idle', 'Senpai Idle', 24, false);
		// 		animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
		// 		animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
		// 		animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", 5, 37);
		// 		addOffset("singRIGHT");
		// 		addOffset("singLEFT", 40);
		// 		addOffset("singDOWN", 14);

		// 		playAnim('idle');

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		antialiasing = false;
		// 	case 'senpai-angry':
		// 		frames = Paths.getSparrowAtlas('weeb/senpai');
		// 		animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
		// 		animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
		// 		animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
		// 		animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
		// 		animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

		// 		addOffset('idle');
		// 		addOffset("singUP", 5, 37);
		// 		addOffset("singRIGHT");
		// 		addOffset("singLEFT", 40);
		// 		addOffset("singDOWN", 14);
		// 		playAnim('idle');

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		antialiasing = false;

		// 	case 'spirit':
		// 		frames = Paths.getPackerAtlas('weeb/spirit');
		// 		animation.addByPrefix('idle', "idle spirit_", 24, false);
		// 		animation.addByPrefix('singUP', "up_", 24, false);
		// 		animation.addByPrefix('singRIGHT', "right_", 24, false);
		// 		animation.addByPrefix('singLEFT', "left_", 24, false);
		// 		animation.addByPrefix('singDOWN', "spirit down_", 24, false);

		// 		addOffset('idle', -220, -280);
		// 		addOffset('singUP', -220, -240);
		// 		addOffset("singRIGHT", -220, -280);
		// 		addOffset("singLEFT", -200, -280);
		// 		addOffset("singDOWN", 170, 110);

		// 		setGraphicSize(Std.int(width * 6));
		// 		updateHitbox();

		// 		playAnim('idle');

		// 		antialiasing = false;
		dance();


		isDanceLeftDanceRight = (animation.getByName("danceLeft") != null && animation.getByName("danceRight") != null);
		
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
		if (isPlayer) flipX = !flipX;
	}

	var isDanceLeftDanceRight:Bool = false;

	public function switchOffset(anim1:String, anim2:String) {
		var old = animOffsets[anim1];
		animOffsets[anim1] = animOffsets[anim2];
		animOffsets[anim2] = old;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (stunned) {
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
			switch (curCharacter)
			{
				// hardcode custom dance animations here
				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					if (isDanceLeftDanceRight) {
						playAnim((danced = !danced) ? 'danceLeft' : 'danceRight');
					} else
						playAnim('idle');
			}
		}
	}

	public function beatHit(curBeat:Int) {
		if ((lastHit + (Conductor.stepCrochet * holdTime) < Conductor.songPosition) || animation.curAnim == null || (!animation.curAnim.name.startsWith("sing") && animation.curAnim.finished))
			dance();
	}
	public function stepHit(curStep:Int) {
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
	
	public override function draw() {
		if (flipX) {
			__reverseDrawProcedure = true;

			flipX = false;
			scale.x *= -1;
			super.draw();
			flipX = true;
			scale.x *= -1;

			__reverseDrawProcedure = false;
		} else
			super.draw();
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0, Context:PlayAnimContext = NONE):Void
	{
		var event = new PlayAnimEvent(AnimName, Force, Reversed, Frame);
		
		// TODO: Character Scripts

		if (event.cancelled || event.animName == null) return;

		animation.play(event.animName, event.force, event.reverse, event.startingFrame);

		var daOffset = animOffsets.get(event.animName);
		if (daOffset != null)
			offset.set(daOffset.x * (isPlayer != playerOffsets ? -1 : 1), daOffset.y);
		else
			offset.set(0, 0);

		offset.x += globalOffset.x * (isPlayer != playerOffsets ? 1 : -1);
		offset.y -= globalOffset.y;

		if (event.animName.startsWith("sing"))
			lastHit = Conductor.songPosition;
		
		if (curCharacter == 'gf')
		{
			if (event.animName == 'singLEFT')
			{
				danced = true;
			}
			else if (event.animName == 'singRIGHT')
			{
				danced = false;
			}

			if (event.animName == 'singUP' || event.animName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public override function destroy() {
		super.destroy();
	}

	public inline function getIcon() {
		return (icon != null) ? icon : curCharacter;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = new FlxPoint(x, y);
	}
}