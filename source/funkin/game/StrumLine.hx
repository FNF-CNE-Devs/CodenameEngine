package funkin.game;

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
     * Whenever Ghost Tapping is enabled.
     */
    @:isVar public var ghostTapping(get, set):Null<Bool> = null;

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
            PlayState.instance.strumLineNotes.add(babyArrow);

            babyArrow.playAnim('static');
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