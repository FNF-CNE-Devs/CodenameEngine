package funkin.game;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import funkin.system.Conductor;

class Strum extends FlxSprite {
    public var cpu = false;
    public var lastHit:Float = -5000;

    public var scrollSpeed:Null<Float> = null; // custom scroll speed per strum
    
    public function getScrollSpeed() {
        if (scrollSpeed != null) return scrollSpeed;
        if (PlayState.instance != null) return PlayState.instance.scrollSpeed;
        return 1;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (cpu) {
            if (lastHit + (Conductor.crochet / 2) < Conductor.songPosition && getAnim() == "confirm") {
                playAnim("static");
            }
        }
    }

    public function updateNotePosition(daNote:Note) {
        var offset = FlxPoint.get(daNote.isSustainNote ? ((Note.swagWidth - daNote.width) / 2) : 0, (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.instance.scrollSpeed, 2)));
        if (daNote.isSustainNote) offset.y -= Note.swagWidth / 2;
        // TODO: angle stuff
        daNote.x = x + offset.x;
        daNote.y = y - offset.y;
        
        offset.put();
    }

    public function updateClipRect(daNote:Note) {
        if (!daNote.isSustainNote || !daNote.wasGoodHit) return;
        daNote.updateClipRect(this);
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