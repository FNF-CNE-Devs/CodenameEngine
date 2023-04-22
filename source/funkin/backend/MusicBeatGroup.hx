package funkin.backend;

import funkin.backend.system.interfaces.IBeatReceiver;

class MusicBeatGroup extends FlxTypedSpriteGroup<FlxSprite> implements IBeatReceiver {
	public function beatHit(curBeat:Int) {
		for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).beatHit(curBeat);
	}
	public function stepHit(curStep:Int) {
		for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).stepHit(curStep);
	}
	public function measureHit(curMeasure:Int) {
		for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).measureHit(curMeasure);
	}
}