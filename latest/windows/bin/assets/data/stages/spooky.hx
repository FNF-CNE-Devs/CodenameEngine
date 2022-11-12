public var lightningStrike:Bool = true;
public var lightningStrikeBeat:Int = 0;
public var lightningOffset:Int = 8;

public function lightningStrikeShit():Void
{
    FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    bg.animation.play('lightning');

    lightningStrikeBeat = curBeat;
    lightningOffset = FlxG.random.int(8, 24);

    boyfriend.playAnim('scared', true, "SING"); // SING so that they dont get indefinitely looped
    gf.playAnim('scared', true, "SING");
}

function beatHit(curBeat) {
    if (lightningStrike && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
    {
        lightningStrikeShit();
    }
}