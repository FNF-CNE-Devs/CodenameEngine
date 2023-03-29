package funkin.scripting;

import hscript.Expr.Error;
import hscript.Parser;
import openfl.Assets;
import hscript.*;

class HScript extends Script {
	public var interp:Interp;
	public var parser:Parser;
	public var expr:Expr;

	public override function onCreate(path:String) {
		super.onCreate(path);

		interp = new Interp();

		var code:String = Assets.getText(path);
		parser = new Parser();
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
			if (code != null && code.trim() != "")
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

	public override function onDestroy() {
		@:privateAccess {
			// INTERP
			if (interp != null) {
				interp.scriptObject = null;
				interp.errorHandler = null;
				interp.variables.clear();
				interp.variables = null;
				interp.publicVariables = null;
				interp.staticVariables = null;
				for(l in interp.locals)
					if (l != null)
						l.r = null;
				interp.locals.clear();
				interp.locals = null;
				interp.binops.clear();
				interp.binops = null;
				interp.depth = 0;
				interp.inTry = false;
				while(interp.declared.length > 0)
					interp.declared.shift();
				interp.declared = null;
				interp.returnValue = null;
				interp.isBypassAccessor = false;
				interp.importEnabled = false;
				interp.allowStaticVariables = false;
				interp.allowPublicVariables = false;
				while(interp.importBlocklist.length > 0)
					interp.importBlocklist.shift();
				interp.importBlocklist = null;
				while(interp.__instanceFields.length > 0)
					interp.importBlocklist.shift();
				interp.__instanceFields = null;
				interp.curExpr = null;
			}

			if (parser != null) {
				parser.line = 0;
				parser.opChars = null;
				parser.identChars = null;
				parser.opPriority.clear();
				parser.opPriority = null;
				parser.opRightAssoc.clear();
				parser.opRightAssoc = null;
				parser.preprocesorValues.clear();
				parser.preprocesorValues = null;
				parser.input = null;
				parser.readPos = 0;
				parser.char = 0;
				parser.ops = null;
				parser.idents = null;
				parser.uid = 0;
				parser.origin = null;
				parser.tokenMin = 0;
				parser.tokenMax = 0;
				parser.oldTokenMin = 0;
				parser.oldTokenMax = 0;
				parser.tokens = null;
			}

			expr = null;
			parser = null;
			interp = null;
		}
	}
}