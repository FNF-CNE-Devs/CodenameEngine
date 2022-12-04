package funkin.game;

import openfl.utils.Assets;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import funkin.system.Conductor;
import funkin.scripting.events.*;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	/**
	 * Whenever that note should be avoided by Botplay.
	 */
	public var avoid:Bool = false;

	/**
	 * The note that comes before this one (sustain and not)
	 */
	public var prevNote:Note;
	/**
	 * The note that comes after this one (sustain and not)
	 */
	public var nextNote:Note;
	/**
	 * The next sustain after this one
	 */
	public var nextSustain:Note;

	public var strumID(get, never):Int;
	private function get_strumID() {
		var id = noteData % 4;
		if (id < 0) id = 0;
		return id;
	}

	public var sustainLength:Float = 0;
	public var stepLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteTypeID:Int = 0;

	// TO APPLY THOSE ON A SINGLE NOTE
	public var scrollSpeed:Null<Float> = null;
	public var noteAngle:Null<Float> = null;

	public var noteType(get, null):String;

	@:dox(hide) public var __strumCameras:Array<FlxCamera> = null;

	private function get_noteType() {
		if (PlayState.instance == null) return null;
		return PlayState.instance.getNoteType(noteTypeID);
	}

	public static var swagWidth:Float = 160 * 0.7;

	public var animSuffix:String = "";

	public function new(strumTime:Float, noteData:Int, noteType:Int = 0, mustPress:Bool = true, ?prevNote:Note, ?sustainNote:Bool = false, animSuffix:String = "")
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.mustPress = mustPress;
		this.noteTypeID = noteType;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var customType = Paths.image('game/notes/${this.noteType}');
		var event = new NoteCreationEvent(this, strumID, this.noteType, noteTypeID, mustPress, Assets.exists(customType) ? 'game/notes/${this.noteType}' : 'game/NOTE_assets', 0.7, animSuffix);

		if (PlayState.instance != null)
			event = PlayState.instance.scripts.event("onNoteCreation", event);

		this.animSuffix = event.animSuffix;
		if (!event.cancelled) {
			switch (event.noteType)
			{
				// case "My Custom Note Type": // hardcoding note types
				default:
					frames = Paths.getFrames(event.noteSprite);

					switch(event.strumID % 4) {
						case 0:
							animation.addByPrefix('scroll', 'purple0');
							animation.addByPrefix('hold', 'purple hold piece');
							animation.addByPrefix('holdend', 'pruple end hold');
						case 1:
							animation.addByPrefix('scroll', 'blue0');
							animation.addByPrefix('hold', 'blue hold piece');
							animation.addByPrefix('holdend', 'blue hold end');
						case 2:
							animation.addByPrefix('scroll', 'green0');
							animation.addByPrefix('hold', 'green hold piece');
							animation.addByPrefix('holdend', 'green hold end');
						case 3:
							animation.addByPrefix('scroll', 'red0');
							animation.addByPrefix('hold', 'red hold piece');
							animation.addByPrefix('holdend', 'red hold end');
					}

					scale.set(event.noteScale, event.noteScale);
					updateHitbox();
					antialiasing = true;
			}
		}


		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			animation.play('holdend');

			updateHitbox();

			if (prevNote.isSustainNote)
			{
				prevNote.nextSustain = this;
				prevNote.animation.play('hold');
			}
		} else {
			animation.play("scroll");
		}

		if (PlayState.instance != null)
			PlayState.instance.scripts.event("onPostNoteCreation", event);
	}

	public var lastScrollSpeed:Null<Float> = null;
	public var angleOffsets:Bool = true;

	override function draw() {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (__strumCameras != null) FlxCamera._defaultCameras = __strumCameras;
		
		var negativeScroll = isSustainNote && nextSustain != null && lastScrollSpeed < 0;
		if (antialiasing && nextSustain == null)
			rotOffset.y += 2;
		if (negativeScroll)	offset.y *= -1;

		if (angleOffsets && Std.int(angle % 360) != 0) {
			// get default values
			var oldOffset = FlxPoint.get(offset.x, offset.y);
			var oldOrigin = FlxPoint.get(origin.x, origin.y);

			// get offset pos without origin
			var pos = FlxPoint.get(-offset.x, -offset.y);

			// updates sin and cos values for angle
			updateTrig();

			var sin = _sinAngle;
			var cos = _cosAngle;
			
			var anglePos = FlxPoint.get(
				(-cos * pos.x) + (-sin * pos.y),
				(-sin * pos.x) + (-cos * pos.y));

			// applies new values
			x -= anglePos.x;
			y -= anglePos.y;
			offset.set();
			origin.set(oldOrigin.x - oldOffset.x, oldOrigin.y - oldOffset.y);

			// draw
			super.draw();

			// reset values
			offset.set(oldOffset.x, oldOffset.y);
			origin.set(oldOrigin.x, oldOrigin.y);
			x += anglePos.x;
			y += anglePos.y;

			// put flxpoints back in the recycling pool
			oldOffset.put();
			oldOrigin.put();
			pos.put();
			anglePos.put();
			return;
		}
		super.draw();
		if (negativeScroll)	offset.y *= -1;
		if (antialiasing && nextSustain == null)
			rotOffset.y -= 2;
		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}

	// The * 0.5 is so that it's easier to hit them too late, instead of too early
	public var earlyPressWindow:Float = 0.5;
	public var latePressWindow:Float = 1;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function updateSustain(strum:Strum) {
		var scrollSpeed = strum.getScrollSpeed(this);

		if (nextSustain != null && lastScrollSpeed != scrollSpeed) {
			// is long sustain
			lastScrollSpeed = scrollSpeed;

			// scale.y = stepLength / 100 * 1.5 * scrollSpeed * 0.7;
			scale.y = (stepLength * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2))) / frameHeight;
			updateHitbox();
			if (antialiasing && !FlxG.forceNoAntialiasing) {
				// dumbass antialiasing
				scale.y += 3 / frameHeight;
			}
		}

		if (!wasGoodHit) return;
		var t = FlxMath.bound((Conductor.songPosition - strumTime) / (height / (0.45 * FlxMath.roundDecimal(scrollSpeed, 2))), 0, 1);
		var swagRect = new FlxRect(0, t * frameHeight, frameWidth, frameHeight);

		setClipRect(swagRect);
	}

	public function setClipRect(rect:FlxRect) {
		this.clipRect = rect;
	}
}
