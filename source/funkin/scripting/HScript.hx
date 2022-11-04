package funkin.scripting;

import hscript.Expr.Error;
import openfl.Assets;
import hscript.*;

class HScript extends Script {
    var interp:Interp;
    var expr:Expr;

    public override function onCreate(path:String) {
        super.onCreate(path);

        interp = new Interp();

        var code:String = Assets.getText(path);
        var parser = new hscript.Parser();
        parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
        interp.errorHandler = _errorHandler;
        interp.staticVariables = Script.staticVariables;

        interp.variables.set("trace", this.trace);
        try {
            expr = parser.parseString(code, fileName);
        } catch(e) {
            return;
        }
    }

    private function _errorHandler(error:Error) {
        this.error('$fileName:${error.line}: ${error.toString()}');
    }

    public override function setParent(parent:Dynamic) {
        interp.scriptObject = parent;
    }

    public override function onLoad() {
        if (expr != null) interp.execute(expr);
    }

    public override function reload() {
        // save variables
        var savedVariables:Map<String, Dynamic> = [];
        for(k=>e in interp.variables) {
            if (!Reflect.isFunction(e)) {
                savedVariables[k] = e;
            }
        }
        var oldParent = interp.scriptObject;
        onCreate(path);
        load();
        setParent(oldParent);
        for(k=>e in savedVariables) {
            interp.variables.set(k, e);
        }
    }

    private override function onCall(funcName:String, parameters:Array<Dynamic>):Dynamic {
        if (interp == null) return null;

        var func = interp.variables.get(funcName);
        if (Reflect.isFunction(func))
            return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, func, parameters) : func();

        return null;
    }

    public override function get(val:String):Dynamic {
        return interp.variables.get(val);
    }

    public override function set(val:String, value:Dynamic) {
        interp.variables.set(val, value);
    }

    public override function trace(v:Dynamic) {
        var posInfo = interp.posInfos();
        Logs.traceColored([
            Logs.logText('${fileName}:${posInfo.lineNumber}: ', GREEN),
            Logs.logText(Std.string(v))
        ], TRACE);
    }

    public override function setPublicMap(map:Map<String, Dynamic>) {
        this.interp.publicVariables = map;
    }
}