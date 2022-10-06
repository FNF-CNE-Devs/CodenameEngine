package funkin.scripting;

import hscript.Expr.Error;
import openfl.Assets;
import hscript.*;

class HScript extends Script {
    var interp:Interp;
    public override function onCreate(path:String) {
        super.onCreate(path);

        interp = new Interp();

        var code:String = Assets.getText(path);
        var parser = new hscript.Parser();
        parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
        var expr:Expr;
        try {
            expr = parser.parseString(code, filename);
        } catch(e) {
            return;
        }
        interp.errorHandler = _errorHandler;
    }

    private function _errorHandler(error:Error) {
        error('$fileName:${error.line}: ${Std.string(error.e)}');
    }

    public override function call(func:String, parameters:Array<Dynamic>) {
        // TODO: call
    }
}