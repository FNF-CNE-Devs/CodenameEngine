package funkin.scripting;

import hscript.Expr.Error;
import openfl.Assets;
import hscript.*;

class HScript extends Script {
    public var interp:Interp;
    public var expr:Expr;

    public override function onCreate(path:String) {
        super.onCreate(path);

        interp = new Interp();

        var code:String = Assets.getText(path);
        var parser = new hscript.Parser();
        parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
        parser.preprocesorValues = Script.getDefaultPreprocessors();
        interp.errorHandler = _errorHandler;
        interp.staticVariables = Script.staticVariables;
        interp.allowStaticVariables = interp.allowPublicVariables = true;

        interp.variables.set("trace", Reflect.makeVarArgs((args) -> {
            var v:String = Std.string(args.shift());
            for (a in args) v += ", " + Std.string(a);
            this.trace(v);
        }));

        try {
            expr = parser.parseString(code, fileName);
        } catch(e:Error) {
            _errorHandler(e);
        } catch(e) {
            _errorHandler(new Error(ECustom(e.toString()), 0, 0, fileName, 0));
        }
    }

    private function _errorHandler(error:Error) {

        var fn = '$fileName:${error.line}: ';
        var err = error.toString();
        if (err.startsWith(fn)) err = err.substr(fn.length);

        Logs.traceColored([
            Logs.logText(fn, GREEN),
            Logs.logText(err, RED)
        ], ERROR);
    }

    public override function setParent(parent:Dynamic) {
        interp.scriptObject = parent;
    }

    public override function onLoad() {
        if (expr != null) {
            interp.execute(expr);
            call("new", []);
        }
    }

    public override function reload() {
        // save variables
        
        interp.allowStaticVariables = interp.allowPublicVariables = false;
        var savedVariables:Map<String, Dynamic> = [];
        for(k=>e in interp.variables) {
            if (!Reflect.isFunction(e)) {
                savedVariables[k] = e;
            }
        }
        var oldParent = interp.scriptObject;
        onCreate(path);

        for(k=>e in Script.getDefaultVariables(this))
            set(k, e);

        load();
        setParent(oldParent);

        for(k=>e in savedVariables)
            interp.variables.set(k, e);

        interp.allowStaticVariables = interp.allowPublicVariables = true;
    }

    private override function onCall(funcName:String, parameters:Array<Dynamic>):Dynamic {
        if (interp == null) return null;

        var func = interp.variables.get(funcName);
        if (func != null && Reflect.isFunction(func))
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
            Logs.logText(Std.isOfType(v, String) ? v : Std.string(v))
        ], TRACE);
    }

    public override function setPublicMap(map:Map<String, Dynamic>) {
        this.interp.publicVariables = map;
    }
}