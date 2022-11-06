package funkin.cutscenes;

class Cutscene extends MusicBeatSubstate {
    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public override function close() {
        PlayState.instance.startCountdown();
        super.close();
    }
}