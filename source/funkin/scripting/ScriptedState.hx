package funkin.scripting;

class ScriptedState extends MusicBeatState {
    var script:Script;

    public override function new(scriptName:String) {
        super();
        
        script = Script.create(Paths.script('data/states/${scriptName}'));
        script.setParent(this);
        script.load();
    }

    public override function create() {
        super.create();
        script.call("create");
    }

    public override function update(elapsed:Float) {
        script.call("preUpdate", [elapsed]);
        super.update(elapsed);
        script.call("update", [elapsed]);
    }

    public override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);
        script.call("beatHit", [curBeat]);
    }

    public override function stepHit(curStep:Int) {
        super.stepHit(curStep);
        script.call("stepHit", [curStep]);
    }
}