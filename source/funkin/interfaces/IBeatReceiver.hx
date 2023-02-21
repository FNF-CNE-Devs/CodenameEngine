package funkin.interfaces;

interface IBeatReceiver {
    public function measureHit(curMeasure:Int):Void;
    public function beatHit(curBeat:Int):Void;
    public function stepHit(curStep:Int):Void;
}