package funkin.system;

import flixel.FlxSprite;
import funkin.interfaces.IBeatReceiver;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class MusicBeatGroup extends FlxTypedSpriteGroup<FlxSprite> implements IBeatReceiver {
    public function beatHit(curBeat:Int) {
        for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).beatHit(curBeat);
    }
    public function stepHit(curStep:Int) {
        for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).stepHit(curStep);
    }
}