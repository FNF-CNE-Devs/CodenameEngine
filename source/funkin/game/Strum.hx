package funkin.game;

import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import funkin.options.Options;
import funkin.system.Conductor;

class Strum extends FlxSprite {
    public var cpu = false;
    public var lastHit:Float = -5000;

    public var scrollSpeed:Null<Float> = null; // custom scroll speed per strum
    public var noteAngle:Null<Float> = null; // custom scroll speed per strum
    
    public var lastDrawCameras(default, null):Array<FlxCamera> = [];

    public function getScrollSpeed(?note:Note) {
        if (note != null && note.scrollSpeed != null) return note.scrollSpeed;
        if (scrollSpeed != null) return scrollSpeed;
        if (PlayState.instance != null) return PlayState.instance.scrollSpeed;
        return 1;
    }
    
    public function getNotesAngle(?note:Note) {
        if (note != null && note.noteAngle != null) return note.noteAngle;
        if (noteAngle != null) return noteAngle;
        return angle;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (cpu) {
            if (lastHit + (Conductor.crochet / 2) < Conductor.songPosition && getAnim() == "confirm") {
                playAnim("static");
            }
        }
    }

    public override function draw() {
        lastDrawCameras = [for(c in cameras) c];
        super.draw();
    }

    public function updateNotePosition(daNote:Note) {
        if (!daNote.exists) return;
        
        var offset = FlxPoint.get(daNote.isSustainNote ? ((Note.swagWidth - daNote.width) / 2) : 0, (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(getScrollSpeed(daNote), 2)));
        var realOffset = FlxPoint.get(0, 0);

        daNote.__strumCameras = lastDrawCameras;

        if (daNote.isSustainNote) offset.y -= Note.swagWidth / 2;
        
        daNote.scrollFactor.set(scrollFactor.x, scrollFactor.y);
        
        var noteAngle = daNote.__noteAngle = getNotesAngle(daNote);
        daNote.angle = daNote.isSustainNote ? noteAngle : angle;
        if (Std.int(noteAngle % 360) != 0) {
            var noteAngleCos = Math.cos(noteAngle / 180 * Math.PI);
            var noteAngleSin = Math.sin(noteAngle / 180 * Math.PI);
            realOffset.x = (noteAngleCos * offset.x) + (noteAngleSin * offset.y);
            realOffset.y = (noteAngleSin * offset.x) + (noteAngleCos * offset.y);
        } else {
            realOffset.x = offset.x;
            realOffset.y = offset.y;
        }
        realOffset.y *= -1;

        daNote.setPosition(x + realOffset.x, y + realOffset.y);
        
        offset.put();
        realOffset.put();
    }

    public function updateSustain(daNote:Note) {
        if (!daNote.isSustainNote) return;
        daNote.flipY = daNote.flipSustain && (PlayState.instance.downscroll != (getScrollSpeed(daNote) < 0));
        daNote.updateSustain(this);
    }

    public function updatePlayerInput(pressed:Bool, justPressed:Bool, justReleased:Bool) {
        switch(getAnim()) {
            case "confirm":
                if (justReleased || !pressed)
                    playAnim("static");
            case "pressed":
                if (justReleased || !pressed)
                    playAnim("static");
            case "static":
                if (justPressed || pressed)
                    playAnim("pressed");
            case null:
                playAnim("static");
        }
        centerOffsets();
        centerOrigin();
    }

    public function press(time:Float) {
        lastHit = time;
        playAnim("confirm");
    }

    public function playAnim(anim:String, force:Bool = true) {
        var oldAnim = animation.curAnim;
        animation.play(anim, force);
        centerOffsets();
        centerOrigin();
    }
    public function getAnim() {
        return animation.curAnim == null ? null : animation.curAnim.name;
    }
}