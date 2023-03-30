package funkin.scripting;

import haxe.io.Path;
import funkin.scripting.Script.ScriptClass;
import hscript.Expr.ClassDecl;
import hscript.Expr.ModuleDecl;
import hscript.Expr.Error;
import hscript.Parser;
import openfl.Assets;
import hscript.*;

class HScript extends Script {
	public var interp:Interp;
	public var parser:Parser;
	public var expr:Expr;
	public var decls:Array<ModuleDecl> = null;
	public var code:String;
	public var folderlessPath:String;

	public static function initParser() {
		var parser = new Parser();
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		parser.preprocesorValues = Script.getDefaultPreprocessors();
		return parser;
	}

	public override function onCreate(path:String) {
		super.onCreate(path);

		interp = new Interp();

		code = Assets.getText(path);
		parser = initParser();
		folderlessPath = Path.directory(path);

		interp.errorHandler = _errorHandler;
		interp.importFailedCallback = importFailedCallback;
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

	private function importFailedCallback(cl:Array<String>):Bool {
		var path = cl.join("/");

		var scr = Script.create(Paths.script('classes/$path', null, false));
		if (!(scr is DummyScript)) {
			// script is valid
			var cla = scr.getClass(cl.last());
			if (cla != null) {
				interp.variables.set(cl.last(), Script.createCustomClass(cla));
			} else {
				interp.variables.set(cl.last(), scr);
			}

			return true;
		}
		
		return false;
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

	public override function getClass(name:String) {
		if (decls == null) {
			decls = parser.parseModule(code, fileName);
		}
		var imports:Array<Array<String>> = [];
		for(d in decls) {
			switch(d) {
				case DPackage(path):
					// ignore
				case DImport(path, everything):
					imports.push(path);
				case DClass(c):
					trace(c.name);
					trace(name);
					if (c.name == name)
						return new HScriptClass(c, interp, imports, folderlessPath);
				case DTypedef(c):
					// ignore
			}
		}
		return null;
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

class HScriptClass extends ScriptClass {
	var decl:ClassDecl;
	var name:String;

	var interp:Interp;

	public function new(decl:ClassDecl, sInterp:Interp, classesToImport:Array<Array<String>>, forderlessPath:String) {
		super();
		this.name = decl.name;
		switch(decl.extend) {
			case CTPath(p, params):
				this.classPath = p.join(".");
			default:
				
		}

		
		
		interp = new Interp();
		interp.errorHandler = sInterp.errorHandler;
		interp.staticVariables = sInterp.staticVariables;
		interp.allowStaticVariables = interp.allowPublicVariables = true;
		interp.importFailedCallback = importFailedCallback;

		var parser = HScript.initParser();

		for(f in decl.fields) {
			switch(f.kind) {
				case KVar(v):
					interp.variables[f.name] = interp.execute(v.expr);
				case KFunction(fun):
					@:privateAccess
					interp.variables[f.name] = interp.execute(parser.mk(EFunction(fun.args, fun.expr, f.name, fun.ret, false, false)));
			}
		}
	}

	public override function hasField(field:String) {
		return interp.variables.exists(field);
	}
	public override function get(field:String) {
		return interp.variables[field];
	}

	public override function set(field:String, v:Dynamic) {
		interp.variables[field] = v;
	}

	public override function onCall(field:String, parameters:Array<Dynamic>, parent:Dynamic) {
		interp.scriptObject = parent;
		var v = interp.variables[field];
		if (v != null && Reflect.isFunction(v))
			return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, v, parameters) : v();
		return null;
	}
}