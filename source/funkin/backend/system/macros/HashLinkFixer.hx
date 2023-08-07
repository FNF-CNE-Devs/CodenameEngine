package funkin.backend.system.macros;

#if macro
import haxe.macro.Type.ClassType;
import Type.ValueType;
import haxe.macro.Expr.Function;
import haxe.macro.Expr;
import haxe.macro.Type.MetaAccess;
import haxe.macro.Type.FieldKind;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.VarAccess;
import haxe.macro.*;
import Sys;
import haxe.io.Path;

using StringTools;
using haxe.macro.PositionTools;

class HashLinkFixer {
	public static var buildMacroString = '@:build(funkin.backend.system.macros.HashLinkFixer.build())';

	public static var applyOn:Array<String> = [
		"lime",
		"std",
		"Math",
		"",
	];

	public static var modifiedClasses:Array<String> = [];

	public static function init() {
		#if !display
		#if HL
		for(apply in applyOn) {
			compile(apply);
		}
		#end
		#end
	}

	public static function compile(name:String) {
		#if !display
		Compiler.addGlobalMetadata(name, buildMacroString);
		#end
	}

	public static function build():Array<Field> {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		if (clRef == null) return fields;
		var cl = clRef.get();

		if (cl.isAbstract || cl.isExtern || cl.isInterface) return fields;
		if (!cl.name.endsWith("_Impl_") && !cl.name.endsWith("_HSX") && !cl.name.endsWith("_HSC") && !cl.name.endsWith("_HLFHelper")) {
			var metas = cl.meta.get();

			if(cl.params.length > 0)
				return fields;

			if(cl.module == "EReg") return fields; // private typedef in same class
			if(cl.module == "hl.Format") return fields; // enum in same class

			var definedFields = [];

			var helperClass = macro class {

			};

			helperClass.pos = cl.pos;

			var module = cl.module + "_HLFHelper";
			var hcClassName = cl.name + "_HLFHelper";

			for(f in fields.copy()) {
				if (f == null)
					continue;
				if (f.name == "new")
					continue;

				if(definedFields.contains(f.name)) continue; // no duplicate fields

				var hasHlNative = false;
				for(m in f.meta)
					if (m.name == ":hlNative") {
						hasHlNative = true;
						break;
					}

				if(!hasHlNative) continue;

				switch(f.kind) {
					case FFun(fun):
						if (fun == null)
							continue;
						if (fun.params != null && fun.params.length > 0) // TODO: Support for this maybe?
							continue;

						if(fun.params == null)
							fun.params = [];

						var overrideExpr:Expr;
						var returns:Bool = !fun.ret.match(TPath({name: "Void"}));

						var name = 'hlf_${f.name}';

						var arguments = fun.args == null ? [] : [for(a in fun.args) macro $i{a.name}];

						var funcExpr:Expr = returns ? {
							//macro return $i{name}($a{arguments});
							macro return @:privateAccess $i{hcClassName}.$name($a{arguments});
						} : {
							macro @:privateAccess $i{hcClassName}.$name($a{arguments});
						};

						var fiel:Field = {
							name: name,
							pos: Context.currentPos(),
							kind: FFun({
								ret: fun.ret,
								params: fun.params.copy(),
								expr: fun.expr,
								args: fun.args.copy()
							}),
							access: f.access.copy(),
							meta: f.meta.copy()
						};
						helperClass.fields.push(fiel);
						definedFields.push(f.name);

						for(m in f.meta.copy())
							if (m.name == ":hlNative") {
								f.meta.remove(m);
							}

						fun.expr = funcExpr;
					default:
				}
			}

			helperClass.pack = cl.pack.copy();
			helperClass.pos = cl.pos;
			helperClass.name = hcClassName;

			if(definedFields.length > 0) {
				trace(cl.module);

				/*for(m in metas.copy()) {
					trace("   " + m.name);
					if(m.name == ":coreApi") {
						metas.remove(m);
					}
				}*/

				var imports = Context.getLocalImports().copy();
				Context.defineModule(module, [helperClass], imports);

				Context.getLocalImports().push({
					path: [for(m in module.split(".")) {
						name: m,
						pos: Context.currentPos()
					}],
					mode: INormal
				});
			}
		}

		return fields;
	}
}
#else
class HashLinkFixer {
}
#end