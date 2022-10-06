package funkin.scripting;

import openfl.Assets;
import hscript.*;

class HScript extends Script {
    var interp:Interp;
    public override function create(path:String) {
        super.create(path);

        var code:String = Assets.getText(path);
        interp = new Interp();
    }

    public override function call() {

    }
}