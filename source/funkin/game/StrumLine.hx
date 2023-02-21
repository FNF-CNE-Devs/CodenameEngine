package funkin.game;

import funkin.scripting.events.SimpleNoteEvent;
import funkin.system.Conductor;
import funkin.chart.Chart.ChartStrumLine;
import funkin.system.Controls;
import funkin.scripting.events.StrumCreationEvent;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;

class StrumLine extends FlxTypedGroup<Strum> {
    /**
     * Array containing all of the characters "attached" to those strums.
     */
    public var characters:Array<Character>;
    /**
     * Whenever this strumline is controlled by cpu or not.
     */
    public var cpu(default, set):Bool = false;
    /**
     * Whenever this strumline is from the opponent side or the player side.
     */
    public var opponentSide:Bool = false;
    /**
     * Controls assigned to this strumline.
     */
    public var controls:Controls = null;
    /**
     * Chart JSON data assigned to this StrumLine (Codename format)
     */
    public var data:ChartStrumLine = null;
    /**
     * Whenever Ghost Tapping is enabled.
     */
    @:isVar public var ghostTapping(get, set):Null<Bool> = null;
	/**
	 * Group of all of the notes in this strumline. Using `forEach` on this group will only loop through the first notes for performance reasons.
	 */
	public var notes:NoteGroup;

    private function get_ghostTapping() {
        if (this.ghostTapping != null) return this.ghostTapping;
        if (PlayState.instance != null) return PlayState.instance.ghostTapping;
        return false;
    }

    private inline function set_ghostTapping(b:Bool):Bool
        return this.ghostTapping = b;
    
    private var strumOffset:Float = 0.25;

    public function new(characters:Array<Character>, strumOffset:Float = 0.25, cpu:Bool = false, opponentSide:Bool = true, ?controls:Controls) {
        super();
        this.characters = characters;
        this.strumOffset = strumOffset;
        this.cpu = cpu;
        this.opponentSide = opponentSide;
        this.controls = controls;
        this.notes = new NoteGroup();
    }

    public function generate(strumLine:ChartStrumLine) {
        if (strumLine.notes != null) for(note in strumLine.notes) {
            notes.add(new Note(this, note, false));
        }
        notes.sortNotes();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        notes.update(elapsed);
    }

    public override function draw() {
        super.draw();
        notes.cameras = cameras;
        notes.draw();
    }

    public function updateNotes() {
        notes.forEach(updateNote);
    }
    
    var __updateNote_strum:Strum;
    public function updateNote(daNote:Note) {
        
        for(e in members) {
            if (e.ID == daNote.noteData % 4) {
                __updateNote_strum = e;
                break; //ing bad
            }
        }
        PlayState.instance.scripts.event("onNoteUpdate", PlayState.instance.__updateNote_event.recycle(daNote, FlxG.elapsed, __updateNote_strum));
        if (PlayState.instance.__updateNote_event.cancelled) return;

        if (PlayState.instance.__updateNote_event.__updateHitWindow) {
            daNote.canBeHit = (daNote.strumTime > Conductor.songPosition - (PlayState.instance.hitWindow * daNote.latePressWindow)
                && daNote.strumTime < Conductor.songPosition + (PlayState.instance.hitWindow * daNote.earlyPressWindow));

            if (daNote.strumTime < Conductor.songPosition - PlayState.instance.hitWindow && !daNote.wasGoodHit)
                daNote.tooLate = true;
        }

        if (PlayState.instance.__updateNote_event.__autoCPUHit && cpu && !daNote.wasGoodHit && daNote.strumTime < Conductor.songPosition) PlayState.instance.goodNoteHit(this, daNote);

        if (daNote.wasGoodHit && daNote.isSustainNote && daNote.strumTime + (daNote.stepLength) < Conductor.songPosition) {
            deleteNote(daNote);
            return;
        }

        if (daNote.tooLate && !cpu) {
            PlayState.instance.noteMiss(this, daNote);
            return;
        }


        if (PlayState.instance.__updateNote_event.strum == null) return;

        if (PlayState.instance.__updateNote_event.__reposNote) PlayState.instance.__updateNote_event.strum.updateNotePosition(daNote);
        PlayState.instance.__updateNote_event.strum.updateSustain(daNote);

        PlayState.instance.scripts.event("onNotePostUpdate", PlayState.instance.__updateNote_event);
    }

    public inline function addHealth(health:Float)
        PlayState.instance.health += health * (opponentSide ? -1 : 1);

    public function generateStrums(amount:Int = 4) {
        for (i in 0...4)
        {
            var babyArrow:Strum = new Strum((FlxG.width * strumOffset) + (Note.swagWidth * (i - 2)), PlayState.instance.strumLine.y);
            babyArrow.ID = i;

            var event = PlayState.instance.scripts.event("onStrumCreation", EventManager.get(StrumCreationEvent).recycle(babyArrow, PlayState.instance.players.indexOf(this), i));

            if (!event.cancelled) {
                babyArrow.frames = Paths.getFrames(event.sprite);
                babyArrow.animation.addByPrefix('green', 'arrowUP');
                babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
                babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
                babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

                babyArrow.antialiasing = true;
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

                switch (babyArrow.ID % 4)
                {
                    case 0:
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                        babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                    case 1:
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                        babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                    case 2:
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                        babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                    case 3:
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                        babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
                }
            }

            babyArrow.cpu = cpu;
            babyArrow.updateHitbox();
            babyArrow.scrollFactor.set();

            if (event.__doAnimation)
            {
                babyArrow.y -= 10;
                babyArrow.alpha = 0;
                FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            }

            add(babyArrow);

            babyArrow.playAnim('static');
        }
    }

	/**
	 * Deletes a note from this strumline.
	 * @param note Note to delete
	 */
	public function deleteNote(note:Note) {
		if (note == null) return;
		var event:SimpleNoteEvent = PlayState.instance.scripts.event("onNoteDelete", EventManager.get(SimpleNoteEvent).recycle(note));
		if (!event.cancelled) {
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

    /**
     * SETTERS & GETTERS
     */
    #if REGION
    private inline function set_cpu(b:Bool):Bool {
        for(s in members)
            if (s != null)
                s.cpu = b;
        return cpu = b;
    }
    #end
}