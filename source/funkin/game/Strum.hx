package funkin.game;

import flixel.FlxSprite;
import flixel.math.FlxMath;

class Strum extends FlxSprite {
    public var cpu = false;
    public var lastHit:Float = -5000;

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (cpu) {
            if (lastHit + (Conductor.crochet) < Conductor.songPosition && getAnim() == "confirm") {
                playAnim("static");
            }
        }
    }

    public function updateNotePosition(daNote:Note) {
        daNote.y = (y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));
        daNote.x = x;
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
        centerOffsets();
        centerOrigin();
    }

    public function playAnim(anim:String, force:Bool = true) {
        var oldAnim = animation.curAnim;
        animation.play(anim, force);
    }
    public function getAnim() {
        return animation.curAnim == null ? null : animation.curAnim.name;
    }
}