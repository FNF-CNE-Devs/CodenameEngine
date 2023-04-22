package funkin.game.cutscenes;

/**
 * Substate made for cutscenes.
 */
class Cutscene extends MusicBeatSubstate {
	var __callback:Void->Void;
	var game:PlayState = PlayState.instance;

	public function new(callback:Void->Void) {
		super();
		__callback = callback;
	}
	public override function update(elapsed:Float) {
		super.update(elapsed);
	}

	public override function close() {
		__callback();
		super.close();
	}
}