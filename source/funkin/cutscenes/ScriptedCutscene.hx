package funkin.cutscenes;

import funkin.scripting.Script;

class ScriptedCutscene extends Cutscene {
    var script:Script;

    public function new(scriptPath:String, callback:Void->Void) {
        super(callback);

        script = Script.create(scriptPath);
        script.setPublicMap(PlayState.instance.scripts.publicVariables);
        script.setParent(this);
        script.load();
    }

    public override function create() {
        super.create();
        script.call("create");
    }

    public override function update(elapsed:Float) {
        script.call("update", [elapsed]);
        super.update(elapsed);
        script.call("updatePost", [elapsed]);
    }

    public override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);
        script.call("beatHit", [curBeat]);
    }

    public override function stepHit(curStep:Int) {
        super.stepHit(curStep);
        script.call("stepHit", [curStep]);
    }

    public override function destroy() {
        script.call("destroy");
        super.destroy();
    }

    public function startVideo(path:String, ?callback:Void->Void) {
        openSubState(new VideoCutscene(path, function() {
            if (callback != null)
                callback();
        }));
    }
}