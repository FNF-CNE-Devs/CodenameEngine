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

	/**
	 * Name of the splash.
	 */
	public var splash:String = "default";
	
	public var strumID(get, never):Int;
	private function get_strumID() {
		var id = noteData % 4;
		if (id < 0) id = 0;
		return id;
	}

	public var sustainLength:Float = 0;
	public var stepLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var flipSustain:Bool = true;

	public var noteTypeID:Int = 0;

	// TO APPLY THOSE ON A SINGLE NOTE
	public var scrollSpeed:Null<Float> = null;
	public var noteAngle:Null<Float> = null;

	public var noteType(get, null):String;

	@:dox(hide) public var __strumCameras:Array<FlxCamera> = null;
	@:dox(hide) public var __strum:Strum = null;
	@:dox(hide) public var __noteAngle:Float = 0;

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
		var event = EventManager.get(NoteCreationEvent).recycle(this, strumID, this.noteType, noteTypeID, mustPress, Assets.exists(customType) ? 'game/notes/${this.noteType}' : 'game/NOTE_assets', 0.7, animSuffix);

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
	public var useAntialiasingFix:Bool = false;

	/**
	 * Whenever the position of the note should be relative to the strum position or not.
	 * For example, if this is true, a note at the position 0; 0 will be on the strum, instead of at the top left of the screen.
	 */
	public var strumRelativePos:Bool = true;

	override function draw() {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (__strumCameras != null) FlxCamera._defaultCameras = __strumCameras;
		
		var negativeScroll = isSustainNote && nextSustain != null && lastScrollSpeed < 0;
		if (negativeScroll)	offset.y *= -1;

		if (__strum != null && strumRelativePos) {
			var pos = FlxPoint.get(x, y);

			setPosition(__strum.x, __strum.y);

			rotOffset.x -= pos.x / scale.x;
			rotOffset.y -= pos.y / scale.y;

			this.rotOffsetAngle = __noteAngle;

			super.draw();

			this.rotOffsetAngle = 0;

			rotOffset.x += pos.x / scale.x;
			rotOffset.y += pos.y / scale.y;

			setPosition(pos.x, pos.y);
			pos.put();
		} else {
			super.draw();
		}

		if (negativeScroll)	offset.y *= -1;
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

			scale.y = (stepLength * (0.45 * FlxMath.roundDecimal(scrollSpeed, 2))) / frameHeight;
			updateHitbox();
			if (useAntialiasingFix) {
				// dumbass antialiasing
				scale.y += 1 / frameHeight;
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

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}
}
