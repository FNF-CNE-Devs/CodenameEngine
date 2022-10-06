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
            expr = parser.parseString(code, fileName);
        } catch(e) {
            return;
        }
        interp.errorHandler = _errorHandler;
    }

    private function _errorHandler(error:Error) {
        this.error('$fileName:${error.line}: ${error.toString()}');
    }

    public override function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
        // TODO: call
        super.call(func, parameters);
        return null;
    }
}