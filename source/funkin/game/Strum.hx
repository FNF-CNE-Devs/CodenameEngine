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

    public inline function getScrollSpeed(?note:Note):Float {
        if (note != null && note.scrollSpeed != null) return note.scrollSpeed;
        if (scrollSpeed != null) return scrollSpeed;
        if (PlayState.instance != null) return PlayState.instance.scrollSpeed;
        return 1;
    }
    
    public inline function getNotesAngle(?note:Note):Float {
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

    @:noCompletion public static final PIX180:Float = 565.4866776461628; // 180 * Math.PI
    @:noCompletion public static final N_WIDTHDIV2:Float = Note.swagWidth / 2;

    public function updateNotePosition(daNote:Note) {
        if (!daNote.exists) return;
    
        daNote.__strumCameras = lastDrawCameras;
        daNote.__strum = this;
        daNote.scrollFactor.set(scrollFactor.x, scrollFactor.y);
        var noteAngle = daNote.__noteAngle = getNotesAngle(daNote);
        daNote.angle = daNote.isSustainNote ? noteAngle : angle;

        if (daNote.strumRelativePos) {
            daNote.setPosition(daNote.isSustainNote ? ((Note.swagWidth - daNote.width) / 2) : 0, (daNote.strumTime - Conductor.songPosition) * (0.45 * FlxMath.roundDecimal(getScrollSpeed(daNote), 2)));
            if (daNote.isSustainNote) daNote.y += N_WIDTHDIV2;
        } else {
            var offset = FlxPoint.get(0, (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(getScrollSpeed(daNote), 2)));
            var realOffset = FlxPoint.get(0, 0);

            if (daNote.isSustainNote) offset.y -= N_WIDTHDIV2;
            
            if (Std.int(noteAngle % 360) != 0) {
                var noteAngleCos = FlxMath.fastCos(noteAngle / PIX180);
                var noteAngleSin = FlxMath.fastSin(noteAngle / PIX180);

                var aOffset:FlxPoint = FlxPoint.get(
                    (daNote.origin.x / daNote.scale.x) - daNote.offset.x,
                    (daNote.origin.y / daNote.scale.y) - daNote.offset.y
                );
                realOffset.x = -aOffset.x + (noteAngleCos * (offset.x + aOffset.x)) + (noteAngleSin * (offset.y + aOffset.y));
                realOffset.y = -aOffset.y + (noteAngleSin * (offset.x + aOffset.x)) + (noteAngleCos * (offset.y + aOffset.y));

                aOffset.put();
            } else {
                realOffset.x = offset.x;
                realOffset.y = offset.y;
            }
            realOffset.y *= -1;
    
            daNote.setPosition(x + realOffset.x, y + realOffset.y);
            
            offset.put();
            realOffset.put();
        }
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