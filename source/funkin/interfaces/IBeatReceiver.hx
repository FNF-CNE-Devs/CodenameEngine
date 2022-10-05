package funkin.interfaces;

interface IBeatReceiver {
    public function beatHit(curBeat:Int):Void;
    public function stepHit(curStep:Int):Void;
}